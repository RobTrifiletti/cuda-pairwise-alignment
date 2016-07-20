#!/bin/bash
let "number = 2"
for j in {1..20}
do
  let "number *= 2"
done
  let "number -= $j * number / 100"
python sequence_gen.py $number $number'b' > tests/suite/$number'b.fasta'