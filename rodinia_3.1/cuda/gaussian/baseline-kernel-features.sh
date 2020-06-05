#!/bin/bash
# example script to collect several metrics for a cuda program

TOOL="/usr/local/cuda-10.2/bin/nv-nsight-cu-cli --section-folder /home/ubuntu/optimization_unified_memory/Nsight/sections"

OUTPATH=kernel-level-measurement-2
date
##### Launch parallel job using srun
mkdir -p $OUTPATH

date
##### Launch parallel job using srun

echo 'gaussian'
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix3.txt   > ./$OUTPATH/nsight_gaussian_matrix3.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix304.txt > ./$OUTPATH/nsight_gaussian_matrix304.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix32.txt  > ./$OUTPATH/nsight_gaussian_matrix32.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix320.txt > ./$OUTPATH/nsight_gaussian_matrix320.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix336.txt > ./$OUTPATH/nsight_gaussian_matrix336.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix368.txt > ./$OUTPATH/nsight_gaussian_matrix368.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix384.txt > ./$OUTPATH/nsight_gaussian_matrix384.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix4.txt   > ./$OUTPATH/nsight_gaussian_matrix4.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix16.txt  > ./$OUTPATH/nsight_gaussian_matrix16.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix208.txt > ./$OUTPATH/nsight_gaussian_matrix208.log
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -f ../../data/gaussian/matrix1024.txt > ./$OUTPATH/nsight_gaussian_matrix1024.log

for i in `seq 16 16 1024`;do
$TOOL -s 3 -c 100  --csv ./GPU-executable/gaussian_000 -q -s $i  > ./$OUTPATH/nsight_gaussian_${i}.log
done

echo 'Done'
