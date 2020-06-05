#!/bin/bash
TOOL=/usr/local/cuda-10.2/bin/nvprof
mkdir kernel-level-measurement/GPU-log
for size in 64 128 256 512 1024 2048 4096 8192  
do
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
echo $i $j $size
#echo "nvprof --log-file ./kernel-level-measurement/GPU-log/output_$i${j}_${size}.log ./GPU-executable/hotspot_$i$j  $size 2 2 ../../data/hotspot/temp_$size ../../data/hotspot/power_${size} output-adapt.out"
$TOOL -u ms --log-file ./kernel-level-measurement/GPU-log/output_$i${j}_${size}.log ./GPU-executable/hotspot_$i$j  $size 2 2 ../../data/hotspot/temp_$size ../../data/hotspot/power_${size} output-adapt.out > /dev/null 2>&1
done    
done    
done    
