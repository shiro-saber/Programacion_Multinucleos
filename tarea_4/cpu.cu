#include<iostream>
#include"stdio.h"
#include<cmath>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/highgui/highgui.hpp>
 
using namespace std; //un comentario para algo que hacemos siempre
using namespace cv; //si, este es para incluir el namespace cv de opencv
  
/* Saca el gradiente de x, en el punto dado en la direccion de x*/
int xGradient(Mat image, int x, int y)
{
  return image.at<uchar>(y-1, x-1) + 
         2*image.at<uchar>(y, x-1) + 
         image.at<uchar>(y+1, x-1) - 
         image.at<uchar>(y-1, x+1) - 
         2*image.at<uchar>(y, x+1) - 
         image.at<uchar>(y+1, x+1); // return gigantezco de las operaciones que se ejecutan
}
    
/* lo mismo del de arriba pero ahora cambia las x por y */
int yGradient(Mat image, int x, int y)
{
  return image.at<uchar>(y-1, x-1) +
         2*image.at<uchar>(y-1, x) +
         image.at<uchar>(y-1, x+1) -
         image.at<uchar>(y+1, x-1) -
         2*image.at<uchar>(y+1, x) -
         image.at<uchar>(y+1, x+1);// mismo return gigantezco que se veia feo en una linea
}
      
int main() //¿qué será esto?
{
  Mat src, src2, dst; //pos las imágenes
  int gx, gy, sum; // dejare un comentario en esta declaracion
  cudaEvent_t inicio, fin,st2,fn2; // cida events \o/
  float tiempo, tiempo2; // dios mio, ¿que será?
                      
  // Carguemos la imagen
  src = imread("salon.jpeg", CV_LOAD_IMAGE_GRAYSCALE); // es más fácil hacerlo asi
  src2 = imread("salon.jpeg", CV_LOAD_IMAGE_COLOR); // pos necesitas mostrarla en algún momento no?
  dst = src.clone(); //hagamos un clon
  
  cudaEventCreate( &st2 ); //mummy
  cudaEventCreate( &fn2 ); //dracula
  cudaEventRecord( st2, 0 ); //frankie

  if( !src.data ) return -1; // no manches, pasame algo
                                                                                                        
  for(int y = 0; y < src.rows; y++) //recorramos las filas
    for(int x = 0; x < src.cols; x++) //recorramos las columnas
      dst.at<uchar>(y,x) = 0.0; //punto inicial
  
  cudaEventCreate( &inicio );// esta vivo!!!
  cudaEventCreate( &fin ); // el bebe esta vivo!!!
  cudaEventRecord( inicio, 0 );//para medir el tiempo de EJECUCION

  for(int y = 1; y < src.rows - 1; y++){
    for(int x = 1; x < src.cols - 1; x++){
      gx = xGradient(src, x, y); //dame el gradiente x
      gy = yGradient(src, x, y); //dame el gradiente y
      sum = abs(gx) + abs(gy); //suma que pues tenía que hacer
      sum = sum > 255 ? 255:sum; //ahora si la suma es mayor a 255 cierralo en 255 si no pues dejalo en paz
      sum = sum < 0 ? 0 : sum; // y que tal si es menor a 0 pos no te vas a los negativos
      dst.at<uchar>(y,x) = sum; // y vamos pasando los puntos.
    }
  }
  cudaEventRecord( fin, 0 ); // esta muerto ¬¬
  cudaEventSynchronize( fin ); //sincronizadas
  cudaEventElapsedTime( &tiempo, inicio, fin );//paramos cronometro y medimos tiempo

                                                                                                                                                        
  namedWindow("final"); // hagamos un muñeco, digo una ventana
  imshow("final", dst); // print a la imagen generada 
                                                                                                                    
  namedWindow("initial"); //ya me puedo ir? 
  imshow("initial", src2); //neta lo tengo que comentar otra vez?
  
  cudaEventRecord( fn2, 0 ); //dont kill me, please!
  cudaEventSynchronize( fn2 ); //free the nipple
  cudaEventElapsedTime( &tiempo2, st2, fn2 );//paramos cronometro y medimos tiempo
  
  printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tiempo2);//cazar elefantes... o imprimir no se solo soy un comentario

  waitKey(); //no se si esto es demasiado obvio para comentarlo
          
  return 0; // y yo? que hago aqui?
}
