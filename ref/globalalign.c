#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>

#include "globalalign.h"
#include "fasta.h"

#define max(a, b) (a > b ? a : b)

int main(const int argc, char **argv) {
  char *A = read_sequence(argv[1]);
  char *B = read_sequence(argv[2]);

  int M = strlen(A);
  int N = strlen(B);

  double gap = atof(argv[3]);

  int **T = allocate_table(1, N);

  int v1;
  int v2;
  int v3;
  int v4;
  int fillrow = 0;
  for (int i = 0; i <= M; i++) {
    for (int j = 0; j <= N; j++) {
      v1 = v2 = v3 = v4 = INT_MIN;

      if (i > 0 && j > 0) {
        v1 = T[1 - fillrow][j - 1] + s(A[i - 1], B[j - 1]);
      }
      if (i > 0 && j >= 0) {
        v2 = T[1 - fillrow][j] + gap;
      }
      if (i >= 0 && j > 0) {
        v3 = T[fillrow][j - 1] + gap;
      } 
      if (i == 0 && j == 0){
        v4 = 0;
      }
      T[fillrow][j] = mmax(v1, v2, v3, v4);
    }
    /* for(int j = 0; j <= N; j++) { */
    /*   printf("%i ", T[fillrow][j]); */
    /* } */
    /* printf("\n"); */
    
    fillrow = 1 - fillrow;
  }

  printf("optimal score: %i\n", T[1 - fillrow][N]);

  free_table(T, 1, N);

  free(A);
  free(B);

  return EXIT_SUCCESS;
}

int s(char a, char b) {
  if (tolower(a) == tolower(b)) {
    return 1;
  }
  return 0;
}

int mmax(int a, int b, int c, int d) {
  return max(a, max(b, max(c, d)));
}

int **allocate_table(int m, int n) {
  int **table = calloc(m + 1, sizeof(int *));
  for (int i = 0; i <= m; i++) {
    table[i] = calloc(n + 1, sizeof(int));
  }
  return table;
}

void free_table(int **table, int m, int n) {
  for (int i = 0; i <= m; i++) {
    free(table[i]);
  }
  free(table);
}
