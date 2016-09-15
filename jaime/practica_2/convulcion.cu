#include <stdio.h>
#include <stdlib.h>

#define M 32

int t1,t2,t3;

void desplegar(int *m);
//funcion para la multiplicacion de matrices, el kernel
__global__ void calcularGPU3D(int *m1, int *m2, int *m3, int n)
{
   int i = blockIdx.x*blockDim.x + threadIdx.x;
   int j = blockIdx.y*blockDim.y + threadIdx.y;
   int k = blockIdx.z*blockDim.z + threadIdx.z;
   m3[i*n+j] = 0;
   __syncthreads();
   m3[i*n+j] += m1[i*n+k] * m2[k*n+j];
}

short n;
cudaEvent_t gpuI, gpuF;
float gpuT;
//llamada al kernel desde cpu
float multiplicarGPU(int *a, int *b, int *c)
{
   int *dev_a, *dev_b, *dev_c;
   cudaError_t err;

   cudaEventCreate( &gpuI );

   cudaEventCreate( &gpuF );
   cudaEventRecord( gpuI, 0 );
//funciones de mem y mallooc con sus errores cachados
   err=cudaMalloc( (void**)&dev_a, n*n*sizeof(int) );
   printf("CUDA malloc 1: %s\n",cudaGetErrorString(err));
   err=cudaMalloc( (void**)&dev_b, n*n*sizeof(int) );
   printf("CUDA malloc 2: %s\n",cudaGetErrorString(err));
   err=cudaMalloc( (void**)&dev_c, n*n*sizeof(int) );
   printf("CUDA malloc 3: %s\n",cudaGetErrorString(err));
   err=cudaMemcpy( dev_a, a, n*n*sizeof(int), cudaMemcpyHostToDevice );
   printf("CUDA mem copy: %s\n",cudaGetErrorString(err));
   err=cudaMemcpy( dev_b, b, n*n*sizeof(int), cudaMemcpyHostToDevice );
   printf("CUDA mem copy: %s\n",cudaGetErrorString(err));


      dim3 bloques( t2/M, t2/M, t2/M );
      dim3 threads( M, M, M );
      calcularGPU3D<<<bloques, threads>>>( dev_a, dev_b, dev_c, n );

   err=cudaDeviceSynchronize();
   printf("CUDA sync: %s\n",cudaGetErrorString(err));
   err=cudaMemcpy( c, dev_c, n*n*sizeof(int), cudaMemcpyDeviceToHost );
   printf("CUDA copy a CPU: %s\n",cudaGetErrorString(err));

   cudaEventRecord( gpuF, 0 );
   cudaEventSynchronize( gpuF );
   cudaEventElapsedTime( &gpuT, gpuI, gpuF );
   cudaFree( dev_a );
   cudaFree( dev_b );
   cudaFree( dev_c );
   return gpuT;
}

void desplegar(int *m)
{
   for (int i=0; i<n; i++)
   {
      for (int j=0; j<n; j++)
         printf("%d ", m[i*n+j]);
      printf("\n");
   }
   printf("\n");
}// buscando elefantes para cazarlos

//rellenamos las matrices
void inicializar(int *a, int *b, int *c)
{
   for(int i = 0; i<t2*t3; i++)
   {
      c[i] = 0;
   }//llenamos c con puro 0
   bool suma=true;
   int kuz=1;
   //llenamos b con filas de 1 al 255 ida y vvuelta ahsta que quede completo
   for(int i =0; i < t2*t3; i++){
     if (suma){
       b[i] = kuz;
       kuz++;
     }else{
       b[i]=kuz;
       kuz--;
     }
     if(i%255 == 0){
       suma = !suma;
     }
   }
   // llenar la matriz pequeña con 1 2 y 3
   for (int i=0;i<t1;i++){
   a[i]= 1;
   a[i+1]=2;
   a[i+2]=3;
 }
}


//llamar a la funcion que hace los mallocs y llama al kernel de cuda, algo asi como un proxy
void multiplicarMatrices( int *a, int *b, int *c)
{

   //int *a, *b, *c;



      multiplicarGPU( a, b, c) ;

    //desplegar(c);
   free( a );
   free( b );
   free( c );
}


//obtener la mini matriz de la mega matriz para poder ahcer la multiplicacion de matrizita con matriz pequeña
//osea, sacarle el pedazo a la matriz para sobreponerlo con  la otra
void minime(int *x,int *r,int iter){
  for(int i =0; i < t1;i++){
    for(int j=0; i < t1;j++){
      r[i+j] = x[(iter*i*j)];
    }
  }
}

//saca la suma y divicion de los elementos de la matriz resultante
int sumamela(int *d){
  int zain=0;
  for(int i =0; i< t1*t1; i++){
    zain += d[i];
  }
  zain /=(t1*t1);
  return zain;
}

// algo asi como el main, pero como no te gustan mains largos aki ta
void convulcion(){
  int *a, *b, *c, *d;//d es la matriz reducida de b para "sobnreponer" con a
  a = (int*) malloc(t1*sizeof(int));
  b = (int*) malloc(t2*t3*sizeof(int));
  c = (int*) malloc(t2*t3*sizeof(int));
//printf("inici\n");
  int iter =1;
  inicializar( a, b, c );
  //printf("inicializado\n");
  while(iter < (t2-1)*(t3-1))
  {
    //printf("problema\n");
  minime(b,d, iter);

  multiplicarMatrices(a,d,c);
  iter++;
  b[t2+1+iter] = sumamela(d);
  }

}

cudaEvent_t ts,tf ;
float tt;

int main (int argc, char *argv[] )
{
  cudaEventCreate( &ts );
  cudaEventCreate( &tf );
  cudaEventRecord( ts, 0 );
//iniciamos timers
//cachamos args del comando
   if ( argv[1] == NULL || argv[2]== NULL || argv[3]==NULL )
   {
      printf("insuficientes aprametros \n");
      return -3;
   }

   if(atoi(argv[1])%2 ==0 || atoi(argv[2])< 512 || atoi(argv[3])< 256)
    return -3;

    t1 = atoi(argv[1]);
    t2 = atoi(argv[2]);
    t3 = atoi(argv[3]);
   //multiplicarMatrices( atoi(argv[1]), atoi(argv[2]), atoi(argv[3]) );
   convulcion(); // nos vamos de cazeria yey
   cudaEventRecord( tf, 0 );
   cudaEventSynchronize( tf );
   cudaEventElapsedTime( &tt, ts, tf );
   printf("tiempo de calculo: %f \t tiempo total: %f \n", gpuT,tt); /// JAJAJAJAJ jamas llegaras a esta linea porque de PI#$%&# segmentation fault
   return 1;
}
