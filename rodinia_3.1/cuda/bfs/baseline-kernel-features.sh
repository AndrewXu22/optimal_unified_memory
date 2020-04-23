#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands


date
##### Launch parallel job using srun
mkdir -p kernel-level-measurement

echo 'bfs'

nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/bfs_000000 ../../data/bfs/graph1MW_6.txt > ./kernel-level-measurement/nsight_bfs_graph1MW.6.log 
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/bfs_000000 ../../data/bfs/graph4096.txt > ./kernel-level-measurement/nsight_bfs_graph4096.log 
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/bfs_000000 ../../data/bfs/graph65536.txt > ./kernel-level-measurement/nsight_bfs_graph65536.log 


echo 'Done'
