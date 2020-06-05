#!/bin/bash
mkdir -p ./GPU-executable
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
echo $m $i $j $k
nvcc  -O2 -Xptxas -v --gpu-architecture=compute_70 --gpu-code=compute_70 gaussian_adapt.cu ../../cuda-adapter/adapter.o -o gaussian_adapt -I/cm/extra/apps/CUDA.linux86-64/10.1.150_418.39/include -L/usr/local/cuda-10.1/lib  -I../../cuda-adapter -Dadv1=$i -Dadv2=$j -Dadv3=$k 
mv gaussian_adapt .//GPU-executable/gaussian_$i$j$k
done    
done    
done    
