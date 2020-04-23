#include "adapter.h"

int numAllocated = 0;
adapterNode* head = NULL;
adapterNode* tail = NULL;


int isAllocated(void* p) 
{
    int i = 0;
    struct adapterNode* tmp = head; 
    while (tmp != NULL) {
    //printf("%d %d is %p %p ?\n",numAllocated,i,tmp->ptr,p);
        if(tmp->ptr == p)
          return i+1; 
        tmp = tmp->next; 
        i++;
    }
    return 0; 
} 

void removeAllocated(int idx, void* p)
{
    cudaFree((void*)p);
    struct adapterNode* tmp1 = head; 
    if(idx == 0)
    {
printf("removing %d %d\n",idx,numAllocated);
      if(numAllocated > 1)
        head = head->next;
      free(tmp1);
      return;
    }
    struct adapterNode* tmp2 = head->next; 
    for(int i = 0; i < idx-1; i++)
    {
      tmp2 = tmp2->next;
      tmp1 = tmp2;
    }
    tmp1->next = tmp2->next;
    tmp2->next = NULL;
    free(tmp2);
    return;
}

void* xplacer_malloc(size_t s, alloc_type t)
{
  void *p;
  switch(t)
  {
    case CPU:
      p = malloc(s);
      break;
    case GPU:
      cudaMalloc((void**)&p, s);
      break;
    case Managed:
      cudaMallocManaged((void**)&p, s);
      numAllocated++;
      struct adapterNode* newNode = (struct adapterNode*)malloc(sizeof(struct adapterNode)); 
      newNode->ptr = p;
      newNode->next = NULL;
      if(numAllocated == 1)
      {
        head = newNode;
        tail = head; 
      }
      else
      {
        tail->next = newNode;
        tail = newNode;
      }  
      printf("Number of allocated Data = %d\n",numAllocated);
      printf("in api range: %p %p\n",(char*)p,(char*)p+s);
      break;
  }
  return p;
}

void xplacer_free(void* p, alloc_type t)
{
  switch(t)
  {
    case CPU:
      free(p);
      break;
    case GPU:
    case Managed:
    int i = isAllocated(p);
//printf("Removing %dth\n",i);
      if(i != 0)
      {
        removeAllocated(i-1,p); 
        numAllocated--;
        //printf("one deallocated # of allocated Data = %d\n",numAllocated);
      }
      else
        cudaFree((void*)p);
      break;
  }
}

cudaError_t xplacer_memcpy(void** dst,  void* src, size_t count, cudaMemcpyKind kind, bool isUnified)
{
  cudaError_t ret = cudaSuccess;
  if(isUnified)
  {
    if(*dst != src)
      *dst = src;
    //printf("adapter copy:dst = %p src = %p\n",*dst,src);
  }
  else
  {
    //printf("adapter cudaMemcpy:dst = %p src = %p\n",*dst,src);
    ret = cudaMemcpy(*dst, const_cast<void*>(src), count, kind);
  }
  return ret;
}

void xplacer_cudaMemAdvise(const void* data, size_t size, int policy)
{
  switch (policy)
  {
    case 1:
        cudaMemAdvise(data, size, cudaMemAdviseSetReadMostly, 1);
        break;
    case 2:
        cudaMemAdvise(data, size, cudaMemAdviseSetPreferredLocation, 1);
        break;
    case 3:
        cudaMemAdvise(data, size, cudaMemAdviseSetAccessedBy, 1);
        break;
  }
}
