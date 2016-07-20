#ifndef ALIGNMENT_H
#define ALIGNMENT_H
#include "scorematrix.h"

#ifdef __cplusplus
extern "C" {
#endif

void alignment(char *h_A, char *h_B, int M, int N, ScoreMatrix *sm);
char *copy_string_to_device(char *h_A, int len);
int *allocate_device_table(int M, int N);

#ifdef __cplusplus
}
#endif


#endif
