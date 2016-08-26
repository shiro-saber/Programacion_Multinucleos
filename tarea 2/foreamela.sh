#!/bin/bash
make

echo ""
echo "puro CPU"
for run in {1..20}; do
	./sCPU
done
echo ""
echo ""
echo ""
echo "CPU y OMP"
for run in {1..20}; do
	./sCPUOMP
done
echo ""
echo ""
echo ""
echo "solo bloques"
for run in {1..20}; do
	./sGB
done
echo ""
echo ""
echo ""
echo "solo threads"
for run in {1..20}; do
	./sGT
done
echo ""
echo ""
echo ""
echo "bloques y threads"
for run in {1..20}; do
	./sGBT
done

make clean 
