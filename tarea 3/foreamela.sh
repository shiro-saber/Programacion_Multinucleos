#!/bin/bash
make
#script para sacar el tiempo de ejecucion de lso propgramas y escribirlos en un archivo
echo ""
echo "puro CPU"
echo "puro CPU" >>  rpo.txt
for run in {1..20}; do
	./mCPU >> rpo.txt
done
echo ""
echo ""
echo ""
echo "CPU y OMP"
echo "CPU y OMP" >> rpo.txt
for run in {1..20}; do
	./mCPUOMP >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo bloques"
echo "solo bloques" >> rpo.txt
for run in {1..20}; do
	./mGB >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo threads" >> rpo.txt
echo "solo threads"
for run in {1..20}; do
	./mGT >> rpo.txt
done
echo ""
echo ""
echo ""
echo "bloques y threads" >> rpo.txt
echo "bloques y threads"
for run in {1..20}; do
	./mGBT >> rpo.txt
done

make clean
#posteriormente sacamos los datos del archivo e hicimos los calculos
