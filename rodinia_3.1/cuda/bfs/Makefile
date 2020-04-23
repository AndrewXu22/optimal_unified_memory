include ../../common/make.config

CC := ${CUDA_HOME}/bin/nvcc

ADAPTERPATH = ../../cuda-adapter
INCLUDE :=${CUDA_HOME}/include

SRC = bfs.cu
SRCADP = bfs_adapt.cu

EXE = bfs
EXEADP = bfs_adapt

all: release adapt

$(ADAPTERPATH)/adapter.o:
	cd $(ADAPTERPATH); make

adapt: $(SRC) $(ADAPTERPATH)/adapter.o
	$(CC) $(SRCADP) $(ADAPTERPATH)/adapter.o -o $(EXEADP) -I$(INCLUDE) -L$(CUDA_LIB_DIR) -I$(ADAPTERPATH) 

release: $(SRC)
	$(CC) $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

enum: $(SRC)
	$(CC) -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debug: $(SRC)
	$(CC) -g $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

debugenum: $(SRC)
	$(CC) -g -deviceemu $(SRC) -o $(EXE) -I$(INCLUDE) -L$(CUDA_LIB_DIR) 

clean: $(SRC)
	rm -f $(EXE) $(EXE).linkinfo result.txt $(EXEADP)
