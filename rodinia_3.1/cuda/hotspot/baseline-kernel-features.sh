#!/bin/bash
# example script to collect several metrics for a cuda program

##### These are shell commands


date
##### Launch parallel job using srun
mkdir -p kernel-level-measurement

echo 'hotspot'


nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 64 2 2   ../../data/hotspot/temp_64   ../../data/hotspot/power_64 output.out   > ./kernel-level-measurement/nsight_hotspot_64
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 128 2 2  ../../data/hotspot/temp_128  ../../data/hotspot/power_128 output.out  > ./kernel-level-measurement/nsight_hotspot_128
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 256 2 2  ../../data/hotspot/temp_256  ../../data/hotspot/power_256 output.out  > ./kernel-level-measurement/nsight_hotspot_256
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 512 2 2  ../../data/hotspot/temp_512  ../../data/hotspot/power_512 output.out  > ./kernel-level-measurement/nsight_hotspot_512
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 1024 2 2 ../../data/hotspot/temp_1024 ../../data/hotspot/power_1024 output.out > ./kernel-level-measurement/nsight_hotspot_1024
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 2048 2 2 ../../data/hotspot/temp_2048 ../../data/hotspot/power_2048 output.out > ./kernel-level-measurement/nsight_hotspot_2048
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 4096 2 2 ../../data/hotspot/temp_4096 ../../data/hotspot/power_4096 output.out > ./kernel-level-measurement/nsight_hotspot_4096
nv-nsight-cu-cli  --csv ./lassen-executable/hotspot_00 8192 2 2 ../../data/hotspot/temp_8192 ../../data/hotspot/power_8192 output.out > ./kernel-level-measurement/nsight_hotspot_8192

echo 'Done'
