//https://people.sc.fsu.edu/~jburkardt/cpp_src/heated_plate/heated_plate.html
# include <cstdlib>
# include <iostream>
# include <iomanip>
# include <fstream>
# include <cmath>
# include <ctime>
# include <string>

using namespace std;

int main ( int argc, char *argv[] );
double cpu_time ( );

int main ( int argc, char *argv[] )
{
  double ctime;
  double ctime1;
  double ctime2;
  double diff;
  double epsilon  = 0.001;
  FILE *fp;
  int N, M;
  int i;
  int iterations;
  int iterations_print;
  int j;
  double mean;
  ofstream output;
  char output_filename[10] = "tvt.dat";
  int success;

//  Read EPSILON from the command line or the user.

  if ( argc < 3 )
  {
    M = 500;
    N = 500;
  }
  else
  {
    M = atoi(argv[1]);
    N = atoi(argv[2]);
  }

  double u[M][N];
  double w[M][N];

  cout << "\n";
  cout << "HEATED_PLATE\n";
  cout << "\n";
  cout << "  Spatial grid of " << M << " by " << N << " points.\n";

  cout << "\n";
  cout << "  The iteration will be repeated until the change is <= " << epsilon << "\n";
  diff = epsilon;

  cout << "\n";
  cout << "  The steady state solution will be written to "<< output_filename << "\n";

//  Set the boundary values, which don't change.

  for ( i = 1; i < M - 1; i++ )
    w[i][0] = 100.0;

  for ( i = 1; i < M - 1; i++ )
    w[i][N-1] = 100.0;

  for ( j = 0; j < N; j++ )
    w[M-1][j] = 100.0;

  for ( j = 0; j < N; j++ )
    w[0][j] = 0.0;

//  Average the boundary values, to come up with a reasonable
//  initial value for the interior.
  mean = 0.0;

  for ( i = 1; i < M - 1; i++ )
    mean = mean + w[i][0];

  for ( i = 1; i < M - 1; i++ )
    mean = mean + w[i][N-1];

  for ( j = 0; j < N; j++ )
    mean = mean + w[M-1][j];

  for ( j = 0; j < N; j++ )
    mean = mean + w[0][j];

  mean = mean / ( double ) ( 2 * M + 2 * N - 4 );
//
//  Initialize the interior solution to the mean value.
//
  for ( i = 1; i < M - 1; i++ )
    for ( j = 1; j < N - 1; j++ )
      w[i][j] = mean;
//
//  iterate until the  new solution W differs from the old solution U
//  by no more than EPSILON.
//
  iterations = 0;
  iterations_print = 1;
  cout << "\n";
  cout << " Iteration  Change\n";
  cout << "\n";
  ctime1 = cpu_time ( );

  while ( epsilon <= diff )
  {

//  Save the old solution in U.
    for ( i = 0; i < M; i++ )
      for ( j = 0; j < N; j++ )
        u[i][j] = w[i][j];

//  Determine the new estimate of the solution at the interior points.
//  The new solution W is the average of north, south, east and west neighbors.

    diff = 0.0;
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

    if ( iterations == iterations_print )
    {
      cout << "  " << setw(8) << iterations << "  " << diff << "\n";
      iterations_print = 2 * iterations_print;
    }
  }

  ctime2 = cpu_time ( );
  ctime = ctime2 - ctime1;

  cout << "\n";
  cout << "  " << setw(8) << iterations << "  " << diff << "\n";
  cout << "\n";
  cout << "  Error tolerance achieved.\n";
  cout << "  CPU time = " << ctime << "\n";

//  Write the solution to the output file.
  output.open ( output_filename );

  output << M << "\n";
  output << N << "\n";

  for ( i = 0; i < M; i++ )
  {
    for ( j = 0; j < N; j++)
      output << "  " << w[i][j];
    output << "\n";
  }
  output.close ( );

  cout << "\n";
  cout << "  Solution written to the output file \"" << output_filename << "�\"�\n";

//  Terminate.

  cout << "\n";
  cout << "HEATED_PLATE:\n";
  cout << "  Normal end of execution.\n";

  return 0;
}

double cpu_time ( )
{
  double value;

  value = ( double ) clock ( ) / ( double ) CLOCKS_PER_SEC;

  return value;
}
