#!/bin/bash
for m in `seq 0 1`;
do
for i in `seq 0 6`;
do
echo $i $j 
nvcc -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 pathfinder_adapt.cu ../../cuda-adapter/adapter.o -o pathfinder_adapt -I/cm/extra/apps/CUDA.linux86-64/10.1.150_418.39/include -L/usr/local/cuda-10.1/lib -I../../cuda-adapter  -Dadvdata=$i -DmemLoc=$m 
mv pathfinder_adapt ./lin32-lassen/pathfinder_$m$i
done    
done    
        
