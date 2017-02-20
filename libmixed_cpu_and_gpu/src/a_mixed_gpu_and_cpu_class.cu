#include "a_mixed_gpu_and_cpu_class.hh"

#include <iostream>

__device__ void a_mixed_gpu_and_cpu_class::a_device_function() {
  float x = 0;
  x += 1;
  printf("%d\n",x);
}


__host__   void a_mixed_gpu_and_cpu_class::a_host_function() {
  float* gpu_mem;
  cudaMalloc((void**)&gpu_mem,10*sizeof(float));
  cudaFree(gpu_mem);
}


__global__ void some_kernel (double* data) {
  data[0]*=10.0;
}
