#!/bin/bash
#TOOL=/usr/local/cuda-10.2/bin/nvprof
TOOL=nvprof
mkdir kernel-level-measurement/GPU-log
for i in `seq 0 6`;
do
for r in `seq 100000 100000 500000`;do
for c in `seq 100 100 500`;do
echo $i $r $c 
$TOOL -u ms --log-file ./kernel-level-measurement/GPU-log/output_${i}_${r}${c}20.log ./GPU-executable/pathfinder_$i  $r $c 20 > /dev/null 2>&1
done    
done    
done    
