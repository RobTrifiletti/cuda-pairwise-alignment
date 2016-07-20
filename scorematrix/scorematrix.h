#ifndef SCOREMATRIX_H
#define SCOREMATRIX_H

#include <stdio.h>

#define SCORE_MATRIX_SIZE 4

typedef struct ScoreMatrix {
  int gap;
  int **matrix;
} ScoreMatrix;

ScoreMatrix *scoreMatrixCreate(FILE *fp);
void scoreMatrixFree(ScoreMatrix *sm);
int scoreMatrixRead(ScoreMatrix *sm, char x, char y);

#endif