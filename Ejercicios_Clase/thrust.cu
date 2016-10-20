#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/functional.h>
#include <thrust/sort.h>
#include <thrust/transform.h>
#include <chrono>
#include <algorithm>
#include <vector>

using namespace thrust;
using namespace std;

using sys_clock = std::chrono::system_clock;

void thrust_sequence(){
  thrust::device_vector<int> D_vec(10,1);
  thrust::fill(D_vec.begin(),D_vec.begin() + 7,9);

  thrust::host_vector<int> H_vec(D_vec.begin(),D_vec.begin() +5 );

  thrust::sequence(H_vec.begin(),H_vec.end(),5,2);
  thrust::copy(H_vec.begin(),H_vec.end(),D_vec.begin());
  int i=0;
  for (auto value: D_vec)
    std::cout<< "d[" << i++ << "]" << value << std::endl;
}

void sorts(){
  int current_h =0, current_d =0, exit =0, limit = 1 << 24;
  chrono::time_point<sys_clock> t1,t2;
  chrono::duration<double,milli> exec_time_ms;

  host_vector<int> H_vec(limit);
  thrust::generate(H_vec.begin(),H_vec.end(),rand);
    device_vector<int> D_vec = H_vec;

    t1 = sys_clock::now();
    thrust::sort(D_vec.begin(), D_vec.end());
    t2 = sys_clock::now();
    exec_time_ms = t2-t1;

    cout << "gpu sort time : " << exec_time_ms.count() << endl;
    vector<int> st1_hsot_vec(H_vec.size());
    thrust::copy(H_vec.begin(), H_vec.end(), st1_hsot_vec.begin());

    t1 = sys_clock::now();
    std::sort(st1_hsot_vec.begin(),st1_hsot_vec.end());
    t2 = sys_clock::now();
    exec_time_ms = t2-t1;
    cout<< "CPU time: " << exec_time_ms.count() << endl;
}
struct functor
{
  const float a;
  functor(float _a):a(_a){}
  __host__ __device__ float operator()(const float &x, const float &y)const{return a*x +y;}
};

void transforms(){
  const float A=5;
  const int size = 10;

  host_vector<float> X(size), Y(size);
  sequence(X.begin(),X.end(),10,10);
  sequence(Y.begin(),Y.end(),10,10);

  thrust::transform(X.begin(),X.end(),Y.begin(),Y.end(),functor(A));

  for(int i =0; i < Y.size(); i++){
    cout << "Y[" << i << "]=" << Y[i] << endl;
  }

}



template <typename T>
struct square
{

  __host__ __device__ float operator()(const T &x)const{return x*x;}
};

int main (void){

  float x[4] = {1,2,3,4};

  device_vector<float> D_vec(x,x+4);
  square<float> unary_op;
  thrust::plus<float> binary_op;
  float norm= std::sqrt(
    thrust::transform_reduce(D_vec.begin(),D_vec.end(),unary_op,0,binary_op)
  );

  cout << norm << endl;
  return 0;
}
// nvcc thrust.cu -std=c++11 -D_MWAITXINTRIN_H_INCLUDED
