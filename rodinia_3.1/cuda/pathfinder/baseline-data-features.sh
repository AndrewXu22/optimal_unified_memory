#!/bin/bash
TOOL=nvprof
mkdir -p data-level-measurement
for r in `seq 100000 100000 500000`;do
for c in `seq 100 100 500`;do
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace  ./GPU-executable/pathfinder_1 $r $c 20  &> ./data-level-measurement/GPUTraceOutput_1_${r}${c}20.log
done
done
