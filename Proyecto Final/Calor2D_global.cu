//////////////////////////////////////////////////////////////////
//Templete 2D para la ecuacion de calor sin uso de memoria de textura
//Basado en el programa demo:
//http://www.many-core.group.cam.ac.uk/projects/LBdemo.shtml
//Autor: Carlos Malaga
//Para compilar en CUDA 2.3
//nvcc -o templete Templete2D.cu -I$HOME/NVIDIA_GPU_Computing_SDK/C/common/inc 
//////////////////////////////////////////////////////////////

// Librerias
#include <stdio.h>
#include <stdlib.h>
#include <cutil.h>

// Tamaño del bloque
#define TILE_I 16
#define TILE_J 16

// Punteros en el CPU 
float *t0; 

// Punteros, arreglos y texturas en el GPU    
float             *t_data;
float         *t_data_old; 


// Escalares globales
float dx,dy,dp,dt,kcond;
int   ni,nj,paso;
size_t pitch;

// Definicion del CUDA kernel 
__global__ void solveheat_kernel (int ni, int nj, int pitch, float kcond, float dt, float dx, float dy, float *t_data, float *t_data_old);

// Definicion C wrappers
void solveheat(void);
void Imprimir(void);

///////////////////////////////////////////////////////////////////

int main(void)
{
    int i;
    int totpoints;


    dt = 0.01f;
    dx = 0.1f;
    dy = 0.1f;
    kcond = 0.01f;
    ni=800;
    nj=800;
    totpoints = ni*nj;

    printf ("ni = %d\n", ni);
    printf ("nj = %d\n", nj);
    printf ("Numero de puntos = %d\n", totpoints);
    
    // Asigna la memoria en el CPU (host)
    t0 = (float *)malloc(ni*nj*sizeof(float));

    // Asigna la memoria en el GPU (device)
    cudaMallocPitch((void **)&t_data, &pitch, sizeof(float)*ni, nj);
    cudaMallocPitch((void **)&t_data_old, &pitch, sizeof(float)*ni, nj);


    // Valores iniciales del campo t
    for (i=0; i<totpoints; i++) {
	t0[i] = 0.f;
    }
    t0[totpoints/2 + ni/2] = 1000.f;

    // Copia valores iniciales al GPU
    cudaMemcpy2D((void *)t_data, pitch, (void *)t0,sizeof(float)*ni,sizeof(float)*ni, nj,
                                cudaMemcpyHostToDevice);
   
    paso = 0;
    
    for (i=1;i<=10000;i++){    
    paso = paso + 1;   
    solveheat();   
    if (paso%1000 == 0) printf ("Iteracion: %d\n", paso);  
    }
    	
    Imprimir();

    // 	
    printf("CUDA: %s\n", cudaGetErrorString(cudaGetLastError()));
    
    return 0;
}

////////////////////////////////////////////////////////////////////////////////

void solveheat(void)
{
    // Copiado de t_data a t_array y "Bind" de t_array a la textura	
   
  cudaMemcpy2D((void *)t_data_old, pitch, (void *)t_data,sizeof(float)*ni,sizeof(float)*ni, nj,
                                cudaMemcpyDeviceToDevice);
   
	

    dim3 grid = dim3(ni/TILE_I, nj/TILE_J);
    dim3 block = dim3(TILE_I, TILE_J);

    solveheat_kernel<<<grid, block>>>(ni,nj,pitch,kcond,dt,dx,dy,t_data, t_data_old);


}

__global__ void solveheat_kernel (int ni,int nj,int pitch, float kcond, float dt, 
                                                float dx, float dy, float *t_data, float *t_data_old)
{
    int i, j, i2d, i2d2, i2d3, i2d4, i2d5;
    float told,tnow,tip1,tim1,tjp1,tjm1;
    
    i = blockIdx.x*TILE_I + threadIdx.x;
    j = blockIdx.y*TILE_J + threadIdx.y;

    i2d = i + j*pitch/sizeof(float);
    i2d2= (i+1) + (j)*pitch/sizeof(float);
    i2d3= (i-1) + (j)*pitch/sizeof(float);
    i2d4= (i) + (j+1)*pitch/sizeof(float);
    i2d5= (i) + (j-1)*pitch/sizeof(float);
    
    if (i ==ni-1) i2d2= ni-1 + (j)*pitch/sizeof(float);
    if (i == 0) i2d3= 0 + (j)*pitch/sizeof(float);
    if (j ==nj-1) i2d4= i + (nj-1)*pitch/sizeof(float);
    if (j == 0) i2d5= i + (0)*pitch/sizeof(float);

    told = t_data_old[i2d];
    tip1 = t_data_old[i2d2];
    tim1 = t_data_old[i2d3];
    tjp1 = t_data_old[i2d4];
    tjm1 = t_data_old[i2d5];

    tnow = told + dt*kcond*((tip1-2.0f*told+tim1)/(dx*dx) 
                          + (tjp1-2.0f*told+tjm1)/(dy*dy));
    t_data[i2d] = tnow;
}

////////////////////////////////////////////////////////////////////////////////

void Imprimir(void)
{
      
    int i, j, i2d;
    float t; 
    FILE *fp;

    // Copia de VRAM a RAM
    cudaMemcpy((void *)t0, (void *)t_data, nj*ni*sizeof(float), cudaMemcpyDeviceToHost);

    fp = fopen ( "Datos_sintex.dat", "w+" );
    
    for (i=0;i<ni;++i){
      for (j=0;j<nj;++j){
      i2d = i + ni*j;
      t = t0[i2d];
	fprintf(fp, "%f\t %f\t %f\n" , i*dx,j*dy,t);
      }
      fprintf(fp, "\n");
    }
    fclose ( fp );
}    

////////////////////////////////////////////////////////////////////////////////


