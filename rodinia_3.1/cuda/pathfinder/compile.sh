#!/bin/bash
mkdir -p GPU-executable

for i in `seq 0 6`;
do
echo $i
nvcc pathfinder_adapt.cu ../../cuda-adapter/adapter.o -o pathfinder-adapt -I/usr/tce/packages/cuda/cuda-10.1.243/include -L/usr/local/cuda-10.1/lib -I../../cuda-adapter -Dadv1=$i
mv pathfinder-adapt ./GPU-executable/pathfinder_$i
done    
        
