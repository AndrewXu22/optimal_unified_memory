include ../../common/make.config
ADAPTERPATH = ../../cuda-adapter
#CUDA_PATH = /usr/local/cuda
CUDA_PATH = ${CUDA_HOME}


# Determine the correct version of the cutil library
CUTIL_LIB = # -lcutil
ifeq ($(shell uname -m), x86_64)
     ifeq ($(shell if test -e $(CUDA_PATH)/lib64/libcutil_x86_64.a; then echo T; else echo F; fi), T)
        CUTIL_LIB = #-lcutil_x86_64
     endif
endif


all: euler3d_adapt euler3d euler3d_double  pre_euler3d  pre_euler3d_double 

$(ADAPTERPATH)/adapter.o:
	cd $(ADAPTERPATH); make

euler3d_adapt: euler3d-adapt.cu $(ADAPTERPATH)/adapter.o
	nvcc $(KERNEL_DIM) -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 $< $(ADAPTERPATH)/adapter.o -o $@ -I$(CUDA_PATH)/samples/common/inc  -L$(CUDA_PATH)/lib64 $(CUTIL_LIB) -I$(ADAPTERPATH) -lnvToolsExt

euler3d: euler3d-orig.cu
	nvcc $(KERNEL_DIM) -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 $< -o $@ -I$(CUDA_PATH)/samples/common/inc  -L$(CUDA_PATH)/lib64 $(CUTIL_LIB)

euler3d_double: euler3d_double.cu
	nvcc -Xptxas -v -O3 --gpu-architecture=compute_70 --gpu-code=compute_70 $< -o $@ -I$(CUDA_PATH)/samples/common/inc  -L$(CUDA_PATH)/lib64 $(CUTIL_LIB)


pre_euler3d: pre_euler3d.cu
	nvcc -Xptxas -v -O3 --gpu-architecture=compute_70 --gpu-code=compute_70 $< -o $@ -I$(CUDA_PATH)/samples/common/inc  -L$(CUDA_PATH)/lib64 $(CUTIL_LIB)

pre_euler3d_double: pre_euler3d_double.cu
	nvcc -Xptxas -v -O3 --gpu-architecture=compute_70 --gpu-code=compute_70 $< -o $@ -I$(CUDA_PATH)/samples/common/inc  -L$(CUDA_PATH)/lib64 $(CUTIL_LIB)


clean:
	rm -f euler3d_adapt euler3d euler3d_double pre_euler3d pre_euler3d_double *.linkinfo
