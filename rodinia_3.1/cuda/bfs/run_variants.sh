#!/bin/bash
TOOL=/usr/local/cuda-10.2/bin/nvprof
mkdir kernel-level-measurement/GPU-log
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
#echo "nvprof --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph1MW.6.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph1MW_6.txt"
$TOOL -u ms --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph1MW.6.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph1MW_6.txt > /dev/null 2>&1
#echo "nvprof --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph1MW.6.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph1MW_6.txt"
$TOOL -u ms --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph4096.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph4096.txt > /dev/null 2>&1
#echo "nvprof --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph1MW.6.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph1MW_6.txt"
$TOOL -u ms --log-file ./kernel-level-measurement/GPU-log/output_$i$j$k$l$m${n}_graph65536.log  ./GPU-executable/bfs_$i$j$k$l$m$n ../../data/bfs/graph65536.txt > /dev/null 2>&1
done    
done    
done    
done    
done    
done    
        
