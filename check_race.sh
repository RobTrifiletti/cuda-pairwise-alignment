#!/bin/bash

RES1 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES2 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES3 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES4 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES5 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES6 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES7 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES8 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES9 = $(~/cuda-pairwise-alignment/run_tests.sh)
RES10 = $(~/cuda-pairwise-alignment/run_tests.sh)

#for i in 1 2 3 4 5 6 7 8 9 10
#do
#    res$i=$(~/cuda-pairwise-alignment/run_tests.sh)
#    echo "File $i written."
#done

for i in 1 2 3 4 5 6 7 8 9 10
do
    for j in 1 2 3 4 5 6 7 8 9 10
    do
	if ! diff res$i res$j >/dev/null
	then
	    echo "DIFFERENT!!!"
	fi
    done
done
