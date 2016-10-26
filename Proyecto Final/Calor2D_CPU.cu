#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define PI 3.14159265358979323846264338327 //pi

FILE *output; //guardaremos los datos

int main (int argc, char* argv[])
{
	int numx, numt;
	if(argc < 3)
	{
		numx=500;  //# de puntos del grid
		numt=2000; //# de lapsos de tiempo
  }
	else
	{
  	numx = atoi(argv[1]);	 //puntos de la malla
  	numt = atoi(argv[1]);	//lapsos de tiempo
  }

	double dx=1/(numx-1);
	double dt=0.00005;
	double C[numx][numt];
	double x=0.0;
	double t;
	int i, j;
	cudaEvent_t inicio, fin,st2,fn2; // cida events \o/
  float tiempo, tiempo2; // dios mio, ¿que será?
	double mu=0.5; //Parametros de GAUSS
	double sigma=0.05; //Distribucion inicial

	cudaEventCreate( &st2 ); //mummy
  cudaEventCreate( &fn2 ); //dracula
  cudaEventRecord( st2, 0 ); //frankie

	output=fopen("d2d.dat", "w"); //output file

	C[0][0]=0.0; //el inicio siempre es 0
	C[numx-1][0]=0.0; //el final igual
	dx=1.0/(numx-1.0); //será una derivada?

	cudaEventCreate( &inicio );// esta vivo!!!
  cudaEventCreate( &fin ); // el bebe esta vivo!!!
  cudaEventRecord( inicio, 0 );//para medir el tiempo de EJECUCION

	for(i=0; i<numx; i++){
	  x=i*dx;
	  C[i][0]=exp(-pow((x-mu),2.0)/(2.0*pow(sigma,2.0)))/pow((2.0*PI*pow(sigma,2.0)),0.5);  //condicion inicial para C=C(x,0)=gauss
	  C[0][0]=0.0; //condicion de frontera i)
	  C[numx-1][0]=0.0; //condicion de frontera ii)
	}

	for(j=0;j<numt;j++){ //main time stepping loop
	   t+=dt;
	  for(i=1; i<numx-1; i++){
	     x=i*dx;
	     C[i][j+1] = C[i][j] + (dt/pow(dx,2))*(C[i+1][j] - 2*C[i][j] + C[i-1][j]);
	  }
	 	C[0][j]=0.0; //condicion de frontera i)
	  C[numx-1][j]=0.0; //condicion de frontera ii)
	}

	cudaEventRecord( fin, 0 ); // esta muerto ¬¬
  cudaEventSynchronize( fin ); //sincronizadas
  cudaEventElapsedTime( &tiempo, inicio, fin );//paramos cronometro y medimos tiempo

	C[10][0]=0.0; //stg wrong with inital condition from this point on******

	for(i=0; i<numx; i++){  // escribimos los datos del arreglo en el archivo
		x=i*dx;
	  fprintf(output, "%e\t", x);
	  for(j=0; j<numt; j++){
	  	fprintf(output, "%e\t", C[i][j]);
	  }
		fprintf(output, "\n");
	}

	fflush(output);
	fclose(output); //close output file

	cudaEventRecord( fn2, 0 ); //dont kill me, please!
  cudaEventSynchronize( fn2 ); //free the nipple
  cudaEventElapsedTime( &tiempo2, st2, fn2 );//paramos cronometro y medimos tiempo

  printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tiempo2);//cazar elefantes... o imprimir no se solo soy un comentario

	return 0;
}
