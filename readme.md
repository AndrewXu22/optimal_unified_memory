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


## How to collect kernel level metrics (baseline experiment)

Kernel level feature vector: f(K1) = < f1, f2… fn,> (K1)  
* e.g.  <input size, cycles (8991), duration (3520, nsecond), mem % (9.27, %)>
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

## Now, collect data object level features: 

Assuming two objects, we should have the following feature vectors: 
Data object’s feature vector: f(A) = < f1, f2,...fm> (A) // e.g. <size, cpu pages faults (9982), gpu page faults(334), H2D data movement count(42, MB), D2H data movement count (3, MB) >
How to collect object level metric (baseline experiment):  using nvprof run unified memory default version of a program
Data object’s feature vector:  f(B) = < f1, f2,...fm> (B) // e.g. <cpu pages faults (3434), gpu page faults(78), H2D data movement count(83, MB), D2H data movement count (123, MB) >

Kernel-feature = <cycles (8991), duration (3520, nsecond), mem % (9.27, %)>

Object-feature = <cpu pages faults (9982), gpu page faults(334), H2D data movement count(42, MB), D2H data movement count (3, MB) >

Scripts to collect data object level features. :
  ./rodinia_3.1/cuda/cfd/baseline-data-features.sh

Note -v2.sh may not work properly. The log files have a special name convention for different data sizes in the original script.  Changing name convention needs the change of python scripts!! 

The accepted CFD’s log files must consistly use _097K.log, _193K.log, and _missile0.2M.log for all experiments.

Object-level feature raw data: samples are stored within ./rodinia_3.1/cuda/cfd/data-level-measurement

Post-process script:
./scripts/extractGPUTrace.py

Command to run post-process:
```
> cd data-level-measurement
> python3 $PATH_TO_PROJET/scripts/extractGPUTrace.py
```

Post-processed data; ./rodinia_3.1/cuda/cfd/data-level-measurement/GPUTrace.csv

Sample content of the post-processed data in GPUTrace.csv :
```
array name, variants, input size, 

Data,label,InputData,BeginAddr,EndAddr,CPUPageFault,GPUPagePault,HtoD,DtoH,RemoteMap
h_normals,001,0.2M,0x200060000000,0x200060aa7000,65,578,10944.0,0.0,0.0
h_normals,002,0.2M,0x200060000000,0x200060aa7000,171,629,10944.0,0.0,0.0
```
