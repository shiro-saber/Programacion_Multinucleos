#!/bin/bash
echo "omp"  >> rpo.txt
for run in {1..20}; do
./cpu 500 500 0 
 $? >> rpo.txt
done
echo "" >> rpo.txt
echo "cpu " >> rpo.txt
for run in {1..20}; do
./omp 500 500 0
$? >> rpo.txt
done
