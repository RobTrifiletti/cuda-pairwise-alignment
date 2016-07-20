#!/bin/sh
echo "<seq1, seq2>"
echo "<par result>"
echo "<ref result>"
echo

echo "slide1, slide1"
par/build/alignment tests/slide1.fasta tests/slide1.fasta tests/standard_score.sm
ref/build/globalalign tests/slide1.fasta tests/slide1.fasta tests/standard_score.sm
echo 
echo "slide2, slide2"
par/build/alignment tests/slide2.fasta tests/slide2.fasta tests/standard_score.sm
ref/build/globalalign tests/slide2.fasta tests/slide2.fasta tests/standard_score.sm
echo 
echo "slide1, slide2"
par/build/alignment tests/slide1.fasta tests/slide2.fasta tests/standard_score.sm
ref/build/globalalign tests/slide1.fasta tests/slide2.fasta tests/standard_score.sm
echo 
echo "slide2, slide1"
par/build/alignment tests/slide2.fasta tests/slide1.fasta tests/standard_score.sm
ref/build/globalalign tests/slide2.fasta tests/slide1.fasta tests/standard_score.sm
echo 
echo "slide3, slide3"
par/build/alignment tests/slide3.fasta tests/slide3.fasta tests/standard_score.sm
ref/build/globalalign tests/slide3.fasta tests/slide3.fasta tests/standard_score.sm
echo 
echo "slide1, slide3"
par/build/alignment tests/slide1.fasta tests/slide3.fasta tests/standard_score.sm
ref/build/globalalign tests/slide1.fasta tests/slide3.fasta tests/standard_score.sm
echo 
echo "slide2, slide3"
par/build/alignment tests/slide2.fasta tests/slide3.fasta tests/standard_score.sm
ref/build/globalalign tests/slide2.fasta tests/slide3.fasta tests/standard_score.sm
echo 
echo "slide3, slide2"
par/build/alignment tests/slide3.fasta tests/slide2.fasta tests/standard_score.sm
ref/build/globalalign tests/slide3.fasta tests/slide2.fasta tests/standard_score.sm
echo 
echo "human-pgr-medium, slide1"
par/build/alignment tests/human-pgr-medium.fasta tests/slide1.fasta tests/standard_score.sm
ref/build/globalalign tests/human-pgr-medium.fasta tests/slide1.fasta tests/standard_score.sm
echo 
echo "human-pgr-medium, slide2"
par/build/alignment tests/human-pgr-medium.fasta tests/slide2.fasta tests/standard_score.sm
ref/build/globalalign tests/human-pgr-medium.fasta tests/slide2.fasta tests/standard_score.sm
echo 
echo "human-pgr-medium, slide3"
par/build/alignment tests/human-pgr-medium.fasta tests/slide3.fasta tests/standard_score.sm
ref/build/globalalign tests/human-pgr-medium.fasta tests/slide3.fasta tests/standard_score.sm
echo 
echo "slide1, human-pgr-medium"
par/build/alignment tests/slide1.fasta tests/human-pgr-medium.fasta tests/standard_score.sm
ref/build/globalalign tests/slide1.fasta tests/human-pgr-medium.fasta tests/standard_score.sm
echo 
echo "slide2, human-pgr-medium"
par/build/alignment tests/slide2.fasta tests/human-pgr-medium.fasta tests/standard_score.sm
ref/build/globalalign tests/slide2.fasta tests/human-pgr-medium.fasta tests/standard_score.sm
echo 
echo "slide3, human-pgr-medium"
par/build/alignment tests/slide3.fasta tests/human-pgr-medium.fasta tests/standard_score.sm
ref/build/globalalign tests/slide3.fasta tests/human-pgr-medium.fasta tests/standard_score.sm

