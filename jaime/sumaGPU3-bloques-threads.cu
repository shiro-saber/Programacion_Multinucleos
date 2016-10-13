#include <stdio.h>
#include "book.h"

/* experiment with N */
/* how large can it be? */
#define N 1000000
#define THREADS_PER_BLOCK 1000

__global__ void add(int *a, int *b, int *c, int size)
{
   int index = blockIdx.x * blockDim.x + threadIdx.x;
   if (index < size)
      c[index] = a[index] + b[index];
}

struct DataStruct {
    int    deviceID;
    int    size;
    int   *a;
    int   *b;
    int   *returnC;
};

void * sumaGPUS(void* dataI)
{
  DataStruct  *data = (DataStruct*)dataI;
  HANDLE_ERROR( cudaSetDevice( data->deviceID ) ); // 0 o 1

   int *a, *b, *c;
   int *d_a, *d_b, *d_c;
   int size = N * sizeof( int );
   float tiempo1, tiempo2;
   cudaEvent_t inicio1, fin1, inicio2, fin2; // para medir tiempos como con timestamp

   /* allocate space for host copies of a, b, c and setup input alues */

   a = (int *)malloc( size );
   b = (int *)malloc( size );
   c = (int *)malloc( size );

   for( int i = 0; i < N; i++ )
      a[i] = b[i] = i+1;

   /*
   cudaEventCreate(&inicio1); // Se inicializan
   cudaEventCreate(&fin1);
   cudaEventRecord( inicio1, 0 ); // Se toma el tiempo de inicio
   */

   /* allocate space for device copies of a, b, c */

   cudaMalloc( (void **) &d_a, size );
   cudaMalloc( (void **) &d_b, size );
   cudaMalloc( (void **) &d_c, size );

   /* copy inputs to deice */
   /* fix the parameters needed to copy data to the device */
   cudaMemcpy( d_a, a, size, cudaMemcpyHostToDevice );
   cudaMemcpy( d_b, b, size, cudaMemcpyHostToDevice );

   /*
   cudaEventCreate(&inicio2); // Se inicializan
   cudaEventCreate(&fin2);
   cudaEventRecord( inicio2, 0 ); // Se toma el tiempo de inicio
   */

   /* launch the kernel on the GPU */
   add<<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>( d_a, d_b, d_c, data->size );

   /*
   cudaEventRecord( fin2, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin2 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo2, inicio2, fin2 );
   */

   /* copy result back to host */
   /* fix the parameters needed to copy data back to the host */
   cudaMemcpy( c, d_c, size, cudaMemcpyDeviceToHost );

   cudaFree( d_a );
   cudaFree( d_b );
   cudaFree( d_c );

   /*
   cudaEventRecord( fin1, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin1 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo1, inicio1, fin1 );
   */

   //for (int i=0; i<N; i++)
  //    printf( "%d + %d = %d\n", a[i], b[i], c[i] );

   /* clean up */

   free(a);
   free(b);
   free(c);

   /*
   printf("Tiempo cálculo %f ms\n", tiempo2);
   printf("Tiempo total %f ms\n", tiempo1);
   */


} /* end main */

int main(void){
  float tiempo1, tiempo2;
  cudaEvent_t inicio1, fin1, inicio2, fin2; // para medir tiempos como con timestamp

cudaDeviceProp prop;
int numVideocards=0;
cudaGetDeviceCount(&numVideocards);
cudaGetDeviceProperties(&prop,1);
printf("num cards: %d \n",numVideocards);

int   *a = (int*)malloc( sizeof(int) * N );
HANDLE_NULL( a );
int   *b = (int*)malloc( sizeof(int) * N );
HANDLE_NULL( b );
int *c  = (int*)malloc( sizeof(int) * N );
int * kuz = (int*)malloc( sizeof(int) * N );
HANDLE_NULL( c );
// fill in the host memory with data
for (int i=0; i<N; i++) {
    a[i] = i;
    b[i] = i*2;
}

cudaEventCreate(&inicio1); // Se inicializan
cudaEventCreate(&fin1);
cudaEventRecord( inicio1, 0 ); // Se toma el tiempo de inicio

// prepare for multithread
DataStruct  data[2];
data[0].deviceID = 0;
data[0].size = N*3/4;
data[0].a = a;
data[0].b = b;
data[0].returnC = c;

data[1].deviceID = 1;
data[1].size = N/4;
data[1].a = a + N/2;
data[1].b = b + N/2;
data[1].returnC = c + N/2;

CUTThread   thread = start_thread( sumaGPUS, &(data[0]) );
sumaGPUS( &(data[1]) );
end_thread( thread );

cudaEventRecord( fin1, 0); // Se toma el tiempo final.
cudaEventSynchronize( fin1 ); // Se sincroniza
cudaEventElapsedTime( &tiempo1, inicio1, fin1 );
kuz[0]=*data[0].returnC;
kuz[N*3/4] =* data[1].returnC;
//for (int i=0; i<N; i++)
//    printf( "%d + %d = %d\n", a[i], b[i], c[i] );
for (int i=0; i<N; i++)
    printf( "%d + %d = %d\n", a[i], b[i], kuz[i] );

//printf("Tiempo cálculo %f ms\n", tiempo2);
printf("Tiempo allah %f ms\n", tiempo1);

  return 0;
}
