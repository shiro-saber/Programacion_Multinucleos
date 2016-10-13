#include <iostream> //ionput output party
#include <opencv2/opencv.hpp> // si dice open cv seguro que son las librerias para hacer operaciones matematicas
#include <stdio.h> // o cielos no era estudio?????
#include "cudaKernel.cu" // MWUWHAHAHAHA vas a tener que revisar otro archivo // que tiene mas comentarios ya sabes por linea

using namespace cv; //si, este es para incluir el namespace cv de opencv
using namespace std; // namespace de Solos Traumados y Dolidos 

int main(int argc, char** argv) //estoy seguro que he visto esto antes epro aun no se que es... tal vez cubells lo sepa
{
    cudaEvent_t inicio, fin,st2,fn2; // eventos de cuda??? espero me invviten 
    float tiempo, tt2; // tiempo y mas tiempo = tiempo^2

    int blok, threads; // bloques para contruir y threads para tejer 
    blok = atoi(argv[1]); // الله أكبر
    threads = atoi(argv[2]); // en serio lees todos estos comentarios obvios????

    cout << "bloques: " << blok << "\tthreads: "<< threads << endl; // por si tienes alts heimer y se te olvido cuantos threads y bloques pussite aqui te lo recordamos

    cudaEventCreate( &st2 );// sera mi invitacion apra ir al evento de CUDA?
    cudaEventCreate( &fn2 ); // si si es!!
    cudaEventRecord( st2, 0 ); // que empieze al fiesta 

    IplImage* image; // hmmm... elefantes??
    IplImage* sharmuta;// sip elefantes

    image = cvLoadImage("salon.jpeg", CV_LOAD_IMAGE_GRAYSCALE); // elefantes normales (osea grises) 
    sharmuta = cvLoadImage("salon.jpeg", CV_LOAD_IMAGE_COLOR); // elefantes coloridos (osea estas en drogas)

    if(!image ) // osea que borraste la imgen genio
    {
        cout << "Could not open or find the image" << std::endl; // se kago todo 
        return -1; // :'( 
    }


    IplImage* image2 = cvCreateImage(cvGetSize(image),IPL_DEPTH_32F,image->nChannels); // pues casteamso nuestros elefantes a matrices 
    IplImage* image3 = cvCreateImage(cvGetSize(image),IPL_DEPTH_32F,image->nChannels); // la misma cosa 

    //Convert the input image to float
    cvConvert(image,image3);// tarduccion: que lo convertimos a float 

    float *output = (float*)image2->imageData; // umm si creo que ya lo dije no?
    float *input =  (float*)image3->imageData; // deberias poner mas atencion a los comentarios que pongo 
    
    cudaEventCreate( &inicio ); // ViVa La pArI LoKa
    cudaEventCreate( &fin ); // todo lo bueno tiene un final... pero esto es el principio del fin. o eso es lo que ahi dice
    cudaEventRecord( inicio, 0 );//para medir el tiempo de EJECUCION

    // llamemos al kernel 
    kernelcall(input, output, image->width,image->height, image3->widthStep, blok,threads); // como la unica funcion que importa en todo el codigo
    
    cudaEventRecord( fin, 0 );// se acabo 
    cudaEventSynchronize( fin ); // wiiiiiiiii
    cudaEventElapsedTime( &tiempo, inicio, fin );//paramos cronometro y medimos tiempo
    //un comentario mas porque puedo

    //Normalize the output values from 0.0 to 1.0
    cvScale(image2,image2,1.0/255.0); // re escalamos los valores
    //para que s epuedan imprimir o algo asi 

    cvShowImage("Original Image //xq hay que ocmentar hasta ne las ventanas de display", sharmuta );// te la enseño 
    cvShowImage("Sobeled Image //osea sobeleada", image2);// la imagen!!! 
    
    cudaEventRecord( fn2, 0 ); // no se que poner 
    cudaEventSynchronize( fn2 );// asi que pongo lo que es. sincronizamos eventos 
    cudaEventElapsedTime( &tt2, st2, fn2 );//paramos cronometro y medimos tiempo
    printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tt2);//cazar elefantes... o imprimir no se solo soy un comentario


    cvWaitKey(0);// 我々は、任意のキーを押して、ユーザを待ちます
    
    return 0; // que malo no devuelves nada 
}
