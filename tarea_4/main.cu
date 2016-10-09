#include <iostream>
#include <opencv2/opencv.hpp>
#include <stdio.h>
#include "cudaKernel.cu"

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
    cudaEvent_t inicio, fin,st2,fn2;
    float tiempo, tt2;
    
    cudaEventCreate( &st2 );
    cudaEventCreate( &fn2 );
    cudaEventRecord( st2, 0 );

    IplImage* image;
    IplImage* sharmuta;

    image = cvLoadImage("salon.jpeg", CV_LOAD_IMAGE_GRAYSCALE);
    sharmuta = cvLoadImage("salon.jpeg", CV_LOAD_IMAGE_COLOR);

    if(!image )
    {
        cout << "Could not open or find the image" << std::endl;
        return -1;
    }


    IplImage* image2 = cvCreateImage(cvGetSize(image),IPL_DEPTH_32F,image->nChannels);
    IplImage* image3 = cvCreateImage(cvGetSize(image),IPL_DEPTH_32F,image->nChannels);

    //Convert the input image to float
    cvConvert(image,image3);

    float *output = (float*)image2->imageData;
    float *input =  (float*)image3->imageData;
    
    cudaEventCreate( &inicio );
    cudaEventCreate( &fin );
    cudaEventRecord( inicio, 0 );//para medir el tiempo de EJECUCION

    kernelcall(input, output, image->width,image->height, image3->widthStep);
    
    cudaEventRecord( fin, 0 );
    cudaEventSynchronize( fin );
    cudaEventElapsedTime( &tiempo, inicio, fin );//paramos cronometro y medimos tiempo

    //Normalize the output values from 0.0 to 1.0
    cvScale(image2,image2,1.0/255.0);

    cvShowImage("Original Image", sharmuta );
    cvShowImage("Sobeled Image", image2);
    
    cudaEventRecord( fn2, 0 );
    cudaEventSynchronize( fn2 );
    cudaEventElapsedTime( &tt2, st2, fn2 );//paramos cronometro y medimos tiempo
    printf("tiempo calculos en ms: %f\t tiempo de total %f\n", tiempo,tt2);//cazar elefantes... o imprimir no se solo soy un comentario

    return 0;
}


    cvWaitKey(0);
    
    return 0;
}
