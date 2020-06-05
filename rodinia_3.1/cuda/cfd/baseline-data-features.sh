#!/bin/bash
TOOL=/usr/local/cuda-10.2/bin/nvprof
mkdir -p data-level-measurement
#echo "nvprof --log-file ./output_111_097K.log ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.097K"
#nvprof -u ms --log-file ./output_111_097K.log ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.097K
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.097K &> ./data-level-measurement/GPUTraceOutput_111_097K.log
#echo "nvprof --log-file-./output_111_193K.log ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.193K"
#nvprof -u ms --log-file ./output_111_193K.log ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.193K
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/cfd_111 ../../data/cfd/fvcorr.domn.193K &> ./data-level-measurement/GPUTraceOutput_111_193K.log
#echo "nvprof --log-file ./output_111_0.2M.log ./GPU-executable/cfd_111 ../../data/cfd/missile.domn.0.2M"
#nvprof -u ms --log-file ./output_111_0.2M.log ./GPU-executable/cfd_111 ../../data/cfd/missile.domn.0.2M
$TOOL --unified-memory-profiling per-process-device --print-gpu-trace ./GPU-executable/cfd_111 ../../data/cfd/missile.domn.0.2M &> ./data-level-measurement/GPUTraceOutput_111_missile0.2M.log
