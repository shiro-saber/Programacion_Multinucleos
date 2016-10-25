// confio en la obviedad de esto
#include <math.h>
#include <string.h>
#include <openacc.h>
#include "timer.h"

int main(int argc, char** argv)
{
  int n = 4096; //matriz en n
  int m = 4096; //matriz en m
  int iter_max = 1000; //numero maximo de intentos para el resultado

  const float pi  = 2.0f * asinf(1.0f); //viva, es el valor de pi
  const float tol = 1.0e-5f; //es una variable del metodo de Laplace
  float error     = 1.0f; //el error permitido

  float A[n][m]; //matriz n*m
  float Anew[n][m]; //la que sera de cuda
  float y0[n]; //elementps

  memset(A, 0, n * m * sizeof(float)); //reservamos memoria

  // Ponemos las barreras
  for (int i = 0; i < m; i++)
  {
    A[0][i]   = 0.f; //en la barrera es 0
    A[n-1][i] = 0.f; //en la barrera es 0
  }

  for (int j = 0; j < n; j++)
  {
    y0[j] = sinf(pi * j / (n-1)); //una aplicacion del seno que para algo ha de servir
    A[j][0] = y0[j]; //elemento
    A[j][m-1] = y0[j]*expf(-pi); //algo mas del metodo de laplace
  }

  #if _OPENACC
    acc_init(acc_device_nvidia); //inciamos el ambiente de openAcc
  #endif

  printf("Jacobi relaxation Calculation: %d x %d mesh\n", n, m); //print

  StartTimer(); //esta tomando el tiempo
  int iter = 0; //en que iteracion vamos.

  #pragma omp parallel for shared(Anew) // en cpu
  for (int i = 1; i < m; i++)
  {
    Anew[0][i]   = 0.f;
    Anew[n-1][i] = 0.f;
  }

  #pragma omp parallel for shared(Anew) //en cpu
  for (int j = 1; j < n; j++)
  {
    Anew[j][0]   = y0[j];
    Anew[j][m-1] = y0[j]*expf(-pi); //ya lo hizo varias veces, lo importante es acc
  }

  #pragma acc data copy(A), create(Anew) //dejamos que pragma acc copie a GPU
  while (error > tol && iter < iter_max) //hasta que no lleguemos al resultado y a la ultima iteracion
  {
    error = 0.f;
    #pragma omp parallel for shared(m, n, Anew, A) //paralelizamos en cpu el envio de datos a GPU
      #pragma acc kernels loop gang(32), vector(16) //paralelizamos los kernels, los for y asignamos bloques y threads
        for( int j = 1; j < n-1; j++)
        {
          #pragma acc loop gang(16), vector(32) //paralelizamos otro loop con bloques y threads
          for( int i = 1; i < m-1; i++ )
          {
            Anew[j][i] = 0.25f * ( A[j][i+1] + A[j][i-1] + A[j-1][i] + A[j+1][i]); //comentario
            error = fmaxf( error, fabsf(Anew[j][i]-A[j][i])); //algo de Jacobi creo
          }
        }

  #pragma omp parallel for shared(m, n, Anew, A) //de nueva cuenta paralelizamos el envio de datos desde CPU
    #pragma acc kernels loop //de nueva cuenta paralelizamos los kernels que van a trabajar y los fot
    for( int j = 1; j < n-1; j++)
    {
      #pragma acc loop gang(16), vector(32) //mas for
      for( int i = 1; i < m-1; i++ )
      {
        A[j][i] = Anew[j][i]; // yeii
      }
    }

    if(iter % 100 == 0) printf("%5d, %0.6f\n", iter, error); //no se encontro
    iter++; //++ ++ ++ ++ ++ ++
  }

  double runtime = GetTimer(); //tiempo
  printf(" total: %f s\n", runtime / 1000.f); //me tarde
}
