This repo contains the instructions, scripts, and codes needed to reproduce the
experiments for our SC paper named:
"XPlacer: A framework for Guiding Optimal Use of GPU Unified Memory"

Overview of major steps
* Step 1. Collect baseline metrics for both kernel-level and object level features
* Step 2. Merge kernel and object level features
* Step 3. Label the training data
* Step 4. Generate the model
* Step 5. Use the model to predict a new kernel’s object policies	

# Step 1. Collect Baseline Metrics for Kernel and Object Level Features

Kernel level feature vector: f(K1) = < f1, f2… fn,> (K1)  
* e.g.  <input size, cycles (8991), duration (3520, nsecond), mem % (9.27, %)>

How to collect kernel level metrics (baseline experiment)
* using nsight run default, discrete memory API version of a program  (select this for now)

Build all necessary code variants for the program
Prerequisites: 
* aws-volta: nvcc --version, V10.2.89
* a GPU machine running Ubuntu 18.04 LTS
* python3 and python3-pandas  // apt-get install python3-pandas

Build the cuda-adapter library 
cd rodinia_3.1/cuda-adapter 
type make 

Build up to 7\*7\*7 = 343 binary variants for the benchmark, using a script 

e.g: rodinia_3.1/cuda/cfd/compile.sh or compile-aws-volta.sh (trying to run nvcc in background with some parallelism) 
you need to customize the environment variables in the scripts first.

hostname-exectuable/ will contain the generated binary variants. run “ls |wc” will show if there are correct number of files under this path.

There is a script to run all the program variants
* ./rodinia_3.1/cuda/cfd/baseline-kernel-features.sh

You need to set the right path to the profiler in the script.

You may need to use sudo to run the script since it uses nv-nsight-cu-cli to collect hardware counter information.

Raw Data samples are stored within

./rodinia_3.1/cuda/cfd/kernel-level-measurement

three log files for three different data sizes of CFD, note that the data size portion file names must be consistent for all log files. Later python scripts will rely on them to merge and label data. 
* nsight_cfd_097K.log  
* nsight_cfd_193K.log  
* nsight_cfd_missile0.2M.log

Post-process script:
./scripts/logs_format_to_dataset.py

Commandlines to run post-process:
```
> cd kernel-level-measureent
> python3 $PROJECT_HOME/prototype/logs_format_to_dataset.py
```

Example output from nsight_cfd_unRM_097k.log:
```
"ID","Process ID","Process Name","Host Name","Kernel Name","Kernel Time","Context","Stream","Section Name","Metric Name","Metric Unit","Metric Value"

"0","21524","cfd_000","127.0.0.1","cuda_compute_step_factor","2020-Apr-07 17:01:05","1","7","GPU Speed Of Light","Memory Frequency","cycle/second","772656250"
"0","21524","cfd_000","127.0.0.1","cuda_compute_step_factor","2020-Apr-07 17:01:05","1","7","GPU Speed Of Light","SOL FB","%","39.60"
"0","21524","cfd_000","127.0.0.1","cuda_compute_step_factor","2020-Apr-07 17:01:05","1","7","GPU Speed Of Light","Elapsed Cycles","cycle","11733"
```

Output dataset at:
* ./rodinia_3.1/cuda/cfd/kernel-level-measurement/dataset.csv


