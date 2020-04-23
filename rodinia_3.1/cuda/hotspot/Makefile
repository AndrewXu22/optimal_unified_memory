include ../../common/make.config
ADAPTERPATH = ../../cuda-adapter
CUDA_DIR := ${CUDA_HOME}
CUDA_LIB_DIR := $(CUDA_DIR)/lib64

CC := $(CUDA_DIR)/bin/nvcc

INCLUDE := $(CUDA_DIR)/include

SRC = hotspot.cu
SRC_ADAPT = hotspot-adapt.cu

EXE = hotspot
EXE_ADAPT = hotspot-adapt

all: release release_adapt

$(ADAPTERPATH)/adapter.o:
	cd $(ADAPTERPATH); make

release_adapt: $(SRC_ADAPT) $(ADAPTERPATH)/adapter.o
	$(CC) $(KERNEL_DIM) $(SRC_ADAPT) $(ADAPTERPATH)/adapter.o -o $(EXE_ADAPT) -I$(INCLUDE) -I$(ADAPTERPATH) -L$(CUDA_LIB_DIR)  

release: $(SRC)
	$(CC) $(KERNEL_DIM) $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

enum: $(SRC)
	$(CC) $(KERNEL_DIM) -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debug: $(SRC)
	$(CC) $(KERNEL_DIM) -g $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debugenum: $(SRC)
	$(CC) $(KERNEL_DIM) -g -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

clean: $(SRC)
	rm -f $(EXE) $(EXE).linkinfo result.txt
