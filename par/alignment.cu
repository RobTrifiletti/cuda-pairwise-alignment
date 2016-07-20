#include <stdio.h>
#include <stdlib.h>
#include "alignment.h"
#include "scorematrix.h"

#define BLOCK_SIZE_X 1
#define BLOCK_SIZE_Y 1024

// Must be an even number
// Largest possible: 7776
#define COMPUTE_SIZE 6000

#define INNER 0
#define OUTER 1
#define TOP 2

#define max(a, b) (a > b ? a : b)

__device__ __constant__ int s[SCORE_MATRIX_SIZE][SCORE_MATRIX_SIZE];
__device__ __constant__ int gap;

__device__ __shared__ int diags[2][BLOCK_SIZE_Y + 1];
__device__ __shared__ int top[COMPUTE_SIZE + 1];

__device__ __shared__ int result_thread;

__device__ __shared__ char s_A[BLOCK_SIZE_Y];
__device__ __shared__ char s_B[BLOCK_SIZE_Y + COMPUTE_SIZE];

__device__ int mmax(int a, int b, int c, int d) {
  return max(a, max(b, max(c, d)));
}

__global__ void
__launch_bounds__ (1024)
alignment_kernel(int *T, char *A, char *B, int t_M, int t_N, int k, int T_middle) {
  int x = -1;
  int y = -1;
  int t = k & 1;

  // Set x, y if we are in a root thread.
  for (int j = 0; j <= k / 2; j++) {
    int tmp_x = 2 * j + t;
    int tmp_y = k / 2 - j;
    if (blockIdx.x == tmp_x && blockIdx.y == tmp_y &&
        tmp_x <= t_N / COMPUTE_SIZE + 1 && tmp_y <= t_M / BLOCK_SIZE_Y) {
      x = tmp_x;
      y = tmp_y;
      break;
    }
  }
  if (x == -1 && y == -1) {
    return;
  }

  result_thread = INT_MIN;

  int ty_mod_2 = threadIdx.y & 1;
  int ty_div_2 = threadIdx.y >> 1;
  int BS_div_2 = BLOCK_SIZE_Y >> 1;
  
  int col = x * COMPUTE_SIZE - threadIdx.y - (COMPUTE_SIZE - (BLOCK_SIZE_Y - 1));
  int row = y * BLOCK_SIZE_Y + threadIdx.y;

  int num_of_blocks = k / 2 + 1;
  int block_num = num_of_blocks - y - 1;

  int data_size = (COMPUTE_SIZE + 2 * BLOCK_SIZE_Y);

  int vertical_offset = - k / 2 * BLOCK_SIZE_Y;
  int first_block_offset = - (COMPUTE_SIZE + BLOCK_SIZE_Y - 1);
  int odd_block_offset = t * COMPUTE_SIZE;
  int block_num_offset = (data_size + COMPUTE_SIZE - BLOCK_SIZE_Y) * block_num;

  int first_write_idx = T_middle + vertical_offset + first_block_offset + odd_block_offset + block_num_offset;
  int second_write_idx = first_write_idx + COMPUTE_SIZE;
  int third_write_idx = second_write_idx + BLOCK_SIZE_Y;
  
  int first_read_idx = first_write_idx - 1;
  int second_read_idx = first_read_idx + BLOCK_SIZE_Y;
  int third_read_idx = second_read_idx + BLOCK_SIZE_Y;

  // Read the relevant part of the two sequences into shared memory. 
  if (row > 0 && row <= t_M) {
    s_A[threadIdx.y] = A[row - 1];    
  }

  for (int i = 0; i <= (COMPUTE_SIZE + 1) / BLOCK_SIZE_Y + 1; i++) {
    if (i * BLOCK_SIZE_Y + col > 0 && i * BLOCK_SIZE_Y + col <= t_N &&
  i * BLOCK_SIZE_Y + (BLOCK_SIZE_Y - threadIdx.y - 1) < COMPUTE_SIZE + BLOCK_SIZE_Y) {
      s_B[i * BLOCK_SIZE_Y + (BLOCK_SIZE_Y - threadIdx.y - 1)] = B[i * BLOCK_SIZE_Y + col - 1];
    }
  }

  // Read into INNER and OUTER in shared memory
  int t_col = x * COMPUTE_SIZE + ty_div_2 - COMPUTE_SIZE - 1;
  if (t_col >= 0) {
    diags[ty_mod_2][ty_div_2 + ty_mod_2] = T[first_read_idx + threadIdx.y];
  } else {
    diags[ty_mod_2][ty_div_2 + ty_mod_2] = INT_MIN;
  }

  int t_row = y * BLOCK_SIZE_Y + BS_div_2 - (threadIdx.y + 1) / 2 - 1;
  if (t_col + BS_div_2 >= 0 && t_row >= 0) {
    diags[ty_mod_2][(ty_div_2) + BS_div_2 + ty_mod_2] = T[second_read_idx + threadIdx.y];
  } else {
    diags[ty_mod_2][(ty_div_2) + BS_div_2 + ty_mod_2] = INT_MIN;
  }
  

  // Read into TOP in shared memory
  for (int i = 0; i < (COMPUTE_SIZE + 1) / BLOCK_SIZE_Y + 1; i++) {
    if (i * BLOCK_SIZE_Y + threadIdx.y < COMPUTE_SIZE + 1) {
      int top_idx = col + i * BLOCK_SIZE_Y + 2 * threadIdx.y;
      if (y > 0 && top_idx >= 0) {
  top[i * BLOCK_SIZE_Y + threadIdx.y] = T[third_read_idx + i * BLOCK_SIZE_Y + threadIdx.y];
      } else {
  top[i * BLOCK_SIZE_Y + threadIdx.y] = INT_MIN;
      }
    }
  }

  int limit;
  if (row == t_M - 1 && col + COMPUTE_SIZE - 1 > t_N - 1) {
    result_thread = threadIdx.y;
    limit = t_N - col;
  } else {
    limit = COMPUTE_SIZE;
  }

  // Make sure that all three diags are written and every thread sees result_thread.
  __syncthreads();

  int fill_diag = 0;
  int v1;
  int v2;
  int v3;
  int v4;

  int bs_minus_ty = BLOCK_SIZE_Y - threadIdx.y;
  int bs_minus_ty_minus_one = BLOCK_SIZE_Y - threadIdx.y - 1;
  char s_A_value = s_A[threadIdx.y] & 3;
 
  int res = diags[fill_diag][bs_minus_ty_minus_one];
  
  // Start computation
  for (int i = 0; i < limit; i++) {
    diags[fill_diag][BLOCK_SIZE_Y] = top[i];

    // Diagonal
    v1 = diags[1 - fill_diag][bs_minus_ty] + s[ s_A_value ][ s_B[i + bs_minus_ty_minus_one] & 3 ];

    // Above
    v2 = diags[fill_diag][bs_minus_ty] + gap;

    // To the left
    v3 = res + gap;

    // (0,0) is guaranteed to be "small" negative number this way. 99 is to ensure a large value in the score matrix to not give a positive yield.
    v4 = - row - abs(col + i) * 99;

    fill_diag = 1 - fill_diag;
    
    res = mmax(v1, v2, v3, v4);
    diags[fill_diag][bs_minus_ty_minus_one] = res;

    // Sync before reading from fill_diag.
    __syncthreads();
    top[i] = diags[fill_diag][0];
  }
  
  if (threadIdx.y == 0) {
    diags[fill_diag][BLOCK_SIZE_Y] = top[COMPUTE_SIZE];
  }
  __syncthreads();
  
  // Write TOP array
  int t_row_top = y * BLOCK_SIZE_Y + BLOCK_SIZE_Y - 1;
  for (int i = 0; i < COMPUTE_SIZE / BLOCK_SIZE_Y + 1; i++) {
    int t_col_top = i * BLOCK_SIZE_Y + col - BLOCK_SIZE_Y + 2 * threadIdx.y + 1;
    if (t_row_top >= 0 && t_row_top < t_M && t_col_top >= 0 && t_col_top < t_N && i * BLOCK_SIZE_Y + threadIdx.y < COMPUTE_SIZE) {
      T[first_write_idx + i * BLOCK_SIZE_Y + threadIdx.y] = top[i * BLOCK_SIZE_Y + threadIdx.y];
    }
  }
  
  // Write the first half of INNER/OUTER array
  int t_row_first = row - threadIdx.y + BLOCK_SIZE_Y - ty_div_2 - 2;
  int t_col_first = col + COMPUTE_SIZE - BLOCK_SIZE_Y + threadIdx.y + ty_div_2 + ty_mod_2;
  if (t_row_first >= 0 && t_row_first < t_M && t_col_first >= 0 && t_col_first < t_N) {
    T[second_write_idx + threadIdx.y] = diags[1 - (ty_mod_2)][ty_div_2 + 1];
  }

  // Write the second half of INNER/OUTER array
  int t_row_second = t_row_first - BS_div_2;
  int t_col_second = t_col_first + BS_div_2;
  if (t_row_second >= 0 && t_row_second < t_M && t_col_second >= 0 && t_col_second < t_N) {
    T[third_write_idx + threadIdx.y] = diags[1 - (ty_mod_2)][(ty_div_2) + 1 + BS_div_2];
  }

  // The result is written to the start of T
  if (result_thread >= 0) {
    T[0] = diags[fill_diag][BLOCK_SIZE_Y - result_thread - 1];
  }

  // Wait for global memory writes to finish
  __syncthreads();
  __threadfence();
}

