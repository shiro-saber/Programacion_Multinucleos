ALL: mCPU mCPUOMP mGPUBT mGPUB mGPUT 
CFLAGS=-Xcompiler -fopenmp -w

.PHONY:clean

clean:
	@echo "Porque Kenny!"
	\rm -f *.o mCPU mCPUOMP mGPUB mGPUT mGPUBT

mCPU: multMat.cu
	nvcc $(CFLAGS) multMat.cu -g -o mCPU

mCPUOMP: multOMP.cu
	nvcc $(CFLAGS) multOMP.cu -g -o mCPUOMP

mGPUBT: multGPUBT.cu multGPUBT.h
	nvcc multGPUBT.cu -g -o mGPUBT

mGPUT: multGPUT.cu multGPUBT.h
	nvcc multGPUT.cu -g -o mGPUT

mGPUB: multGPUB.cu multGPUBT.h
	nvcc multGPUB.cu -g -o mGPUB
#como nos dio flojera estar recompilando este make file compila todo junto
