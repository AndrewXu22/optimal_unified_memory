#!/bin/bash
mkdir kernel-level-measurement/lassen-log
for size in 64 128 256 512 1024 2048 4096 8192  
do
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
echo $i $j $size
#echo "nvprof --log-file ./kernel-level-measurement/lassen-log/output_$i${j}_${size}.log ./lassen-executable/hotspot_$i$j  $size 2 2 ../../data/hotspot/temp_$size ../../data/hotspot/power_${size} output-adapt.out"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i${j}_${size}.log ./lassen-executable/hotspot_$i$j  $size 2 2 ../../data/hotspot/temp_$size ../../data/hotspot/power_${size} output-adapt.out > /dev/null 2>&1
done    
done    
done    
