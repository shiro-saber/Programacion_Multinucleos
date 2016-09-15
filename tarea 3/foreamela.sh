#!/bin/bash
if [ -z $1 ] || [ -z $2 ]
  then
     echo "Faltan opciones"
     echo "./foreamela A B"
     echo "A - dimesión de las matrices N*N"
     echo "B - 0 si queremos imprimir, 1 si no queremos"
  exit 1
fi

if [ $2 -ne 0 ] && [ $2 -ne 1 ]
  then
      echo "Caracter no válido en la opcion B"
  exit 
fi

make
#script para sacar el tiempo de ejecucion de lso propgramas y escribirlos en un archivo
echo ""
echo "puro CPU"
echo "puro CPU" >>  rpo.txt
for run in {1..20}; do
	./mCPU $1 $2 >> rpo.txt
done
echo ""
echo ""
echo ""
echo "CPU y OMP"
echo "CPU y OMP" >> rpo.txt
for run in {1..20}; do
	./mCPUOMP $1 $2 >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo bloques"
echo "solo bloques" >> rpo.txt
for run in {1..20}; do
	./mGPUB $1 $2 >> rpo.txt
done
echo ""
echo ""
echo ""
echo "solo threads" >> rpo.txt
echo "solo threads"
for run in {1..20}; do
	./mGPUT $1 $2 >> rpo.txt
done
echo ""
echo ""
echo ""
echo "bloques y threads" >> rpo.txt
echo "bloques y threads"
for run in {1..20}; do
	./mGPUBT $1 $2 >> rpo.txt
done

make clean

echo "Si se eligio la impresión, se podrá visualizar en el archivo rpo.txt"
#posteriormente sacamos los datos del archivo e hicimos los calculos
