#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <thrust/copy.h>
#include <thrust/functional.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/sequence.h>

#include <iostream>
#include <cstdlib>
#include <ctime>
#include <chrono>

using namespace std;
using sys_clock = std::chrono::system_clock;

/// used to fill a host vector
struct rand_functor
{
	int mod = 0;
	rand_functor(int _mod = 0) : mod(_mod) { std::srand(std::time(0)); }

	template<typename T>
	void operator()(T &var)
	{
		if(mod > 0)
			var = std::rand() % mod;
		else
			var = std::rand();
	}
};

struct matrix_mult
{
	/// Fill the structure
  int *data;

  matrix_mult(int* _data) : data(_data){}

  template<typename Tuple>
  __host__ __device__
  void operator()(Tuple t){
    thrust::get<2>(t) = thrust::get<0>(t) * thrust::get<1>(t) + data[thrust::get<2>(t)];
  }
};

void cpu_matrix_mult(float *A, float *B, float *C, int row_size, int col_size)
{
	/// CPU matrix mult
  for (int i=0; i<row_size; i++)
    for (int j=0; j<col_size; j++)
      for (int k=0; k<col_size; k++)
        C[i*(col_size)+j] += A[i*(col_size)+k] * B[k*(row_size)+j];
}

void print_matrix(float *A, int row_size, int col_size)
{
	std::cout << "\n";
	for(int i = 0; i < row_size; i++)
	{
		for(int j = 0; j <col_size; j++)
		{
			std::cout << A[i * col_size + j] << " ";
		}
		std::cout << "\n";
	}
}

void thrust_matrix_mult(const int row_size, const int col_size)
{
	const int matrix_size = col_size * row_size;

	std::chrono::time_point<sys_clock> t1, t2;
	std::chrono::duration<double, std::milli> exec_time_ms;

	/// These are for the CPU matrix mult
	float *A = (float*)malloc(sizeof(float) * matrix_size);
	float *B = (float*)malloc(sizeof(float) * matrix_size);
	float *C = (float*)malloc(sizeof(float) * matrix_size);

	/// Vectors for the thrust matrix mult
	thrust::host_vector<float> result(matrix_size);
	thrust::host_vector<float> matrix_hA(matrix_size), matrix_hB(matrix_size);
	thrust::device_vector<float> matrix_A(matrix_size), matrix_B(matrix_size), matrix_C(matrix_size, 0.0f);
  thrust::device_vector<int> ids(matrix_size);
  thrust::device_vector<int> data(matrix_size);

	/// Additional variables you may need
  thrust::sequence(data.begin(),data.end());
  thrust::sequence(ids.begin(),ids.end());
	thrust::for_each(matrix_hA.begin(), matrix_hA.end(), rand_functor(10));
	thrust::for_each(matrix_hB.begin(), matrix_hB.end(), rand_functor(10));

	matrix_A = matrix_hA;
	matrix_B = matrix_hB;

	thrust::copy(matrix_A.begin(), matrix_A.end(), A);
	thrust::copy(matrix_B.begin(), matrix_B.end(), B);

	t1 = sys_clock::now();
	cpu_matrix_mult(A, B, C, row_size, col_size);
	t2 = sys_clock::now();

	exec_time_ms = t2 - t1;

	std::cout << "CPU mm time: " << exec_time_ms.count() << "ms\n";

	t1 = sys_clock::now();

	/// Thrust code!
  thrust::for_each(
    thrust::make_zip_iterator(thrust::make_tuple(matrix_A.begin(),matrix_B.begin(),ids.begin(),matrix_C.begin())),
    thrust::make_zip_iterator(thrust::make_tuple(matrix_A.end(),matrix_B.end(),ids.end(),matrix_C.end())),
    matrix_mult(thrust::raw_pointer_cast(data.data()))
  );

	result = matrix_C;
	t2 = sys_clock::now();

	exec_time_ms = t2 - t1;
	std::cout << "Thrust GPU mm time: " << exec_time_ms.count() << "ms\n";

  bool ora = true;

	std::cout << "\nChecking Matrices" << std::endl;
  // Compare matrices (CPU & thrust) for correctness aja
  for(int preguntame = 0; preguntame < col_size; preguntame++)
    if(C[preguntame] == result[preguntame])
      continue;
    else
      ora=false;

  if(ora) cout << "Iguales" << endl;
  else cout << "NOT equal" << endl;
}

int main(int argc, char* argv[])
{
	if (argc < 2)
		thrust_matrix_mult(50, 50);
	else
		thrust_matrix_mult(atoi(argv[1]), atoi(argv[1]));
	return 0;
}
