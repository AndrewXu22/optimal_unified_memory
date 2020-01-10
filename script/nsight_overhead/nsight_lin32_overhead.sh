#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands


date
##### Launch parallel job using srun

## for ray 
#module load cuda/9.0.176

echo "Benchmark,withProf,input,time(s),Mem(KB)" > overhead_lassen.csv

echo -n "CFD,No,fvcorr.domn.097K," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/cfd/lin32-lassen/cfd_orig ../rodinia_3.1/data/cfd/fvcorr.domn.097K 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "CFD,Yes,fvcorr.domn.097K," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100 --quiet --export tmp.out ../rodinia_3.1/cuda/cfd/lin32-lassen/cfd_orig ../rodinia_3.1/data/cfd/fvcorr.domn.097K 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report



echo -n "bfs,No,graph1MW_6," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph1MW_6.txt 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "bfs,Yes,graph1MW_6," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph1MW_6.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "bfs,No,graph4096," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph4096.txt 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "bfs,Yes,graph4096," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph4096.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "bfs,No,graph65536," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph65536.txt 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "bfs,Yes,graph65536," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/bfs/lin32-lassen/bfs_orig ../rodinia_3.1/data/bfs/graph65536.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "gaussian,No,matrix1024," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix1024.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,matrix1024," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix1024.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "gaussian,No,matrix16," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix16.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,matrix16," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix16.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "gaussian,No,matrix208," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix208.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,matrix208," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix208.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "gaussian,No,matrix3," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix3.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,matrix3," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix3.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report

echo -n "gaussian,No,matrix4," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix4.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,matrix4," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -f ../rodinia_3.1/data/gaussian/matrix4.txt  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report


for i in `seq 16 16 1024`;do
echo -n "gaussian,No,$i," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -s $i  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "gaussian,Yes,$i," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli -s 3 -c 100  --quiet --export tmp.out ../rodinia_3.1/cuda/gaussian/lin32-lassen/gaussian_orig -s $i  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report
done

for i in `64 128 256 512 1024 2048 4096 8192`;do
echo -n "hotspot,No,$i," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/hotspot/lin32-lassen/hotspot_orig $i 2 2 ../rodinia_3.1/data/hotspot/temp_$i ../rodinia_3.1/data/hotspot/power_$i output.out 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "hotspot,Yes,$i," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli --quiet --export tmp.out ../rodinia_3.1/cuda/hotspot/lin32-lassen/hotspot_orig $i 2 2 ../rodinia_3.1/data/hotspot/temp_$i ../rodinia_3.1/data/hotspot/power_$i output.out   
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report
done

for da in `seq 50000 50000 200000`;
do
for db in `seq 20 20 100`;
do
for dc in `seq 5 5 20`;
do
echo -n "pathfinder,No,$da$db$dc," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log ../rodinia_3.1/cuda/pathfinder/lin32-lassen/pathfinder_orig $da $db $dc 
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
echo -n "pathfinder,Yes,$da$db$dc," >> overhead_lassen.csv 
/usr/bin/time -f "%e,%M" -o mem.log /g/g92/lin32/opt/nsight-compute-2019.4.0.12/nv-nsight-cu-cli  --quiet --export tmp.out ../rodinia_3.1/cuda/pathfinder/lin32-lassen/pathfinder_orig $da $db $dc  
mem=$(cat mem.log)
echo $mem >> overhead_lassen.csv
rm -rf tmp.out.nsight-cuprof-report
done    
done    
done    
