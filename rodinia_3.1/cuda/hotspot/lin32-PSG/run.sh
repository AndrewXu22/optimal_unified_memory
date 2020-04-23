#!/bin/bash
for size in 64 128 256 512 1024 2048 4096 8192 16384 
do
for m in `seq 0 1`;
do
for i in `seq 0 5`;
do
for j in `seq 0 5`;
do
#echo $i $j $size
#echo "nvprof --log-file output_$m$i${j}_${size}.log ./hotspot_$m$i$j  $size 2 2 ../../../data/hotspot/temp_$size ../../../data/hotspot/power_${size} output-adapt.out"
nvprof -u ms --log-file output_$m$i${j}_${size}.log ./hotspot_$m$i$j  $size 2 2 ../../../data/hotspot/temp_$size ../../../data/hotspot/power_${size} output-adapt.out > /dev/null 2>&1
done    
done    
done    
done    
