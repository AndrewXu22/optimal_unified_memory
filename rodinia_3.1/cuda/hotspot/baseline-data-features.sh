#!/bin/bash
mkdir -p data-level-measurement
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 64 2 2   ../../data/hotspot/temp_64   ../../data/hotspot/power_64 output.out   &> ./data-level-measurement/GPUTraceOutput_11_64.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 128 2 2  ../../data/hotspot/temp_128  ../../data/hotspot/power_128 output.out  &> ./data-level-measurement/GPUTraceOutput_11_128.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 256 2 2  ../../data/hotspot/temp_256  ../../data/hotspot/power_256 output.out  &> ./data-level-measurement/GPUTraceOutput_11_256.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 512 2 2  ../../data/hotspot/temp_512  ../../data/hotspot/power_512 output.out  &> ./data-level-measurement/GPUTraceOutput_11_512.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 1024 2 2 ../../data/hotspot/temp_1024 ../../data/hotspot/power_1024 output.out &> ./data-level-measurement/GPUTraceOutput_11_1024.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 2048 2 2 ../../data/hotspot/temp_2048 ../../data/hotspot/power_2048 output.out &> ./data-level-measurement/GPUTraceOutput_11_2048.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 4096 2 2 ../../data/hotspot/temp_4096 ../../data/hotspot/power_4096 output.out &> ./data-level-measurement/GPUTraceOutput_11_4096.log
nvprof --unified-memory-profiling per-process-device --print-gpu-trace  ./lassen-executable/hotspot_11 8192 2 2 ../../data/hotspot/temp_8192 ../../data/hotspot/power_8192 output.out &> ./data-level-measurement/GPUTraceOutput_11_8192.log
