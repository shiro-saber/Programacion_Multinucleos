#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <ctime>
#include <string>
#include <omp.h>

using namespace std;

int main ( int argc, char *argv[] )
{
  // Declaracion de variables de tiempo
  time_t t1,t2,tf;

  //variables para la convergencia del algoritmo
  double diff;
  double epsilon  = 0.001;
  FILE *fp; //apuntador para abrir el archivo
  int N, M; //grid size
  bool imprimemela;

  //iteradores que iteran
  int i;
  int iterations;
  int iterations_print;
  int j;
  double mean; //media del tiempo
  ofstream output; //archivo donde se va a guardar
  char output_filename[15] = "tvtomp.dat"; //nombre del archivo
  int success; //si se logro o no

  //definimos el tamaño del grid dependiendo de si hay input o no
  if (argc < 4)
  {
    M = 500;
    N = 500;
    imprimemela = false;
  }
  else
  {
    M = atoi(argv[1]);
    N = atoi(argv[2]);
    imprimemela = (atoi(argv[3]) == 1) ? 1 : 0; //if one liner )({|})(
  }

  //declaramos los grid
  double u[M][N]; //escritura
  double w[M][N]; //lectura

  cout << "Punto de calor" << endl;
  cout << "  Grid de " << M << " * " << N << " nodos"<<endl;

  cout << "  El estado estable se alcanzara cuando la diferencia sea <= " << epsilon << endl;
  diff = epsilon; //se define la diferencia

  cout << "Corriendo :(){ :|: & };:" << endl;

//  Definimos los boundaries del grid
#pragma omp parallel for
  for ( i = 1; i < M - 1; i++ )
    w[i][0] = 100.0;

#pragma omp parallel for
  for ( i = 1; i < M - 1; i++ )
    w[i][N-1] = 100.0;

#pragma omp parallel for
  for ( j = 0; j < N; j++ )
    w[M-1][j] = 100.0;

#pragma omp parallel for
  for ( j = 0; j < N; j++ )
    w[0][j] = 0.0;

// valor aproximado para los boundaries
  mean = 0.0;

#pragma omp parallel for
  for ( i = 1; i < M - 1; i++ )
    mean = mean + w[i][0];

#pragma omp parallel for
  for ( i = 1; i < M - 1; i++ )
    mean = mean + w[i][N-1];

#pragma omp parallel for
  for ( j = 0; j < N; j++ )
    mean = mean + w[M-1][j];

#pragma omp parallel for
  for ( j = 0; j < N; j++ )
    mean = mean + w[0][j];

  mean = mean / ( double ) ( 2 * M + 2 * N - 4 );

//  Inicializar grid de escritura
#pragma omp parallel for shared(i) private(j)
  for ( i = 1; i < M - 1; i++ )
    for ( j = 1; j < N - 1; j++ )
      w[i][j] = mean;

// iteramos hasta que la solucion no sea mayor a epsilon
  iterations = 0;
  iterations_print = 1;
  //cout << " Arepa"<<endl;
  time(&t1);

  while ( epsilon <= diff )
  {

//  escribimos en el grid de escritura
#pragma omp parallel for shared(i) private(j)
    for ( i = 0; i < M; i++ )
      for ( j = 0; j < N; j++ )
        u[i][j] = w[i][j];

    // definimos el nuevo estimado para los puntos interiores, se mueve para todos lados
    diff = 0.0;

#pragma omp parallel for shared(i) private(j)
    for ( i = 1; i < M - 1; i++ )
    {
      for ( j = 1; j < N - 1; j++ )
      {
        w[i][j] = ( u[i-1][j] + u[i+1][j] + u[i][j-1] + u[i][j+1] ) / 4.0;
        if ( diff < fabs ( w[i][j] - u[i][j] ) )
          diff = fabs ( w[i][j] - u[i][j] );
      }
    }

    iterations++;

    if ( iterations == iterations_print && imprimemela)
    {
      cout << "  " << setw(8) << iterations << "  " << diff << "\n";
      iterations_print = 2 * iterations_print;
    }
  }

  time(&t2);
  tf = t2-t1;

  cout << "  " << setw(8) << iterations << "  " << diff << endl;
  cout << "  Llegamos al epsilon deseado." << endl;
  cout << "  tiempo de CPU = " << tf << endl;

//  Escribimos los resultados en el archivo
  output.open ( output_filename );

  output << "Grid: " << M << " * " << N << endl;

  // escritura en output que ira al archivo
  for ( i = 0; i < M; i++ )
  {
    for ( j = 0; j < N; j++)
    {
      output << "  " << w[i][j];
    }
    output << "\n";
  }
  output << "  tiempo de CPU = " << tf << endl;
  output.close ( ); //cerramos archivo

  cout << "  No olvidar revisar el archivo "  << output_filename << endl;

  // Terminose.
  return tf;
}
