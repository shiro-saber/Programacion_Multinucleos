/*
 * Copyright 1993-2010 NVIDIA Corporation.  All rights reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and 
 * proprietary rights in and to this software and related documentation. 
 * Any use, reproduction, disclosure, or distribution of this software 
 * and related documentation without an express license agreement from
 * NVIDIA Corporation is strictly prohibited.
 *
 * Please refer to the applicable NVIDIA end user license agreement (EULA) 
 * associated with this source code for terms and conditions that govern 
 * your use of this NVIDIA software.
 * 
 */


#include <stdio.h>
//GAHGHAGHAGHAHGAHGHA
// N= bloques
 // M= calculos 
#define N   1000
#define M   1000000
int d;

__global__ void add( int *a, int *b, int *c, int i ) {
   int tid = i*N+blockIdx.x; // vector index
   if (tid < M)
      c[tid] = a[tid] + b[tid];
}//funcion de kernel cuda

int main( void ) {
   int *a= new int[M], *b=new int[M], *c=new int[M];
   int *dev_a, *dev_b, *dev_c;
   float tiempo1, tiempo2;
   cudaEvent_t inicio1, fin1, inicio2, fin2; // para medir tiempos como con timestamp

   // llenar el arreglo NO en apralelo
   for (int i=0; i<M; i++)
      a[i] = b[i] = i+1;

   cudaEventCreate(&inicio1); // Se inicializan
   cudaEventCreate(&fin1); // un comentario por aqui 
   cudaEventRecord( inicio1, 0 ); // Se toma el tiempo de inicio

   d = M / N;
   //printf( "d:%d\n", d );

   // allocate the memory on the GPU
   cudaMalloc( (void**)&dev_a, M * sizeof(int) );
   cudaMalloc( (void**)&dev_b, M * sizeof(int) );
   cudaMalloc( (void**)&dev_c, M * sizeof(int) );//memoria en cuda 

   // copy the arrays 'a' and 'b' to the GPU
   cudaMemcpy( dev_a, a, M * sizeof(int), cudaMemcpyHostToDevice );// pasamos los datos a las GPU
   cudaMemcpy( dev_b, b, M * sizeof(int), cudaMemcpyHostToDevice );

   cudaEventCreate(&inicio2); // Se inicializan
   cudaEventCreate(&fin2);// otro comentario casual 
   cudaEventRecord( inicio2, 0 ); // Se toma el tiempo de inicio

   for (int i=0; i<d; i++)
      add<<<N,1>>>( dev_a, dev_b, dev_c, i );
//llamar la funcion del kernel de cuda 
   cudaEventRecord( fin2, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin2 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo2, inicio2, fin2 );//un comentario temporal 

   // copy the array 'c' back from the GPU to the CPU
   cudaMemcpy( c, dev_c, M * sizeof(int), cudaMemcpyDeviceToHost );//traduccion: regresamos los datos a ram

   // free the memory allocated on the GPU
   cudaFree( dev_a );
   cudaFree( dev_b );
   cudaFree( dev_c );//limpiamos la memoria de cuda

   cudaEventRecord( fin1, 0); // Se toma el tiempo final.
   cudaEventSynchronize( fin1 ); // Se sincroniza
   cudaEventElapsedTime( &tiempo1, inicio1, fin1 );// otro comentario temporal

   // display the results
   //for (int i=0; i<M; i++)
   //    printf( "%d + %d = %d\n", a[i], b[i], c[i] );

   free(a);//a es libre 
   free(b);// b es un elfo libre
   free(c);//sin patria ni libertad estaremos muy lejos de la verdadera felicidad --atte: c

   printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo2,tiempo1);// asi o mas comentado?
   return 0;
}
