#!/bin/bash
#
#SBATCH --job-name=hotspot
#
#SBATCH --time=6:00:00
#SBATCH --ntasks=1
#SBATCH --partition=hsw_v100_32g

module load cuda
cd /home/phlin/projects/optimization_unified_memory/rodinia_3.1/cuda/hotspot/lin32-PSG
./run.sh
