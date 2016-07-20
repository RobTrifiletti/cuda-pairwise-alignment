#include <stdlib.h>
#include <string.h>
#include "alignment.h"
#include "fasta.h"

int main(int argc, char **argv) {
  char *A = read_sequence(argv[1]);
  char *B = read_sequence(argv[2]);
  FILE *sm_fp = fopen(argv[3], "r");

  ScoreMatrix *sm = scoreMatrixCreate(sm_fp);

  int M = strlen(A);
  int N = strlen(B);

  if (N > M) {
    alignment(A, B, M, N, sm);
  } else {
    alignment(B, A, N, M, sm);
  }
  free(A);
  free(B);
  
  return EXIT_SUCCESS;
}
