ALL: mCPU mCPUOMP mGB mGT mGBT
CFLAGS=-Xcompiler -fopenmp -w

.PHONY:clean

clean:
	@echo "Porque Kenny!"
	\rm -f *.o mCPU mCPUOMP mGB mGT mGBT

mCPU: multMat.cu
	nvcc $(CFLAGS) multMat.cu -g -o mCPU

mCPUOMP: .cu
	nvcc $(CFLAGS) .cu -g -o mCPUOMP

mGB: .cu
	nvcc .cu -g -o mGB

mGT: .cu
	nvcc .cu -g -o mGT

mGBT: .cu
	nvcc .cu -g -o mGBT
#como nos dio flojera estar recompilando este make file compila todo junto
