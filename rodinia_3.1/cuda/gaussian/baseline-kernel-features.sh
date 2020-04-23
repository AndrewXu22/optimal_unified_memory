#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands

mkdir -p kernel-level-measurement
date
##### Launch parallel job using srun

echo 'gaussian'
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix3.txt > ./kernel-level-measurement/nsight_gaussian_matrix3.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix304.txt > ./kernel-level-measurement/nsight_gaussian_matrix304.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix32.txt > ./kernel-level-measurement/nsight_gaussian_matrix32.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix320.txt > ./kernel-level-measurement/nsight_gaussian_matrix320.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix336.txt > ./kernel-level-measurement/nsight_gaussian_matrix336.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix368.txt > ./kernel-level-measurement/nsight_gaussian_matrix368.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix384.txt > ./kernel-level-measurement/nsight_gaussian_matrix384.log

nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix4.txt > ./kernel-level-measurement/nsight_gaussian_matrix4.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix16.txt > ./kernel-level-measurement/nsight_gaussian_matrix16.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix208.txt > ./kernel-level-measurement/nsight_gaussian_matrix208.log
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -f ../../data/gaussian/matrix1024.txt > ./kernel-level-measurement/nsight_gaussian_matrix1024.log

for i in `seq 16 16 1024`;do
nv-nsight-cu-cli -s 3 -c 100  --csv ./lassen-executable/gaussian_000 -q -s $i  > ./kernel-level-measurement/nsight_gaussian_${i}.log
done

echo 'Done'
