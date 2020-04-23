#!/bin/bash
mkdir -p  kernel-level-measurement/lassen-log
for i in `seq 0 6`;
do
for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
#echo $i $j $k
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix3.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix3.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix3.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix3.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix304.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix304.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix304.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix304.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix32.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix32.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix32.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix32.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix320.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix320.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix320.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix320.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix336.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix336.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix336.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix336.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix368.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix368.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix368.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix368.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix384.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix384.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix384.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix384.txt > /dev/null 2>&1

#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix4.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix4.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix4.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix4.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix16.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix16.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix16.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix16.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix208.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix208.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix208.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix208.txt > /dev/null 2>&1
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix1024.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix1024.txt"
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_matrix1024.log ./lassen-executable/gaussian_$i$j$k -q -f ../../data/gaussian/matrix1024.txt > /dev/null 2>&1

for d in `seq 16 16 1024`;do
#echo "nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_16.log ./lassen-executable/gaussian_$i$j$k -q -s 16" 
nvprof -u ms --log-file ./kernel-level-measurement/lassen-log/output_$i$j${k}_${d}.log ./lassen-executable/gaussian_$i$j$k -q -s $d > /dev/null 2>&1
done    

done    
done    
done    
