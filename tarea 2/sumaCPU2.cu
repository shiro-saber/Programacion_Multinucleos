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
#include <omp.h>

#define N 1000000

void add( int *a, int *b, int *c ) {
   int tid = 0;    
   while (tid < N) {
      c[tid] = a[tid] + b[tid];
      tid ++;   
   }//#noSeHacerUnFor
}// y tal vez algunos calculos 

int main( void ) {
   int *a=new int[N], *b = new int[N], *c = new int[N];
   cudaEvent_t inicio, fin,st2,fn2;
   float tiempo, tt2;

   cudaEventCreate( &st2 );
   cudaEventCreate( &fn2 );
   cudaEventRecord( st2, 0 );
   // para medir el tiempo TOTAL
   for (int i=0; i<N; i++)
      a[i] = b[i] = i+1;//FOR para dar valores iniciales

   cudaEventCreate( &inicio );
   cudaEventCreate( &fin );
   cudaEventRecord( inicio, 0 );//para medir el tiempo de EJECUCION
   add( a, b, c );
   cudaEventRecord( fin, 0 );
   cudaEventSynchronize( fin );
   cudaEventElapsedTime( &tiempo, inicio, fin );//paramos cronometro y medimos tiempo

   // display the results
   //for (int i=0; i<N; i++)
   //   printf( "%d + %d = %d\n", a[i], b[i], c[i] );
   //for para testear

   free(a);
   free(b);
   free(c);
   cudaEventRecord( fn2, 0 );
   cudaEventSynchronize( fn2 );
   cudaEventElapsedTime( &tt2, st2, fn2 );//paramos cronometro y medimos tiempo
   printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tt2);//cazar elefantes... o imprimir no se solo soy un comentario

   return 0;
}
