#!/bin/bash
mkdir -p ./GPU-executable
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
echo $m $i $j $k
nvcc  -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 euler3d-adapt.cu ../../cuda-adapter/adapter.o -o euler3d_adapt -I/usr/tce/packages/cuda/cuda-9.2.148/samples/common/inc  -L/usr/tce/packages/cuda/cuda-9.2.148/lib64  -I../../cuda-adapter -lnvToolsExt -Dadv1=$i -Dadv2=$j -Dadv3=$k  
mv euler3d_adapt ./GPU-executable/cfd_$m$i$j$k
done    
done    
done    
        
