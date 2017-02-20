#pragma once
#include <vector>


class a_mixed_gpu_and_cpu_class {

 public:

  a_mixed_gpu_and_cpu_class() { ; }
  ~a_mixed_gpu_and_cpu_class() { ; }

  // only callable from within gpu kernel context
  __device__ void a_device_function();

  // can only be called from cpu code, but makes
  // cuda api calls which alter gpu state
  __host__   void a_host_function();

  // callable from CPU, only affects cpu code
  unsigned int a_normal_cpu_method() const { return 0; }

};

// a forward declared cuda kernel
__global__ void some_kernel (double* data);
