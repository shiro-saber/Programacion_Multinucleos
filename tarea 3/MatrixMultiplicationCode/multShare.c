/*
 * multShare.c
 *
 * Robert Hochberg
 * January 24, 2012
 *
 * Based nearly entirely on the code from the CUDA C Programming Guide
 */

#include "multShare.h"

// Matrix multiplication - Host code 
// Matrix dimensions are assumed to be multiples of BLOCK_SIZE 
 void MatMul(const Matrix A, const Matrix B, Matrix C) { 
  // Load A and B to device memory 
  Matrix d_A; 
  d_A.width = d_A.stride = A.width; 
  d_A.height = A.height; 
  size_t size = A.width * A.height * sizeof(float); 
  cudaError_t err = cudaMalloc(&d_A.elements, size); 
  printf("CUDA malloc A: %s\n",cudaGetErrorString(err)); 
  err = cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice); 
  printf("Copy A to device: %s\n",cudaGetErrorString(err)); 

  Matrix d_B; 
  d_B.width = d_B.stride = B.width; 
  d_B.height = B.height; 
  size = B.width * B.height * sizeof(float); 
  err = cudaMalloc(&d_B.elements, size); 
  printf("CUDA malloc B: %s\n",cudaGetErrorString(err));
  err = cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);
  printf("Copy B to device: %s\n",cudaGetErrorString(err)); 

  // Allocate C in device memory 
  Matrix d_C; 
  d_C.width = d_C.stride = C.width; 
  d_C.height = C.height; 
  size = C.width * C.height * sizeof(float);
  printf("C.w: %d, C.H: %d\n",d_C.width,d_C.height);
  err = cudaMalloc(&d_C.elements, size); 
  printf("CUDA malloc C: %s\n",cudaGetErrorString(err));

  // Invoke kernel 
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE); 
  dim3 dimGrid(B.width / dimBlock.x, A.height / dimBlock.y); 
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

// Get a matrix element
__device__ float GetElement(const Matrix A, int row, int col) { 
  return A.elements[row * A.stride + col]; 
} 

// Set a matrix element 
__device__ void SetElement(Matrix A, int row, int col, float value) { 
  A.elements[row * A.stride + col] = value; 
} 

// Get the BLOCK_SIZExBLOCK_SIZE sub-matrix Asub of A that is 
// located col sub-matrices to the right and row sub-matrices down 
// from the upper-left corner of A 
__device__ Matrix GetSubMatrix(Matrix A, int row, int col) { 
  Matrix Asub; 
  Asub.width = BLOCK_SIZE; 
  Asub.height = BLOCK_SIZE; 
  Asub.stride = A.stride; 
  Asub.elements = &A.elements[A.stride * BLOCK_SIZE * row + BLOCK_SIZE * col]; 
  return Asub; 
}


// Matrix multiplication kernel called by MatMul() 
__global__ void MatMulKernel(Matrix A, Matrix B, Matrix C) { 
  // Block row and column 
  int blockRow = blockIdx.y; 
  int blockCol = blockIdx.x; 

  // Each thread block computes one sub-matrix Csub of C
  Matrix Csub = GetSubMatrix(C, blockRow, blockCol); 

  // Each thread computes one element of Csub 
  // by accumulating results into Cvalue 
  float Cvalue = 0.0; 

  // Thread row and column within Csub 
  int row = threadIdx.y; 
  int col = threadIdx.x; 

  // Loop over all the sub-matrices of A and B that are 
  // required to compute Csub 
  // Multiply each pair of sub-matrices together 
  // and accumulate the results 
  for (int m = 0; m < (A.width / BLOCK_SIZE); ++m) {
    // Get sub-matrix Asub of A 
    Matrix Asub = GetSubMatrix(A, blockRow, m); 

    // Get sub-matrix Bsub of B 
    Matrix Bsub = GetSubMatrix(B, m, blockCol); 

    // Shared memory used to store Asub and Bsub respectively 
    __shared__ float As[BLOCK_SIZE][BLOCK_SIZE]; 
    __shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE]; 

    // Load Asub and Bsub from device memory to shared memory 
    // Each thread loads one element of each sub-matrix 
    As[row][col] = GetElement(Asub, row, col); 
    Bs[row][col] = GetElement(Bsub, row, col); 

    // Synchronize to make sure the sub-matrices are loaded 
    // before starting the computation 
    __syncthreads(); 

    // Multiply Asub and Bsub together 
    for (int e = 0; e < BLOCK_SIZE; ++e) 
      Cvalue += As[row][e] * Bs[e][col];

    // Synchronize to make sure that the preceding 
    // computation is done before loading two new 
    // sub-matrices of A and B in the next iteration 
    __syncthreads();  
  }

  // Write Csub to device memory 
  // Each thread writes one element 
  SetElement(Csub, row, col, Cvalue); 
}



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
      A.elements[i*A.width + j] = (int)((rand() % 1001)+10);

    for(int i = 0; i < B.height; i++)
      for(int j = 0; j < B.width; j++)
        B.elements[i*B.width + j] = (int)((rand() % 1001)+10);
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

  printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo2,tiempo1);
  
  
  
}
