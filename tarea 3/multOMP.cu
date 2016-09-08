#include <stdlib.h>
#include <stdio.h>

int i, j, k;

//funcion que llena la matriz randonmente
float** rand_matrix(float **mat, int kuz)
{
  float **backup = mat;

  for(i = 0; i < kuz; i++)
    for(j = 0; j < kuz; j++)
      mat[i][j] = (rand()%1000+1);

    return backup;
}

//funcion para imprimir la matriz
void print_matrix(float **mat, int kuz)
{
    for(i = 0; i < kuz; i++)
    {
        for(j = 0; j < kuz; j++)
            printf(" %f |", mat[i][j]);

        printf("\n");
    }
}

int main(int argc, char *argv[])
{
  if (argc != 3)
  {
    fprintf(stderr, "The right use it's %s <number of the N*N matrix> <0 if you want prints or 1 if you don't>\n", argv[0]);
    exit(-1);
  }

  cudaEvent_t inicio, fin, st2, fn2;
  float tiempo, tt2;
  float **mat, **mat2, **res;
  int N = atoi(argv[1]);

  //iniciamos el crono
  cudaEventCreate( &st2 );
  cudaEventCreate( &fn2 );
  cudaEventRecord( st2, 0 );

  // aloja memoria para la matriz
  mat = (float **)malloc(N*sizeof(float*));
  mat2 = (float **)malloc(N*sizeof(float*));
  res = (float **)malloc(N*sizeof(float*));
  for(i = 0; i < N; i++)
  {
    //aloja la memoria por celda de la matriz
    mat[i] = (float *)malloc(N*sizeof(float));
    mat2[i] = (float *)malloc(N*sizeof(float));
    res[i] = (float *)malloc(N*sizeof(float));
  }

  //llena las matrices
  mat = rand_matrix(mat, N);
  mat2 = rand_matrix(mat2, N);

  //imprime las matrices
  if(atoi(argv[2]) == 0)
  {
    print_matrix(mat, N);
    printf("\n\n\n");
    print_matrix(mat2, N);
  }

  //crono de los calculos
  cudaEventCreate( &inicio );
  cudaEventCreate( &fin );
  cudaEventRecord( inicio, 0 );

  //hacemos la multiplicacion
  #pragma omp parallel for private(k)
    for(i=0; i<N; ++i)
      for(j=0; j<N; ++j)
        for(k=0; k<N; ++k)
          res[i][j]+=mat[i][k]*mat2[k][j];

  //paramos el crono de los calculos
  cudaEventRecord( fin, 0 );
  cudaEventSynchronize( fin );
  cudaEventElapsedTime( &tiempo, inicio, fin );

  //imprimimos el resultado
  if(atoi(argv[2]) == 0)
  {
    printf("\n\n\n");
    print_matrix(res,N);
  }

  //liberamesta
  free(mat);
  free(mat2);
  free(res);

  cudaEventRecord( fn2, 0 );
  cudaEventSynchronize( fn2 );
  cudaEventElapsedTime( &tt2, st2, fn2 );//paramos cronometro y medimos tiempo total
  printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tt2);//cazar elefantes... o imprimir no se solo soy un comentario
}
