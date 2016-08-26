ALL: sCPU sCPUOMP sGB sGT sGBT
CFLAGS=-Xcompiler -fopenmp -w 

.PHONY:clean

clean:
	@echo "Porque Kenny!"
	\rm -f *.o sCPU sCPUOMP sGB sGT sGBT

sCPU: sumaCPU2.cu
	nvcc $(CFLAGS) sumaCPU2.cu -g -o sCPU

sCPUOMP: sumaCPUOMP.cu
	nvcc $(CFLAGS) sumaCPUOMP.cu -g -o sCPUOMP

sGB: sumaGPU2-bloques.cu
	nvcc sumaGPU2-bloques.cu -g -o sGB

sGT: sumaGPU3-threads.cu
	nvcc sumaGPU3-threads.cu -g -o sGT

sGBT: sumaGPU3-bloques-threads.cu
	nvcc sumaGPU3-bloques-threads.cu -g -o sGBT
