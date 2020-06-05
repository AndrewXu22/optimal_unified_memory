#!/bin/bash
# i,j,k,l,m,n represents 6 arrays used in BFS
# each has 7 memory advises  
mkdir -p ./GPU-executable
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
for l in `seq 0 6`;
do
for m in `seq 0 0`;
do
for n in `seq 0 0`;
do
echo $i $j $k $l $m $n
nvcc -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 bfs_adapt.cu ../../cuda-adapter/adapter.o -o bfs_adapt -I/cm/extra/apps/CUDA.linux86-64/10.1.150_418.39/include -L/usr/local/cuda-10.1/lib -I../../cuda-adapter  -Dadv1=$i -Dadv2=$j -Dadv3=$k -Dadv4=$l -Dadv5=$m -Dadv6=$n
mv bfs_adapt ./GPU-executable/bfs_$i$j$k$l$m$n
done    
done    
done    
done    
done    
done    
        
