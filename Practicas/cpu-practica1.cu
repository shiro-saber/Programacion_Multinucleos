#include <stdio.h>
#include <math.h>

// Algoritmo Criba de Eratóstenes
void primos(unsigned long max)
{
   unsigned long i, j, c=0;
   max++;
   char *arr = new char[max];
   cudaEvent_t inicio, fin;
   float tiempo;

   cudaEventCreate( &inicio );
   cudaEventCreate( &fin );
   cudaEventRecord( inicio, 0 );

   if (max >= 2)
   {
      for (i=0; i<max; i++)
         arr[i] = 0;
      arr[0] = 1;
      arr[1] = 1;

      unsigned long raiz = sqrt(max);

      for (j=4; j<max; j+=2)
         arr[j] = 1;

      for (i=3; i<=raiz; i+=2) // impares
         if (arr[i] == 0)
            for (j=i*i; j<max; j+=i)
               arr[j] = 1;

      cudaEventRecord( fin, 0 );
      cudaEventSynchronize( fin );
      cudaEventElapsedTime( &tiempo, inicio, fin );

      for (i=0; i<max; i++)
         if (arr[i] == 0)
         {
//            printf("%ld ", i);
            c++;
         }
      printf("\n total:%ld\n", c);
   }
   free(arr);
   printf("tiempo total en ms: %f\n", tiempo);
}

int main(int argc, char *argv[])
{
   primos(100000000);
   return 1;
}
