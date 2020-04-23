include ../../common/make.config
ADAPTERPATH = ../../cuda-adapter

CC := $(CUDA_HOME)/bin/nvcc
INCLUDE := $(CUDA_HOME)/include

SRC = pathfinder.cu
SRCADAPT = pathfinder_adapt.cu

EXE = pathfinder
EXEADAPT = pathfinder_adapt

all: release adapt

adapt:
	$(CC) $(SRC) $(ADAPTERPATH)/adapter.o -o $(EXEADAPT) -I$(INCLUDE) -L$(CUDA_LIB_DIR) -I$(ADAPTERPATH) 

release:
	$(CC) $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

enum:
	$(CC) -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$$(CUDA_LIB_DIR) 

debug:
	$(CC) -g $(SRC) -o $(EXE) -I$(INCLUDE) -L$$(CUDA_LIB_DIR) 

debugenum:
	$(CC) -g -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

clean:
	rm -f pathfinder
