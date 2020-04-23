#!/bin/bash
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
echo $i $j $k
echo "nvprof --log-file kernel-level-measurement/lassen-log/output_$i$j${k}_097K.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.097K"
nvprof -u ms --log-file kernel-level-measurement/lassen-log/output_$i$j${k}_097K.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.097K
echo "nvprof --log-file-kernel-level-measurement/lassen-log/output_$i$j${k}_193K.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.193K"
nvprof -u ms --log-file kernel-level-measurement/lassen-log/output_$i$j${k}_193K.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/fvcorr.domn.193K
echo "nvprof --log-file kernel-level-measurement/lassen-log/output_$i$j${k}_missile0.2M.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/missile.domn.0.2M"
nvprof -u ms --log-file kernel-level-measurement/lassen-log/output_$i$j${k}_missile0.2M.log ./lassen-executable/cfd_$i$j$k ../../data/cfd/missile.domn.0.2M
done    
done    
done    
