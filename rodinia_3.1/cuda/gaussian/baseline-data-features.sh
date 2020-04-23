#!/bin/bash
mkdir -p data-level-measurement/
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix3.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix3.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix304.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix304.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix32.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix32.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix320.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix320.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix336.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix336.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix368.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix368.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix384.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix384.log 

nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix4.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix4.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix16.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix16.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix208.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix208.log 
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -f ../../data/gaussian/matrix1024.txt &>  ./data-level-measurement/GPUTraceOutput_111_matrix1024.log 

for d in `seq 16 16 1024`;do
nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/gaussian_111 -q -s $d &>  ./data-level-measurement/GPUTraceOutput_111_${d}.log 
done    

