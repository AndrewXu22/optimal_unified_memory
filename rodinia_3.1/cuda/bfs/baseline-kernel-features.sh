#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands

TOOL="/usr/local/cuda-10.2/bin/nv-nsight-cu-cli --section-folder /home/ubuntu/optimization_unified_memory/Nsight/sections"

OUTPATH=kernel-level-measurement-2
date
##### Launch parallel job using srun
mkdir -p $OUTPATH

echo 'bfs'

$TOOL -s 3 -c 100  --csv ./GPU-executable/bfs_000000 ../../data/bfs/graph1MW_6.txt > ./$OUTPATH/nsight_bfs_graph1MW.6.log 
$TOOL -s 3 -c 100  --csv ./GPU-executable/bfs_000000 ../../data/bfs/graph4096.txt  > ./$OUTPATH/nsight_bfs_graph4096.log 
$TOOL -s 3 -c 100  --csv ./GPU-executable/bfs_000000 ../../data/bfs/graph65536.txt > ./$OUTPATH/nsight_bfs_graph65536.log 


echo 'Done'
