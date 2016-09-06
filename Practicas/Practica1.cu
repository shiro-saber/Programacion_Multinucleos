/* primer practica Moi */
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Definicion de bloques y threads por bloque */
#define N 1000000
#define THREADS_PER_BLOCK 1000
/* Números a evaluar */
#define max 1000000

//kernel de CUDA
__global__ void primos(int *n_c, int *raiz_c)
{
  //sacamos el index
  int index = blockIdx.x * blockDim.x + threadIdx.x;

  n_c[0] = 1;
  n_c[1] = 1;

  /*if(index < max)
  {
    for(int i = index; i < raiz_c[0]; i+=2)
      n_c[i] = 1;
  }*/

  if(index <= raiz_c[0])
  {
    //for(int j = index*index; j < max; j+=index) => esta era la buena
    for(int j = index; j < max; j += index)
      n_c[j] = 1;
  }
}

int main(void)
{
  int *raiz;
  int number = 0;
  //arreglo
  int *n;
  //arreglo de cuda
  int *n_c;
  int *raiz_c;
  //tamaño del arreglo
  int size = max*sizeof(int);
  /* para tomar los tiempos */
  float tiempo1, tiempo2;
  cudaEvent_t inicio1, fin1, inicio2, fin2; // para medir tiempos como con timestamp

  /* Inicializacion de tiempo de ejecución */
  cudaEventCreate(&inicio1); // Se inicializan
  cudaEventCreate(&fin1);
  cudaEventRecord( inicio1, 0 ); // Se toma el tiempo de inicio

  //asignacion de memoria CPU
  n = (int*)malloc(sizeof(int)*max);
  raiz = (int*)malloc(sizeof(int)*1);

  //llenamos el arreglo en 0
  for(int i = 0; i < max; i++)
    n[i] = 0;

  raiz[0] = sqrt(max);

  //asignacion de memoria de cuda
  cudaMalloc((void **) &n_c, size);
  cudaMalloc((void **) &raiz_c, 1);
  //copiamos el arreglo a GPU
  cudaMemcpy(n_c, n, size, cudaMemcpyHostToDevice);
  cudaMemcpy(raiz_c, raiz, 1, cudaMemcpyHostToDevice);

  /* Tiempos de ejecución */
  cudaEventCreate(&inicio2); // Se inicializan
  cudaEventCreate(&fin2);
  cudaEventRecord(inicio2, 0); // Se toma el tiempo de inicio
  //llama del kernel de CUDA
  primos<<< N/THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(n_c, raiz_c);
  /* Paramos el crono de ejecución */
  cudaEventRecord(fin2,0);
  cudaEventSynchronize(fin2);
  cudaEventElapsedTime(&tiempo2, inicio2, fin2);

  //Regresamos el arreglo a CPU
  cudaMemcpy(n, n_c, size, cudaMemcpyDeviceToHost);

  for(int j = 0; j < max; j++)
    if(n[j] == 0)
    {
      //printf("%d\t", j);
      number++;
    }

  //Liberamos memoria en GPU
  cudaFree(n_c);
  cudaFree(raiz_c);

  printf("El número de números primos en %d es: %d\n", max, number);
  printf("Herr Moy\n");
  cudaEventRecord(fin1, 0); // Se toma el tiempo final.
  cudaEventSynchronize(fin1); // Se sincroniza
  cudaEventElapsedTime(&tiempo1, inicio1, fin1);

  printf("El tiempo de ejecución es: %f\tEl tiempo de cálculos es: %f\n", tiempo1, tiempo2);

  //liberamos memoria de CPU
  free(n);
  free(raiz);
  return 0;
}
