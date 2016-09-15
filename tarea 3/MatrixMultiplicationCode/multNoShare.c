#include "multNoShare.h"

// Matrix multiplication - Host code 
// Matrix dimensions are assumed to be multiples of BLOCK_SIZE 
 void MatMul(const Matrix A, const Matrix B, Matrix C) { 

  // Load A and B to device memory 
  Matrix d_A; 
  d_A.width = A.width; 
  d_A.height = A.height; 
  size_t size = A.width * A.height * sizeof(float); 
  cudaError_t err = cudaMalloc(&d_A.elements, size); 
  printf("CUDA malloc A: %s\n",cudaGetErrorString(err)); 
  err = cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice); 
  printf("Copy A to device: %s\n",cudaGetErrorString(err)); 
  
  Matrix d_B; 
  d_B.width = B.width; 
  d_B.height = B.height; 
  size = B.width * B.height * sizeof(float); 
  err = cudaMalloc(&d_B.elements, size); 
  printf("CUDA malloc B: %s\n",cudaGetErrorString(err));
  err = cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);
  printf("Copy B to device: %s\n",cudaGetErrorString(err)); 

  // Allocate C in device memory 
  Matrix d_C; 
  d_C.width = C.width; 
  d_C.height = C.height; 
  size = C.width * C.height * sizeof(float); 
  err = cudaMalloc(&d_C.elements, size); 
  printf("CUDA malloc C: %s\n",cudaGetErrorString(err));

  // Invoke kernel 
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE); 
  dim3 dimGrid((B.width + dimBlock.x - 1) / dimBlock.x, 
    (A.height + dimBlock.y - 1) / dimBlock.y); 
  MatMulKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C); 
  err = cudaThreadSynchronize();
  printf("Run kernel: %s\n", cudaGetErrorString(err));
  
  // Read C from device memory 
  err = cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost); 
  printf("Copy C off of device: %s\n",cudaGetErrorString(err));

  // Free device memory 
  cudaFree(d_A.elements); 
  cudaFree(d_B.elements); 
  cudaFree(d_C.elements); 
} 

// Matrix multiplication kernel called by MatMul() 
__global__ void MatMulKernel(Matrix A, Matrix B, Matrix C) { 
  // Each thread computes one element of C 
  // by accumulating results into Cvalue 
  float Cvalue = 0.0; 
  int row = blockIdx.y * blockDim.y + threadIdx.y; 
  int col = blockIdx.x * blockDim.x + threadIdx.x; 
  if(row > A.height || col > B.width) return;
  for (int e = 0; e < A.width; ++e) 
    Cvalue += (A.elements[row * A.width + e]) * (B.elements[e * B.width + col]); 
  C.elements[row * C.width + col] = Cvalue; 
}

// Usage: multNoShare a1 a2 b2
int main(int argc, char* argv[]){
  float tiempo1, tiempo2;
  cudaEvent_t inicio1, fin1, inicio2, fin2;
  cudaEventCreate(&inicio1); // Se inicializan
  cudaEventCreate(&fin1);
  cudaEventRecord( inicio1, 0 );

  Matrix A, B, C;
  int a1, a2, b1, b2;
  if(argv[1] == NULL || argv[2] == NULL || argv[3] == NULL){
    printf("esta funcion acepta 3 argumentos; ancho y alto de las matrices\n done el primer argumento es altura de A\n el segundo elemento es ancho de A y altura de B (para que las matrices sean multiplicables) \n el tercer argumento es ancho de B \n usaremos los defaults de 1000 por no dar arguemntos\n\n");
    printf("o no.\nERROR\n");
    //a1 = a2 = b1 = b2 = 1000;
    return -1;

  }else{
  // Read some values from the commandline
  a1 = atoi(argv[1]);			/* Height of A */
  a2 = atoi(argv[2]);			/* Width  of A */
  b1 = a2;		         	/* Height of B */
  b2 = atoi(argv[3]);			/* Width  of B */
  }
  A.height = a1;
  A.width = a2;
  A.elements = (float*)malloc(A.width * A.height * sizeof(float));

  B.height = b1;
  B.width = b2;
  B.elements = (float*)malloc(B.width * B.height * sizeof(float));

  C.height = A.height;
  C.width = B.width;
  C.elements = (float*)malloc(C.width * C.height * sizeof(float));

  srand(time(NULL));

  for(int i = 0; i < A.height; i++)
    for(int j = 0; j < A.width; j++)
      A.elements[i*A.width + j] = (float)((rand() % 1001)+10);

    for(int i = 0; i < B.height; i++)
      for(int j = 0; j < B.width; j++)
        B.elements[i*B.width + j] = (float)((rand() % 1001)+10);

      //lebnado de las matrices con numeros random 

  cudaEventCreate(&inicio2); // Se inicializan
  cudaEventCreate(&fin2);
  cudaEventRecord( inicio2, 0 );

  MatMul(A, B, C);

  cudaEventRecord( fin2, 0); // Se toma el tiempo final.
  cudaEventSynchronize( fin2 ); // Se sincroniza
  cudaEventElapsedTime( &tiempo2, inicio2, fin2 );

  cudaEventRecord( fin1, 0); // Se toma el tiempo final.
  cudaEventSynchronize( fin1 ); // Se sincroniza
  cudaEventElapsedTime( &tiempo1, inicio1, fin1 );

  /*
  int imprimemela =0;
  printf("1- imprimemela matriz\n0- no ver nada\n");
  scanf("%d", &imprimemela);
  if(imprimemela){  
  // Print up to a 10x10 portion of the three matrices
    for(int i = 0; i <  A.height; i++){
      for(int j = 0; j < A.width; j++)
        printf("%d ",(int) A.elements[i*A.width + j]);
      printf("\n");
    }
    printf("\n");

    for(int i = 0; i < B.height; i++){
      for(int j = 0; j <  B.width; j++)
        printf("%d ",(int) B.elements[i*B.width + j]);
      printf("\n");
    }
    printf("\n");

    for(int i = 0; i < C.height; i++){
      for(int j = 0; j < C.width; j++)
        printf("%d ",(int) C.elements[i*C.width + j]);
      printf("\n");
    }
    printf("\n");
  }
  */

  printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo2,tiempo1); //imprimir tiempos 
  
}
