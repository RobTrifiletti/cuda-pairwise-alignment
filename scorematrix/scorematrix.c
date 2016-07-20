#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "scorematrix.h"

ScoreMatrix *scoreMatrixCreate(FILE *fp) {
  ScoreMatrix *sm = malloc(sizeof(ScoreMatrix));

  // Allocate space for the matrix values.
  sm->matrix = calloc(SCORE_MATRIX_SIZE, sizeof(int *));
  for (int i = 0; i < SCORE_MATRIX_SIZE; i++) {
    sm->matrix[i] = calloc(SCORE_MATRIX_SIZE, sizeof(int));
  }

  fscanf(fp, "%i\n", &sm->gap);
  for (int i = 0; i < SCORE_MATRIX_SIZE; i++) {
    fscanf(fp, "%i %i %i %i\n",
        sm->matrix[i], sm->matrix[i] + 1,
        sm->matrix[i] + 2, sm->matrix[i] + 3);
  }

  return sm;
}

int scoreMatrixRead(ScoreMatrix *sm, char x, char y) {
  int idx, jdx;

  switch (tolower(x)) {
    case 'a': idx = 0; break;
    case 'c': idx = 1; break;
    case 'g': idx = 2; break;
    case 't': idx = 3; break;
  }

  switch (tolower(y)) {
    case 'a': jdx = 0; break;
    case 'c': jdx = 1; break;
    case 'g': jdx = 2; break;
    case 't': jdx = 3; break;
  }

  return sm->matrix[idx][jdx];
}

void scoreMatrixFree(ScoreMatrix *sm) {
  for (int i = 0; i < SCORE_MATRIX_SIZE; i++) {
    free(sm->matrix[i]);
  }

  free(sm->matrix);
  free(sm);
}

#ifdef SM_DEBUG
int main(int argc, char **argv) {
  FILE *fp = fopen(argv[1], "r");
  ScoreMatrix *sm = scoreMatrixCreate(fp);

  printf("gap: %i\n", sm->gap);
  for (int i = 0; i < SCORE_MATRIX_SIZE; i++) {
    for (int j = 0; j < SCORE_MATRIX_SIZE; j++) {
      printf("%i ", sm->matrix[i][j]);
    }
    printf("\n");
  }

  printf("(a, a) = %i\n", scoreMatrixRead(sm, 'a', 'a'));
}
#endif