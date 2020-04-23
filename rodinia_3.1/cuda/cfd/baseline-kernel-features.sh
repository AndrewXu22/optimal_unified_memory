#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands


date
##### Launch parallel job using srun
mkdir -p kernel-level-measurement

echo 'CFD'

nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/cfd_000 ../../data/cfd/fvcorr.domn.097K > ./kernel-level-measurement/nsight_cfd_097K.log 
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/cfd_000 ../../data/cfd/fvcorr.domn.193K > ./kernel-level-measurement/nsight_cfd_193K.log 
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/cfd_000 ../../data/cfd/missile.domn.0.2M > ./kernel-level-measurement/nsight_cfd_missile0.2M.log 


echo 'Done'
