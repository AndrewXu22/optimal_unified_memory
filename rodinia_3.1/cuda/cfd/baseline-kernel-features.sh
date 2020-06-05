#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands
TOOL="/usr/local/cuda-10.2/bin/nv-nsight-cu-cli --section-folder /home/ubuntu/optimization_unified_memory/Nsight/sections"

OUTPATH=kernel-level-measurement-2
date
##### Launch parallel job using srun
mkdir -p $OUTPATH

echo 'CFD'

$TOOL -s 3 -c 100  --csv ./GPU-executable/cfd_000 ../../data/cfd/fvcorr.domn.097K > ./$OUTPATH/nsight_cfd_097K.log 
$TOOL -s 3 -c 100  --csv ./GPU-executable/cfd_000 ../../data/cfd/fvcorr.domn.193K > ./$OUTPATH/nsight_cfd_193K.log 
$TOOL -s 3 -c 100  --csv ./GPU-executable/cfd_000 ../../data/cfd/missile.domn.0.2M >./$OUTPATH/nsight_cfd_missile0.2M.log 


echo 'Done'
