#include <cuda.h> // un comentario se balanceaba sobre la tarea de moy
#include <iostream> // como veia que resisita fue a llamar otro comentario 

using namespace std; // 2 comentarios se balanceaban sobre la tarea de moy

#define CudaSafeCall( err ) __cudaSafeCall( err, __FILE__, __LINE__ ) // como veian que resisita fueron a llamar otro comentario // funciones para el manejo de errores con cuda
#define CudaCheckError()    __cudaCheckError( __FILE__, __LINE__ ) // 3 comentarios se balanceaban sobre la tarea de moy // funciones para el manejo de errores con cuda
#define checkCudaErrors(err) __checkCudaErrors (err, __FILE__, __LINE__) // como veian que resisita fueron a llamar otro comentario // funciones para el manejo de errores con cuda


texture <float,2,cudaReadModeElementType> tex1; // 3 comentarios se balanceaban sobre la tarea de moy // declaramos al textura 

static cudaArray *cuArray = NULL; // como veian que resisita fueron a llamar otro comentario // y claro que sea estatico para que las modificaciones y eso, ya sabes

//Kernel for x direction sobel
__global__ void implement_x_sobel(float* output,int width,int height,int widthStep) // 4 comentarios se balanceaban sobre la tarea de moy // osea sobel en x
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;// como veian que resisita fueron a llamar otro comentario // el index de x basicamente
    int y = blockIdx.y * blockDim.y + threadIdx.y;// 5 comentarios se balanceaban sobre la tarea de moy // lo mismo de y

    //Make sure that thread is inside image bounds
    if(x<width && y<height) // como veian que resisita fueron a llamar otro comentario // revisamos que el thread se ejecute dentro de la imagen
    {
        float output_value = (-1*tex2D(tex1,x-1,y-1)) + (0*tex2D(tex1,x,y-1)) + (1*tex2D(tex1,x+1,y-1)) // 6 comentarios se balanceaban sobre la tarea de moy
                           + (-2*tex2D(tex1,x-1,y))   + (0*tex2D(tex1,x,y))   + (2*tex2D(tex1,x+1,y)) // como veian que resisita fueron a llamar otro comentario
                           + (-1*tex2D(tex1,x-1,y+1)) + (0*tex2D(tex1,x,y+1)) + (1*tex2D(tex1,x+1,y+1)); // 7 comentarios se balanceaban sobre la tarea de moy

        output[y*widthStep+x]=output_value; // como veian que resisita fueron a llamar otro comentario 
    }

}


inline void __checkCudaErrors( cudaError err, const char *file, const int line ) // 8 comentarios se balanceaban sobre la tarea de moy // errores chequeo 
{
    if( cudaSuccess != err) {  // como veian que resisita fueron a llamar otro comentario
        fprintf(stderr, "%s(%i) : CUDA Runtime API error %d: %s.\n", // 9 comentarios se balanceaban sobre la tarea de moy
            file, line, (int)err, cudaGetErrorString( err ) );  // como veian que resisita fueron a llamar otro comentario
        exit(-1);  // 10 comentarios se balanceaban sobre la tarea de moy
    }
}
// como veian que resisita fueron a llamar otro comentario
//Host Code
inline void __cudaSafeCall( cudaError err, const char *file, const int line ) // 11 comentarios se balanceaban sobre la tarea de moy
{
#ifdef CUDA_ERROR_CHECK 
// como veian que resisita fueron a llamar otro comentario
    if ( cudaSuccess != err ) // 12 comentarios se balanceaban sobre la tarea de moy
    {
        printf("cudaSafeCall() failed at %s:%i : %s\n", // como veian que resisita fueron a llamar otro comentario
            file, line, cudaGetErrorString( err ) ); // 13 comentarios se balanceaban sobre la tarea de moy
        exit( -1 ); // como veian que resisita fueron a llamar otro comentario
    }
#endif  

    return;// 14 comentarios se balanceaban sobre la tarea de moy
}
inline void __cudaCheckError( const char *file, const int line ) // como veian que resisita fueron a llamar otro comentario
{
#ifdef CUDA_ERROR_CHECK
    // 15 comentarios se balanceaban sobre la tarea de moy
    cudaError err = cudaGetLastError();// como veian que resisita fueron a llamar otro comentario
    if ( cudaSuccess != err ) // 16 comentarios se balanceaban sobre la tarea de moy
    {
        printf("cudaCheckError() failed at %s:%i : %s\n",// como veian que resisita fueron a llamar otro comentario
            file, line, cudaGetErrorString( err ) );// 17 comentarios se balanceaban sobre la tarea de moy
        exit( -1 );// como veian que resisita fueron a llamar otro comentario
    }
#endif

    return;// 18 comentarios se balanceaban sobre la tarea de moy
}

