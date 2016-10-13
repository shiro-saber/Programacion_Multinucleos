#include <stdio.h>
#include "book.h"

/* experiment with N */
/* how large can it be? 536870911 cm */
#define imin(a,b) (a<b?a:b)
#define N 1000000
const int THREADS_PER_BLOCK = 256;
const int blocksPerGrid =
            imin( 32, (N/2+THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK );

__global__ void add(int size, int *a, int *b, int *c)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index < size)
    c[index] = a[index] + b[index];
  //__shared__ float cache[THREADS_PER_BLOCK];
  //int tid = threadIdx.x + blockIdx.x * blockDim.x;
  //int cacheIndex = threadIdx.x;

  //float   temp = 0;
  //while (tid < size) {
  //  c[tid] = a[tid] * b[tid];
    //  tid += blockDim.x * gridDim.x;
  //}
}//funcion de kernel cuda

struct DataStruct{
  int deviceID;
  int size;
  int *a;
  int *b;
  int *c;
};

void *addGPU(void *pvoidData)
{
   DataStruct *data = (DataStruct*)pvoidData;
   cudaSetDevice(data->deviceID);

   int *a, *b, *c;
   int *d_a, *d_b, *d_c;
   int size = data->size;
   float tiempo1, tiempo2;
   cudaEvent_t inicio1, fin1, inicio2, fin2; // para medir tiempos como con timestamp

   /* allocate space for host copies of a, b, c and setup input alues */
   a = data->a;
   b = data->b;
   c = data->c;

   cudaEventCreate(&inicio1); // Se inicializan
   cudaEventCreate(&fin1);
   cudaEventRecord( inicio1, 0 ); // Se toma el tiempo de inicio

   /* allocate space for device copies of a, b, c */

   cudaMalloc( (void **) &d_a, size);
   cudaMalloc( (void **) &d_b, size);
   cudaMalloc( (void **) &d_c, size);

   /* copy inputs to deice */
   /* fix the parameters needed to copy data to the device */
   cudaMemcpy( d_a, a, size, cudaMemcpyHostToDevice );// pasamos los datos a las GPU
   cudaMemcpy( d_b, b, size, cudaMemcpyHostToDevice );

   cudaEventCreate(&inicio2); // Se inicializan
   cudaEventCreate(&fin2);
   cudaEventRecord( inicio2, 0 ); // Se toma el tiempo de inicio

   /* launch the kernel on the GPU */
   add<<< blocksPerGrid, THREADS_PER_BLOCK >>>(size, d_a, d_b, d_c );

   cudaEventRecord( fin2, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin2 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo2, inicio2, fin2 );

   /* copy result back to host */
   /* fix the parameters needed to copy data back to the host */
   cudaMemcpy( c, d_c, size, cudaMemcpyDeviceToHost );//traduccion: regresamos los datos a ram

   cudaFree( d_a );
   cudaFree( d_b );
   cudaFree( d_c );//limpiamos la memoria de cuda

   cudaEventRecord( fin1, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin1 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo1, inicio1, fin1 );

   data->c = c;
   printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo2,tiempo1);

   return 0;
}

int main()
{
  cudaDeviceProp prop;
  int videos = 0;
  cudaGetDeviceCount(&videos);
  for (int i = 0; i < videos; ++i)
  {
    cudaGetDeviceProperties(&prop, i);
    printf("%d -> # tarjetas \n", videos);
  }

  int *a = (int *)malloc(sizeof(int)*N);
  int *b = (int *)malloc(sizeof(int)*N);
  int *c = (int *)malloc(sizeof(int)*N);

  for( int i = 0; i < N; i++ )
  {
     a[i] = b[i] = i+1;
     c[i] = 0;
  }

  DataStruct data[2];
  data[0].deviceID = 0;
  data[0].size = N*(3/4);
  data[0].a = a;
  data[0].b = b;
  data[0].c = c;

  data[1].deviceID = 1;
  data[1].size = N/4;
  data[1].a = a - N/2;
  data[1].b = b - N/2;
  data[1].c = c - N/2;

  CUTThread thread = start_thread(addGPU, &(data[0]));
  addGPU(&(data[1]));
  end_thread(thread);

  //for (int i=0; i<N; i++)
  //   printf( "%d + %d = %d\n", a[i], b[i], c[i] );

  /* clean up */

  free(a);
  free(b);
  free(c);

  return 0;
}
