#!/bin/bash
# example script to collect several metrics for a cuda program
TOOL="/usr/local/cuda-10.2/bin/nv-nsight-cu-cli --section-folder /home/ubuntu/optimization_unified_memory/Nsight/sections"
#TOOL="nv-nsight-cu-cli"

OUTPATH=kernel-level-measurement
date
##### Launch parallel job using srun
mkdir -p $OUTPATH
echo 'pathfinder'

for r in `seq 100000 100000 500000`;do
for c in `seq 100 100 500`;do
$TOOL  --csv ./GPU-executable/pathfinder_0  $r $c 20  > ./$OUTPATH/nsight_pathfinder_${r}${c}20.log

done
done
echo 'Done'
