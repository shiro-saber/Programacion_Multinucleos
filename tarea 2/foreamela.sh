#!/bin/bash
make

echo ""
echo "puro CPU"
echo "puro CPU" >>  rpo.txt
for run in {1..20}; do
	./sCPU >> rpo.txt
done
echo ""
echo ""
echo ""
echo "CPU y OMP"
echo "CPU y OMP" >> rpo.txt
for run in {1..20}; do
	./sCPUOMP >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo bloques"
echo "solo bloques" >> rpo.txt
for run in {1..20}; do
	./sGB >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo threads" >> rpo.txt
echo "solo threads"
for run in {1..20}; do
	./sGT >> rpo.txt
done
echo ""
echo ""
echo ""
echo "bloques y threads" >> rpo.txt
echo "bloques y threads"
for run in {1..20}; do
	./sGBT >> rpo.txt
done

make clean 