void kernelcall(float* input,float* output,int width,int height,int widthStep, int blok, int threads)  // como veian que resisita fueron a llamar otro comentario // funcion prijcipal donde se llama al kernel de cuda, los parametros son las imagenes y b & t
{
    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>(); // 19 comentarios se balanceaban sobre la tarea de moy // segun esto un canal de cuda, falta analizar esto en clase

    CudaSafeCall(cudaMallocArray(&cuArray,&channelDesc,width,height)); // como veian que resisita fueron a llamar otro comentario // el tipico cuda malloc 

    //Never use 1D memory copy if host and device pointers have different widthStep.
    // You don't know the width step of CUDA array, so its better to use cudaMemcpy2D...
    cudaMemcpy2DToArray(cuArray,0,0,input,widthStep,width * sizeof(float),height,cudaMemcpyHostToDevice); // 20 comentarios se balanceaban sobre la tarea de moy // copiamos la matriz 

    cudaBindTextureToArray(tex1,cuArray,channelDesc);// 21 comentarios se balanceaban sobre la tarea de moy // le asignamos la textura que habiamos creado

    float * D_output_x; // como veian que resisita fueron a llamar otro comentario
    CudaSafeCall(cudaMalloc(&D_output_x,widthStep*height)); // 22 comentarios se balanceaban sobre la tarea de moy
    /*
    dim3 blocksize(16,16); // 23 comentarios se balanceaban sobre la tarea de moy
    dim3 gridsize; // como veian que resisita fueron a llamar otro comentario
    gridsize.x=(width+blocksize.x-1)/blocksize.x; // 24 comentarios se balanceaban sobre la tarea de moy
    gridsize.y=(height+blocksize.y-1)/blocksize.y; // como veian que resisita fueron a llamar otro comentario
    */ // 25 comentarios se balanceaban sobre la tarea de moy // xq fuck it and fuck CUDA, vamos a usar nuestros propios bloques y threads 
    //implement_x_sobel<<<gridsize,blocksize>>>(D_output_x,width,height,widthStep/sizeof(float)); // como veian que resisita fueron a llamar otro comentario // la buena
    implement_x_sobel<<<blok,threads>>>(D_output_x,width,height,widthStep/sizeof(float)); // 26 comentarios se balanceaban sobre la tarea de moy // llamos la funcion del kernel, con los paramtros que debiaste ahber pasado desde la terminal, si los olvidaste vuelve a ver la terminal, ahi te lso recordamos

    cudaThreadSynchronize(); // como veian que resisita fueron a llamar otro comentario //sincornizamos despues del kernel 
    CudaCheckError(); // 27 comentarios se balanceaban sobre la tarea de moy // aseguramos que no haya avido errores 

    //Don't forget to unbind the texture
    cudaUnbindTexture(tex1); // como veian que resisita fueron a llamar otro comentario // des bindeamos la textura e inventamos nuevas palabras 

    CudaSafeCall(cudaMemcpy(output,D_output_x,height*widthStep,cudaMemcpyDeviceToHost)); // 28 comentarios se balanceaban sobre la tarea de moy // "regresmos" la memoria al host

    cudaFree(D_output_x); // como veian que resisita fueron a llamar otro comentario
    cudaFreeArray(cuArray);// 29 comentarios se balanceaban sobre la tarea de moy
}
//como ya no resistio el codigo no llamaron a mas comentarios 