void alignment(char *h_A, char *h_B, int M, int N, ScoreMatrix *sm) {
  // Translate characters to score matrix indexes
  for (int i = 0; i < M; i++) {
    switch (h_A[i]) {
    case 'a': h_A[i] = 0; break;
    case 'c': h_A[i] = 1; break;
    case 'g': h_A[i] = 2; break;
    case 't': h_A[i] = 3; break;
    case 'A': h_A[i] = 0; break;
    case 'C': h_A[i] = 1; break;
    case 'G': h_A[i] = 2; break;
    case 'T': h_A[i] = 3; break;
    }
  }
  for (int i = 0; i < N; i++) {
    switch (h_B[i]) {
    case 'a': h_B[i] = 0; break;
    case 'c': h_B[i] = 1; break;
    case 'g': h_B[i] = 2; break;
    case 't': h_B[i] = 3; break;
    case 'A': h_B[i] = 0; break;
    case 'C': h_B[i] = 1; break;
    case 'G': h_B[i] = 2; break;
    case 'T': h_B[i] = 3; break;
    }
  }

  // Copy A and B to Device Memory.
  char *d_A = copy_string_to_device(h_A, M);
  char *d_B = copy_string_to_device(h_B, N);

  // The table is (M + 1) x (N + 1)
  int t_M = M + 1;
  int t_N = N + 1;

  // Setup dimensions of grid/blocks.
  dim3 blockDim(BLOCK_SIZE_X, BLOCK_SIZE_Y, 1);
  int gridX = (int) ceil(t_N / (double) COMPUTE_SIZE) + 1;
  int gridY = (int) ceil(t_M / (double) BLOCK_SIZE_Y);
  dim3 gridDim(gridX, gridY, 1);

  // Iterate over the score matrix and copy it into standard two-dim array. 
  int tmp_s[SCORE_MATRIX_SIZE][SCORE_MATRIX_SIZE];
  for(int i = 0; i < SCORE_MATRIX_SIZE; i++){
    for(int j = 0; j < SCORE_MATRIX_SIZE; j++){
      tmp_s[i][j] = sm->matrix[i][j];
    }
  }

  // Copy the score matrix and gap cost to constant memory on GPU
  cudaMemcpyToSymbol(s, tmp_s, 
    SCORE_MATRIX_SIZE * SCORE_MATRIX_SIZE * sizeof(int));
  cudaMemcpyToSymbol(gap, &sm->gap, sizeof(int));

  // Calculate the number of kernels to be invoked

  int row = 2 * t_M / BLOCK_SIZE_Y * BLOCK_SIZE_Y - t_M - 1;
  int col = BLOCK_SIZE_Y - 1 - row;
  int extra;
  if (col > t_N - 1) {
    extra = 0;
  } else {
    extra = 1;
  }
  int limit = ceil(2 * t_M / (float) BLOCK_SIZE_Y) + extra +
   floor((t_N / (float) COMPUTE_SIZE));
  
  // Allocate global memory array for partial results
  int *d_T;
  int d_T_size = (t_N / COMPUTE_SIZE + 1) * (2 * (t_M / BLOCK_SIZE_Y + 1) + COMPUTE_SIZE + 1) * sizeof(int) * 2;
  cudaMalloc(&d_T, d_T_size);

  // Calculate the center cell in the arrays for partial results
  int T_middle = d_T_size / sizeof(int) / 2 - 1;

  // Invoke kernel
  for (int k = 0; k < limit; k++) {
    alignment_kernel<<< gridDim, blockDim >>>(d_T, d_A, d_B, t_M, t_N, k, T_middle);
  }
  
  // Copy result to host
  int res;
  cudaMemcpy(&res, d_T, sizeof(int), cudaMemcpyDeviceToHost);

  // Print optimal score
  printf("Optimal score: %i\n", res);

  // Free memory
  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_T);
}

char *copy_string_to_device(char *h_str, int len) {
  char *d_str;
  cudaMalloc(&d_str, len);
  cudaMemcpy(d_str, h_str, len, cudaMemcpyHostToDevice);
  return d_str;
}

int *allocate_device_table(int M, int N) {
  int *table;
  cudaMalloc(&table, M * N * sizeof(int));
  cudaMemset(table, 0, M * N * sizeof(int));
  return table;
}
