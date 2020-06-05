#!/bin/bash
TOOL=/usr/local/cuda-10.2/bin/nvprof
mkdir -p kernel-level-measurement/GPU-log
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
echo $i $j $k
echo "nvprof --log-file kernel-level-measurement/GPU-log/output_$i$j${k}_097K.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.097K"
$TOOL -u ms --log-file kernel-level-measurement/GPU-log/output_$i$j${k}_097K.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.097K
echo "nvprof --log-file-kernel-level-measurement/GPU-log/output_$i$j${k}_193K.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.193K"
$TOOL -u ms --log-file kernel-level-measurement/GPU-log/output_$i$j${k}_193K.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.193K
echo "nvprof --log-file kernel-level-measurement/GPU-log/output_$i$j${k}_missile0.2M.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/missile.domn.0.2M"
$TOOL -u ms --log-file kernel-level-measurement/GPU-log/output_$i$j${k}_missile0.2M.log ./GPU-executable/cfd_$i$j$k ../../data/cfd/missile.domn.0.2M
done    
done    
done    
