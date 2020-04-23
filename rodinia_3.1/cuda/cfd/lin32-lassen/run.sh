#!/bin/bash
for m in `seq 0 1`;
do
for i in `seq 0 5`;
do
for j in `seq 0 5`;
do
for k in `seq 0 5`;
do
echo $i $j $k
echo "nvprof --log-file output_$m$i$j${k}_097K.log ./cfd_$m$i$j$k ../../../data/cfd/fvcorr.domn.097K"
nvprof -u ms --log-file output_$m$i$j${k}_097K.log ./cfd_$m$i$j$k ../../../data/cfd/fvcorr.domn.097K
echo "nvprof --log-file-output_$m$i$j${k}_193K.log ./cfd_$m$i$j$k ../../../data/cfd/fvcorr.domn.193K"
nvprof -u ms --log-file output_$m$i$j${k}_193K.log ./cfd_$m$i$j$k ../../../data/cfd/fvcorr.domn.193K
echo "nvprof --log-file output_$m$i$j${k}_0.2M.log ./cfd_$m$i$j$k ../../../data/cfd/missile.domn.0.2M"
nvprof -u ms --log-file output_$m$i$j${k}_0.2M.log ./cfd_$m$i$j$k ../../../data/cfd/missile.domn.0.2M
done    
done    
done    
done    
