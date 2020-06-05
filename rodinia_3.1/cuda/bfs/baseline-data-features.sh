#!/bin/bash
TOOL=/usr/local/cuda-10.2/bin/nvprof
mkdir -p data-level-measurement
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/bfs_111100 ../../data/bfs/graph1MW_6.txt &> ./data-level-measurement/GPUTraceOutput_111_graph1MW.6.log
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/bfs_111100 ../../data/bfs/graph4096.txt &> ./data-level-measurement/GPUTraceOutput_111_graph4096.log
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/bfs_111100 ../../data/bfs/graph65536.txt &> ./data-level-measurement/GPUTraceOutput_111_graph65536.log
