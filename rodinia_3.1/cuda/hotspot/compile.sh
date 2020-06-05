#!/bin/bash
mkdir -p GPU-executable

for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
echo $m $i $j
nvcc  hotspot-adapt.cu ../../cuda-adapter/adapter.o -o hotspot-adapt -I/cm/extra/apps/CUDA.linux86-64/10.1.150_418.39/include -I../../cuda-adapter -L/cm/extra/apps/CUDA.linux86-64/10.1.150_418.39/lib64 -Dadv1=$i -Dadv2=$j 
mv hotspot-adapt ./GPU-executable/hotspot_$m$i$j$k
done    
done    
        
