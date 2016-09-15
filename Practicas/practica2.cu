#include <stdio.h>
#include <stdlib.h>
//M*N

#define M 32

//llamada de kernel de cuda
__global__ void euler(int **a, int **b, int **c, int n, int m, int p)
{
  // aqui es cuando empezamos a llorar
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  int j = blockIdx.y*blockDim.y + threadIdx.y;

  __syncthreads();
  c[i+j][j] = b[i+j][j] + a[i+j][j];
}

//funcion para imprimir
void print_matrix(int** mat, int kuz, int kuzemac)
{
  for(int i = 0; i < kuz; i++)
  {
      for(int j = 0; j < kuzemac; j++)
          printf(" %d |", mat[i][j]);

      printf("\n");
  }
}

//funcion que hara el traspaso a la memoria de videoy el regreso de la misma
float eulerGPU(int **a, int **b, int **c, int n, int m, int p)
{
  int **c_a, **c_b, **c_c;
  cudaEvent_t inicio, fin;
  float tiempo_c;

  // reservamos memoria para cada parte de video
  cudaMalloc((void**)&c_a, n*sizeof(int*));
  cudaMalloc((void**)&c_c, n*sizeof(int*));
  cudaMalloc((void**)&c_b, p*sizeof(int*));
  for (int i = 0; i < n; ++i)
  {
    cudaMalloc((void**)&c_a[i], m*sizeof(int));
    cudaMalloc((void**)&c_c[i], m*sizeof(int));
  }
  for (int j = 0; j < p; ++j)
    cudaMalloc((void**)&c_b[j], p*sizeof(int));

  //copiamos a GPU
  cudaMemcpy(c_a, a, n*m*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(c_b, b, p*p*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(c_c, c, n*m*sizeof(int), cudaMemcpyHostToDevice);

  //definimos las dimensiones de los bloques y los threads
  dim3 bloques(p/M, p/M);
  dim3 threads(M, M);

  //tomar el tiempo \o/
  cudaEventCreate(&inicio);
  cudaEventCreate(&fin);
  cudaEventRecord(inicio, 0);

  //llamas a cuda
  euler<<<bloques, threads>>>(c_a, c_b, c_c, n, m, p);

  //regresamos a CPU
  cudaMemcpy(c, c_c, n*m*sizeof(int), cudaMemcpyDeviceToHost);

  //terminmamos el tiempo
  cudaEventRecord(fin, 0);
  cudaEventSynchronize(fin);
  cudaEventElapsedTime(&tiempo_c, inicio, fin);

  //imprimir los resultados
  print_matrix(c, n, m);

  return tiempo_c;
}

void inicializar(int** a, int** b, int** c_t, int n, int m, int p)
{
  cudaEvent_t init, end;
  float tiempo_t;
  int d;
  int c = 255;

  //tiempos
  cudaEventCreate(&init);
  cudaEventCreate(&end);
  cudaEventRecord(init, 0);

  // para inicializar la matriz
  for (int i = 0; i < n; ++i)
  {
    for (int j = 0; j < m; ++j)
      a[i][j] = c;
    c--;
  }

  for (int x = 0; x < n; ++x)
    for (int y = 0; y < m; ++y)
      c_t[x][y] = 0;

  for (int k = 0; k < p; ++k)
  {
    d = 1;
    for (int l = 0; l < p; ++l)
    {
      b[l][k] = d;
      d++;
    }
  }

  //neta teniamos que comentar cada linea?
  cudaEventRecord(end, 0);
  cudaEventSynchronize(end);
  cudaEventElapsedTime(&tiempo_t, init, end);

  printf("El tiempo que tarda es: %fms en cálculos\nEl tiempo que tarda: %fms en total\n", eulerGPU(a,b,c_t,n,m,p), tiempo_t); //que? no llegaste? por eso el grito jajaja
}

void solve(char p, char n, char m)
{
  int **a, **b, **c;
  // a sera la matriz de n*m
  a = (int**)malloc(n*sizeof(int*));
  // b sera la matriz de p*p
  b = (int**)malloc(p*sizeof(int*));
  //c matriz resultante
  c = (int**)malloc(n*sizeof(int*));
  for (int i = 0; i < n; ++i)
  {
    a[i] = (int*)malloc(m*sizeof(int));
    c[i] = (int*)malloc(m*sizeof(int));
  }

  for (int j = 0; j < p; ++j)
    b[j] = (int*)malloc(p*sizeof(int));

  // inicializamos las matrices con los valores pedidos
  inicializar(a, b, c, n, m, p);
  free(a);
  free(b);
  free(c);
}

int main(int argc, char *argv[])
{
  if ( argc != 4 )
  {
     //printf("%d\n", argc);
     printf("%s 1- valor de p 2- valor de M 3- valor de N\n", argv[0]);
     exit(0);
  }
  if (atoi(argv[1]) % 2 == 0 && atoi(argv[1]) > 7)
  {
    printf("P tiene que ser impar y se permite máximo 7x7\n");
    exit(0);
  }

  solve(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]));
  // Ya di el grito
  return 0;
}
