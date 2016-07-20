#!/bin/bash

mkdir fasta/build
cd fasta/build
cmake ..
make
cd ../..

mkdir scorematrix/build
cd scorematrix/build
cmake ..
make
cd ../..

mkdir ref/build
cd ref/build
cmake ..
make
cd ../..

mkdir par/build
cd par/build
cmake ..
make
cd ../..
