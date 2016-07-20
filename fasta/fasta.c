#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "fasta.h"

#define BUF_SIZE 40024

char *read_sequence(char *path) {
  FILE *fp = fopen(path, "r");

  unsigned int seq_size = 10 * BUF_SIZE;
  char *seq = malloc(seq_size);

  char buf[BUF_SIZE];
  int seq_idx = 0;
  while (fgets(buf, BUF_SIZE, fp) != NULL) {
    /* Ignore start tags and comments. */
    if (buf[0] == '>' || buf[0] == ';') {
      continue;
    }

    for (unsigned int i = 0; i < BUF_SIZE && buf[i] != '\0'; i++) {
      /* Ignore spaces and line breaks. */
      if (!isspace(buf[i])) {
        seq[seq_idx++] = buf[i];
        
        /* Reallocate sequence if necessary. */
        if (seq_idx > seq_size - 1) {
          seq_size *= 2;
          seq = realloc(seq, seq_size);
        }
      }
    }
  }

  fclose(fp);
  return seq;
}


