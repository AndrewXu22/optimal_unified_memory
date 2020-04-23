include ../../common/make.config
ADAPTERPATH = ../../cuda-adapter


CC := $(CUDA_HOME)/bin/nvcc

INCLUDE := $(CUDA_HOME)/include

SRC = gaussian.cu
SRCADAPT = gaussian_adapt.cu
EXE = gaussian
EXEADAPT = gaussian_adapt

all: release adapt

$(ADAPTERPATH)/adapter.o:
	cd $(ADAPTERPATH); make

adapt: $(SRCADAPT) $(ADAPTERPATH)/adapter.o
	$(CC) $(KERNEL_DIM) $< $(ADAPTERPATH)/adapter.o -o $(EXEADAPT) -I$(INCLUDE) -L$(CUDA_LIB_DIR)  -I$(ADAPTERPATH) 

release: $(SRC)
	$(CC) $(KERNEL_DIM) $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR)  

clean:
	rm gaussian
