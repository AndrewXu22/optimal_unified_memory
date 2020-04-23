#!/bin/bash -x

# configure environment based on your machine
INCLUDE_OPT="-I/usr/local/cuda-10.2/samples/common/inc -I../../cuda-adapter"
LINK_FLAGS="-L/usr/local/cuda-10.2/lib64"
BIN_PATH=`hostname`-executable


mkdir -p ./$BIN_PATH

# we wrap two inner loops into a function. Prepare it to be run in background in parallel
inner-loop ()
{
  local i=$1
  for j in `seq 0 6`;
  do
  for k in `seq 0 6`;
  do
  
  echo $m $i $j $k

    
# we may rerun this script, reuse previously generated binary files.
   if [ ! -f ./$BIN_PATH/cfd_$m$i$j$k ] ; then
    
      # -Xptxas: specify options directly to ptxas, the PTX optimizer assembler
      nvcc $INCLUDE_OPT  -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 euler3d-adapt.cu ../../cuda-adapter/adapter.o -o euler3d_adapt $LINK_FLAGS -lnvToolsExt -Dadv1=$i -Dadv2=$j -Dadv3=$k  
      
      if [ $? -ne 0 ]; then      
        echo "Fatal error: nvcc compilation error!"
        exit 1
      fi
      
       if [ ! -f euler3d_adapt ] ; then
           echo "euler3d_adapt does not exist. aborting..."
           exit 1
       fi
      
      if [ ! -d "$BIN_PATH" ]; then
           echo "$BIN_PATHA does not exist. aborting..."
           exit 1
      fi
      
      mv euler3d_adapt ./$BIN_PATH/cfd_$m$i$j$k
    
      fi
  
  done    
  done    
}

# we run each outer loop's iteration in background to have some speedup
for i in `seq 0 6`;
do

inner-loop $i &

done    
