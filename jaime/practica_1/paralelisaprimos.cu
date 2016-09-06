#include <stdio.h>
#include <math.h>
#include <stdlib.h>


#define THREADS 1000
#define MAX 100000000

__global__ void primos (char * d_arr2, int *d_raiz){
	
	//int index = blockIdx.x * blockDim.x + threadIdx.x;
	//int raiz = sqrt(MAX);
	__shared__ char *d_arr;
	__syncthreads();
	d_arr = d_arr2;
	//__shared__ float cache[threadsPerBlock];
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int cacheIndex = threadIdx.x;

    if(d_arr2[tid] ==0)
	    while(tid*tid < MAX){

	    	d_arr2[tid*tid] =1;
	    	tid += blockDim.x * gridDim.x;
	    }

	
__syncthreads();
	printf("Run kernel: %s\n", cudaGetErrorString(cudaThreadSynchronize()));
}


int main(int argc, char *argv[])
{
	cudaEvent_t st1, fn1, st2,fn2;
	float tt1, tt2;

	cudaEventCreate( &st1 );
	cudaEventCreate( &fn1 );
	cudaEventRecord( st1, 0 );

	unsigned long i, j, c=0;
	char *arr = new char[MAX];
	char *d_arr;
	int *d_raiz;
	cudaMalloc((void**) &d_arr, MAX* sizeof(char));
	cudaMalloc((void**) &d_raiz, sizeof(int));
	int *raiz;
	*raiz = sqrt(MAX);


	for (i=0; i<MAX; i++)
		arr[i] = 0;
	arr[0] = 1;
	arr[1] = 1;

	cudaMemcpy(d_arr,arr,MAX*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_raiz,raiz,sizeof(int), cudaMemcpyHostToDevice);


	cudaEventCreate( &st2 );
	cudaEventCreate( &fn2 );
	cudaEventRecord( st2, 0 );

	primos<<<MAX/THREADS,THREADS>>>(d_arr,d_raiz);

	cudaEventRecord( fn2, 0 );
      cudaEventSynchronize( fn2 );
      cudaEventElapsedTime( &tt2, st2, fn2 );

cudaMemcpy(arr,d_arr, MAX*sizeof(char), cudaMemcpyDeviceToHost);
int cont =0;

      for (int i = 0; i < MAX; ++i)
      {
      	if(d_arr[i]==0){
      		cont++;
      	}

      }
printf("%ld\n", cont);

cudaFree(d_arr);
cudaFree(d_raiz);
free(arr);


	return 1;
}