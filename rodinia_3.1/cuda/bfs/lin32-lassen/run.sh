#!/bin/bash
for m in `seq 0 1`;
do
for i in `seq 0 6`;
do
for j in `seq 0 5`;
do
#echo $i $j 
#echo "nvprof --log-file output_$m$i${j}_graph1MW_6.log  ./bfs_$m$i$j ../../../data/bfs/graph1MW_6.txt"
nvprof -u ms --log-file output_$m$i${j}_graph1MW_6.log  ./bfs_$m$i$j ../../../data/bfs/graph1MW_6.txt > /dev/null 2>&1
#echo "nvprof --log-file output_$m$i${j}_graph1MW_6.log  ./bfs_$m$i$j ../../../data/bfs/graph1MW_6.txt"
nvprof -u ms --log-file output_$m$i${j}_graph4096.log  ./bfs_$m$i$j ../../../data/bfs/graph4096.txt > /dev/null 2>&1
#echo "nvprof --log-file output_$m$i${j}_graph1MW_6.log  ./bfs_$m$i$j ../../../data/bfs/graph1MW_6.txt"
nvprof -u ms --log-file output_$m$i${j}_graph65536.log  ./bfs_$m$i$j ../../../data/bfs/graph65536.txt > /dev/null 2>&1

done    
done    
done    
        
