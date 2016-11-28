//https://people.sc.fsu.edu/~jburkardt/cpp_src/heated_plate/heated_plate.html
#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <ctime>
#include <string>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

double diff;
double epsilon = 0.001;
//  FILE *fp; //apuntador para abrir el archivo
int N, M; //grid size
//  bool imprimemela;

//iteradores que iteran
int i;
int iterations;
int iterations_print;
int j;
int iterador = 0;
double mean; //media del tiempo
double **u; //[M][N]; //escritura
double **w; //[M][N]; //lectura

using namespace std;

void init(void) {

  glClearColor(0.0, 0.0, 0.0, 0.0);
  glShadeModel(GL_FLAT);


  cout << "Punto de calor" << endl;
  cout << "  Grid de " << M << " * " << N << " nodos" << endl;

  w = (double **) malloc(M * sizeof(double *));
  u = (double **) malloc(M * sizeof(double *));

  for (int k = 0; k < N; k++){
    w[k] = (double *) malloc(N * sizeof(double));
    u[k] = (double *) malloc(N * sizeof(double));
  }

  cout << "  El estado estable se alcanzara cuando la diferencia sea <= " << epsilon << endl;
  diff = epsilon; //se define la diferencia

  cout << "Corriendo :(){ :|: & };:" << endl;

//  Definimos los boundaries del grid
  for (i = 1; i < M - 1; i++)
    w[i][0] = 100.0;

  for (i = 1; i < M - 1; i++)
    w[i][N - 1] = 100.0;

  for (j = 0; j < N; j++)
    w[M - 1][j] = 100.0;

  for (j = 0; j < N; j++)
    w[0][j] = 0.0;

// valor aproximado para los boundaries
  mean = 0.0;

  for (i = 1; i < M - 1; i++)
    mean = mean + w[i][0];

  for (i = 1; i < M - 1; i++)
    mean = mean + w[i][N - 1];

  for (j = 0; j < N; j++)
    mean = mean + w[M - 1][j];

  for (j = 0; j < N; j++)
    mean = mean + w[0][j];

  mean = mean / (double) (2 * M + 2 * N - 4);

//  Inicializar grid de escritura
  for (i = 1; i < M - 1; i++)
    for (j = 1; j < N - 1; j++)
      w[i][j] = mean;

// iteramos hasta que la solucion no sea mayor a epsilon
  iterations = 0;
  iterations_print = 1;

}
void display(void) {

  glClearColor(0, 0, 0, 1);
  glClear(GL_COLOR_BUFFER_BIT );


  for (i = 0; i < M; i++)
    for (j = 0; j < N; ++j) {
      glColor3f((double)w[i][j] /(double)100, 0, 0);
      glRectf(-250 + j, -250 + i, -249+ j, -249 + i);
    }
  glFlush();

}

void myReshape(int w, int h) {

  glViewport(0, 0, (GLsizei)w, (GLsizei)h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-250.0, 250.0, -250.0, 250.0, -2.0, 2.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

}

void motion(int x, int y) {}

void simulacion(){

  if (epsilon <= diff) {

//  escribimos en el grid de escritura
    for (i = 0; i < M; i++)
      for (j = 0; j < N; j++)
        u[i][j] = w[i][j];

    // definimos el nuevo estimado para los puntos interiores, se mueve para todos lados
    diff = 0.0;

    for (i = 1; i < M - 1; i++) {
      for (j = 1; j < N - 1; j++) {
        w[i][j] = (u[i - 1][j] + u[i + 1][j] + u[i][j - 1] + u[i][j + 1]) / 4.0;
        if (diff < fabs(w[i][j] - u[i][j]))
          diff = fabs(w[i][j] - u[i][j]);
      }
    }

    iterations++;


/*
    if (iterations == iterations_print && imprimemela) {
      cout << "  " << setw(8) << iterations << "  " << diff << "\n";
      iterations_print = 2 * iterations_print;
    }*/

  }

  glutPostRedisplay();
}

int main ( int argc, char *argv[] );
double cpu_time ( );

int main ( int argc, char *argv[] ) {
  // Declaracion de variables de tiempo
//  double ctimee;
//  double ctime1;
//  double ctime2;

  //variables para la convergencia del algoritmo

//  ofstream output; //archivo donde se va a guardar
//  char output_filename[10] = "tvt.dat"; //nombre del archivo
  int success; //si se logro o no

  //definimos el tamaño del grid dependiendo de si hay input o no
  if (argc < 4) {
    M = 500;
    N = 500;
    //imprimemela = false;
  }
  else {
    M = atoi(argv[1]);
    N = atoi(argv[2]);
  //  imprimemela = (atoi(argv[3]) == 1) ? 1 : 0; //if one liner )({|})(
  }

  //declaramos los grid



  //cout << " Arepa"<<endl;


/*
  ctime2 = cpu_time();
  ctimee = ctime2 - ctime1;

  cout << "  " << setw(8) << iterations << "  " << diff << endl;
  cout << "  Llegamos al epsilon deseado." << endl;
  cout << "  tiempo de CPU = " << ctimee << endl;

//  Escribimos los resultados en el archivo
  output.open(output_filename);

  output << "Grid: " << M << " * " << N << endl;

  // escritura en output que ira al archivo
  for (i = 0; i < M; i++) {
    for (j = 0; j < N; j++) {
      output << "  " << w[i][j];
    }
    output << "\n";
  }
  output << "  tiempo de CPU = " << ctimee << endl;
  output.close(); //cerramos archivo

  cout << "  No olvidar revisar el archivo " << output_filename << endl;

*/


  glutInit(&argc, argv);
  glutInitDisplayMode( GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH );
  glutInitWindowSize(600, 600);
  glutCreateWindow("Difusion de calor");
  init();
  glutDisplayFunc(display);
  glutReshapeFunc(myReshape);
  glutIdleFunc(simulacion);
  glutMainLoop();

  free(w);
  free(u);
  // Terminose.
  return 0;
}

// funcion para llevar el tiempo
double cpu_time ( )
{
  double value;

  value = ( double ) clock ( ) / ( double ) CLOCKS_PER_SEC;

  return value;
}
