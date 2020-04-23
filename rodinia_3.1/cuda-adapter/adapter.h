#ifndef ADAPTER_H
#define ADAPTER_H

#include "cuda.h"
#include "cuda_runtime.h"
#ifdef __cplusplus
extern "C" {
#endif
#include <stdio.h> 
#include <stdlib.h> 
#include <stddef.h>

  typedef enum {CPU, GPU, Managed} alloc_type;
  struct adapterNode{
    void* ptr;
    struct adapterNode* next;
  }; 
  int isAllocated(void* p);   
  void removeAllocated(int i, void* p);

  void* xplacer_malloc(size_t s, alloc_type t);
  void xplacer_free(void* p, alloc_type t);
  cudaError_t xplacer_memcpy(void** dst, void* src, size_t count, cudaMemcpyKind kind, bool isUnified);
  void xplacer_cudaMemAdvise(char* data, int size, int policy);
  

#ifdef __cplusplus
};
#endif /* __cplusplus */

#endif /* ADAPTER_H */
