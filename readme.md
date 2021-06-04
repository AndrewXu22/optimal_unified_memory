This repo contains the instructions, scripts, and codes needed to reproduce the
experiments for our paper named:
"XPlacer: A framework for Guiding Optimal Use of GPU Unified Memory"

# Overview of major steps

The goal is to decide which memory placement policy is best for a given data object (array) with a CUDA kernel.  We prepare code variants of kernels using different memory placement policies, input data sizes and run them all.  Performance and profiling information are collected and made into a labelled training dataset. After that, machine learning models are built and used to guide memory placement of new programs. 

* Step 1. Collect baseline metrics for both kernel-level and object level features
* Step 2. Merge kernel and object level features
* Step 3. Label the training data
* Step 4. Generate the model
* Step 5. Use the model to predict a new kernel’s object policies	

# Prerequisites: 
* a GPU machine running Ubuntu 18.04 LTS
* p3.2xlarge: AWS vm instance with Volta GPU 
* Nvidia CUDA toolkit 10.2: nvcc --version, V10.2.89
* python3 and python3-pandas  // apt-get install python3-pandas
* Weka 3.8.5: https://waikato.github.io/weka-wiki/downloading_weka/#linux_1

# Step 1. Collect Baseline Metrics for Kernel and Object Level Features


## How to collect kernel level metrics (baseline experiment)

Kernel level feature vector: f(K1) = < f1, f2… fn,> (K1)  
* e.g.  <input size, cycles (8991), duration (3520, nsecond), mem % (9.27, %)>
* using nsight run default, discrete memory API version of a program  (select this for now)

Build all necessary code variants for the program. The variants of a kernel include a combination of choices of using discrete memory API, unified memory API, and CUDAMemAdvise(). 

Build the cuda-adapter library 

```
cd rodinia_3.1/cuda-adapter 
make 
```

Build up to 7\*7\*7 = 343 binary variants for the benchmark, using a script 

e.g: rodinia_3.1/cuda/cfd/compile.sh or compile-aws-volta.sh (trying to run nvcc in background with some parallelism) 
you need to customize the environment variables in the scripts first.

hostname-exectuable/ will contain the generated binary variants. run “ls |wc” will show if there are correct number of files under this path.

There is a script to run all the program variants
* ./rodinia_3.1/cuda/cfd/baseline-kernel-features.sh

You need to set the right path to the profiler in the script.

You may need to use sudo to run the script since it uses nv-nsight-cu-cli to collect hardware counter information. Or you may get the error message like "The user does not have permission to access NVIDIA GPU Performance Counters".  

Raw Data samples are stored within

./rodinia_3.1/cuda/cfd/kernel-level-measurement

three log files for three different data sizes of CFD, note that the data size portion file names must be consistent for all log files. Later python scripts will rely on them to merge and label data. 

* nsight_cfd_097K.log  
* nsight_cfd_193K.log  
* nsight_cfd_missile0.2M.log

Example content of nsight_cfd_097K.log
```
"ID","Process ID","Process Name","Host Name","Kernel Name","Kernel Time","Context","Stream","Section Name","Metric Name","Metric Unit","Metric Value"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","Memory Frequency","cycle/second","768683274.02"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SOL FB","%","46.47"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","Elapsed Cycles","cycle","10251"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SM Frequency","cycle/second","1138271055.75"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","Memory [%]","%","46.47"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","Duration","nsecond","8992"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SOL L2","%","13.61"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SM Active Cycles","cycle","8038.12"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SM [%]","%","22.48"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","GPU Speed Of Light","SOL TEX","%","11.33"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Block Size","","192"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Grid Size","","506"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Registers Per Thread","register/thread","20"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Shared Memory Configuration Size","byte","0"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Dynamic Shared Memory Per Block","byte/block","0"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Static Shared Memory Per Block","byte/block","0"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Threads","thread","97152"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Launch Statistics","Waves Per SM","","0.63"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Block Limit SM","block","32"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Block Limit Registers","block","14"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Block Limit Shared Mem","block","32"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Block Limit Warps","block","10"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Achieved Active Warps Per SM","warp","30.72"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Achieved Occupancy","%","48.00"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Theoretical Active Warps per SM","warp/cycle","60"
"0","28439","cfd_000","127.0.0.1","cuda_compute_step_factor(int,float*,float*,float*)","2020-May-29 12:02:46","1","7","Occupancy","Theoretical Occupancy","%","93.75"
```

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

Example content of dataset.csv:
```
Benchmark,InputData,ID,Kernel,Memory Frequency,SOL FB,Elapsed Cycles,SM Frequency,Memory [%],Duration,SOL L2,SM Active Cycles,SM [%],SOL TEX,Block Size,Grid Size,Registers Per Thread,Shared Memory Configuration Size,Dynamic Shared Memory Per Block,Static Shared Memory Per Block,Threads,Waves Per SM,Block Limit SM,Block Limit Registers,Block Limit Shared Mem,Block Limit Warps,Achieved Active Warps Per SM,Achieved Occupancy,Theoretical Active Warps per SM,Theoretical Occupancy
cfd,097K,0,cuda_compute_step_factor,768683274.02,46.47,10251,1138271055.75,46.47,8992,13.61,8038.12,22.48,11.33,192,506,20,0,0,0,97152,0.63,32,14,32,10,30.72,48.00,60,93.75
cfd,097K,1,cuda_compute_flux,872404485.05,34.41,49831,1289451827.24,34.41,38528,30.54,37603.90,26.02,28.81,192,506,60,0,0,0,97152,1.27,32,5,32,10,25.03,39.11,30,46.88
cfd,097K,2,cuda_time_step,805194805.19,66.24,14764,1196117424.24,66.24,12320,21.59,11349.56,5.22,14.71,192,506,22,0,0,0,97152,0.63,32,14,32,10,34.09,53.26,60,93.75
cfd,097K,3,cuda_compute_flux,881048387.10,33.09,51774,1301285282.26,33.09,39680,29.46,39758.10,27.25,27.44,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.01,37.51,30,46.88
cfd,097K,4,cuda_time_step,799212598.43,67.71,14494,1186365376.20,67.71,12192,21.99,11510.29,5.32,14.51,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.93,53.02,60,93.75
cfd,097K,5,cuda_compute_flux,881584362.14,33.76,50783,1301491769.55,33.76,38880,30.10,38880.47,26.32,27.88,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.42,38.16,30,46.88
cfd,097K,6,cuda_time_step,822418136.02,63.16,15549,1221623110.83,63.16,12704,20.49,11934.80,4.96,13.99,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.91,52.99,60,93.75
cfd,097K,7,cuda_compute_step_factor,806381118.88,43.80,10951,1193582459.21,43.80,9152,12.75,8344.74,21.54,10.91,192,506,20,0,0,0,97152,0.63,32,14,32,10,30.01,46.89,60,93.75
cfd,097K,8,cuda_compute_flux,843037459.28,34.89,49003,1243786475.30,34.89,39296,31.06,39725.61,26.83,27.44,192,506,60,0,0,0,97152,1.27,32,5,32,10,23.43,36.60,30,46.88
cfd,097K,9,cuda_time_step,801020408.16,65.76,14947,1188549638.61,65.76,12544,21.34,11664.88,5.18,14.31,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.95,53.04,60,93.75
cfd,097K,10,cuda_compute_flux,861365528.73,34.87,49032,1272251422.43,34.87,38432,31.15,39003.55,26.22,27.99,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.03,37.55,30,46.88
cfd,097K,11,cuda_time_step,767948717.95,68.62,14245,1138087606.84,68.62,12480,22.39,11849.74,5.42,14.09,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.95,53.04,60,93.75
cfd,097K,12,cuda_compute_flux,848206839.03,35.37,48148,1251172852.38,35.37,38368,31.68,37848.66,25.97,28.84,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.37,38.08,30,46.88
cfd,097K,13,cuda_time_step,858725761.77,66.42,14740,1272838758.08,66.42,11552,21.64,11596.54,5.23,14.40,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.83,52.86,60,93.75
cfd,097K,14,cuda_compute_step_factor,808510638.30,44.07,10812,1195183215.13,44.07,9024,12.91,8358.98,20.66,10.90,192,506,20,0,0,0,97152,0.63,32,14,32,10,29.90,46.72,60,93.75
cfd,097K,15,cuda_compute_flux,874580536.91,34.61,49411,1291277789.43,34.61,38144,30.91,38238.59,25.36,28.54,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.52,38.32,30,46.88
cfd,097K,16,cuda_time_step,839832869.08,68.84,14361,1247809308.26,68.84,11488,22.19,11616.44,5.37,14.37,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.71,52.67,60,93.75
cfd,097K,17,cuda_compute_flux,892765957.45,34.51,49739,1317752659.57,34.51,37600,30.68,37310.68,24.57,29.09,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.27,37.93,30,46.88
cfd,097K,18,cuda_time_step,818306010.93,68.75,14251,1214224726.78,68.75,11712,22.36,11558.29,5.41,14.45,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.88,52.94,60,93.75
cfd,097K,19,cuda_compute_flux,817842323.65,36.72,46644,1206241355.46,36.72,38560,32.69,36478.29,25.81,29.77,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.67,38.54,30,46.88
cfd,097K,20,cuda_time_step,806216931.22,67.71,14519,1197654872.13,67.71,12096,21.96,12083.27,5.31,13.82,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.92,53.00,60,93.75
cfd,097K,21,cuda_compute_step_factor,785964912.28,45.27,10639,1164126461.99,45.27,9120,13.12,8148.52,20.08,11.18,192,506,20,0,0,0,97152,0.63,32,14,32,10,30.19,47.18,60,93.75
cfd,097K,22,cuda_compute_flux,878695652.17,35.69,47836,1296046195.65,35.69,36800,31.85,37109.89,25.22,29.28,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.34,38.04,30,46.88
cfd,097K,23,cuda_time_step,773076923.08,68.55,14356,1147823183.76,68.55,12480,22.21,11442.55,5.37,14.59,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.97,53.07,60,93.75
cfd,097K,24,cuda_compute_flux,843878389.48,35.20,48646,1245065564.23,35.20,38944,31.32,38250.64,24.32,28.48,192,506,60,0,0,0,97152,1.27,32,5,32,10,24.17,37.76,30,46.88
cfd,097K,25,cuda_time_step,811314363.14,68.97,14232,1202376919.60,68.97,11808,22.41,11712.08,5.42,14.26,192,506,22,0,0,0,97152,0.63,32,14,32,10,33.72,52.68,60,93.75
```

## Now, collect data object level features: 
Data object level features contain information about page faults on CPU and GPU, as well as data movement between host and device.

Assuming two objects, we should have the following feature vectors: 
* Data object’s feature vector: f(A) = < f1, f2,...fm> (A) 
  * e.g. <size, cpu pages faults (9982), gpu page faults(334), H2D data movement count(42, MB), D2H data movement count (3, MB) >
* Data object’s feature vector:  f(B) = < f1, f2,...fm> (B) 
  * e.g. <cpu pages faults (3434), gpu page faults(78), H2D data movement count(83, MB), D2H data movement count (123, MB) >

How to collect object level metric (baseline experiment):  using nvprof to run the unified memory default version of a program. 

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

# Step 2. Merge kernel and object level features 
This step essentially join two tables into a single table, by merging kernel level features with data object level features. 

The Merge script: 
* ./prototype/merger.py

You need to make sure 
```
df1 = pd.read_csv("./kernel-level-measurement/dataset.csv")
df2 = pd.read_csv("./data-level-measurement/GPUTrace.csv")
```
e.g. run it  under ~/optimization_unified_memory/rodinia_3.1/cuda/cfd
```
python3 $PATH_TO_PROJECT/scripts/labeler-v2.py 
```

Output of merged data:
* ./rodinia_3.1/cuda/cfd/mergedDataSet.csv

A similar file for aws volta machine: mergedDataSet-ip-128-115-246-7.csv 

Command to run merger:
* python3 $PATH_TO_PROJET/optimization_unified_memory/prototype/merger.py

Merged_feature = Kernel_vector X Object_vector

M (K1-A-B) = [ < f(K1) + f(A) > ]

Note that: feature vector length (n+m)  <  f(k1) + f(B) 

Merged Feature vector for A:: <input size, cycles, duration, mem%, cpu page faults, gpu page faults, H2D data movement count, D2H data movement count, advise>, for example:
```
< 1, 8991, 3520, 9.27, 9982, 334, 42, 3, 0>   
< 1, 8991, 3520, 9.27, 3434, 78, 83, 123> 
< 2, 8991, 3520, 9.27, 9982, 334, 42, 3>   
< 2, 8991, 3520, 9.27, 3434, 78, 83, 123> 
```

Note: profilers collect object level metrics for the whole program, the multiplication of kernel vector and object vector may result in some records which do not correspond to actual use of objects within the kernels. We may need to ignore some records. 


Notes for the columns
* InputData:  the data size for a benchmark:    this varies a lot from one program to another
* Data: the variable name
* DataID: always values of 0, 1,2 , the top three most important arrays
* 28: Not Eligible, this can be ignored
* 31: One or More Eligible , this can be ignored.
* 57: variant XXX three digit value to indicate which variant

# Step 3. Label the training data
This step labels rows in the training dataset with an optimal policy choice.  

## Generate kernel-based run for all variants
* ./rodinia_3.1/cuda/cfd/run_variants.sh

./rodinia_3.1/cuda/cfd$ nohup ./run_variants-v2.sh &

Output sample:
* ./rodinia_3.1/cuda/cfd/ip-128-115-246-7-kernel-level-measurement/variants 
There should be 7*7*7*3 = 1029 log files :up to 3 objects, each 7 variants, 3 input data sizes for cfd

## PostProcessing to find the best performing ones
Post-process script:
*./scripts/extractData.py

Command: 
* python3 $PATH_TO_PROJECT/scripts/extractData.py

Output Summary in csv: 
* ./rodinia_3.1/cuda/cfd/kernel-level-measurement/data-level-measurement/GPUTrace.csv


Currently the kernel-level results (using minimum nvprof option) is collected at 
./rodinia_3.1/cuda/cfd/data-level-measurement/dataset.csv

We can sort the csv file to find the best execution time for each kernel.
  
cuda_compute_flux,0.2M,0,000,66.45,402.5463,6000,0.067091,0.058240,0.070912

Best-performed data group by kernel and inputdata:
* ./rodinia_3.1/cuda/cfd/kernel-level-measurement/GPU-log/kernel-data-best.csv

Example content of kernel-data-best.csv is:
```
kernel,InputData,advise0,advise1,advise2,variant,TimePerc,Time,calls,AVG,MIN,MAX
cuda_compute_flux,097K,6,0,2,602,74.51,182.9408,6000,0.030489999999999996,0.027617000000000003,1.603672
cuda_compute_flux,193K,0,1,2,12,67.33,300.6107,6000,0.050101,0.04672,4.110404
cuda_compute_flux,missile0.2M,2,1,6,216,69.46,399.1468,6000,0.066524,0.06111900000000001,4.255723000000001
cuda_compute_step_factor,097K,0,0,5,5,0.28,7.298011,2000,0.00365,0.00346,0.0054399999999999995
cuda_compute_step_factor,193K,0,0,4,4,0.32,17.07745,2000,0.00854,0.008029999999999999,0.011456000000000001
cuda_compute_step_factor,missile0.2M,0,0,5,5,0.37,23.6803,2000,0.01184,0.010816,0.013472
cuda_initialize_variables,097K,4,6,1,461,0.0,0.015584,3,0.00519,0.0032,0.0073
cuda_initialize_variables,193K,2,2,1,221,0.0,0.022368,3,0.00746,0.00563,0.011008
cuda_initialize_variables,missile0.2M,1,6,2,162,0.0,0.02512,3,0.00837,0.00643,0.012032
cuda_time_step,097K,4,5,4,454,0.92,32.757329999999996,6000,0.0054600000000000004,0.00483,0.00672
cuda_time_step,193K,5,4,5,545,1.43,101.3333,6000,0.016888,0.015776,0.020031999999999998
cuda_time_step,missile0.2M,0,6,6,66,20.62,120.6156,6000,0.020102000000000002,0.018847,0.022175999999999998
```

## Applying Labels to feature vectors
This step adds one more column (indicating best memory placement policy) into the merged training datasets. 

Add label into the merged feature vector
* <Kernel-feature, data-object-feature, label>

// How to label the data with object level adaptation ： assuming 7 options for data placement
best execution of variants: 
* SC paper:  object variants: each object within a kernel, different placement  policies 
* Once we find the best performing one of the 49 variants.: we use the labels for each data object . 

Labeled_Vector =  M_Vector + Labels

Key components of the final vector
* < Kernel, input, array object, list of features, policy_label>

Script:
* ./scripts/labeler.py
Command:
```
cd $PATH_TO_PROJET/optimization_unified_memory/rodinia_3.1/cuda/cfd
Python3 $PATH_TO_PROJET/prototypes/labeler.py
```

Output labelled data:
* ./rodinia_3.1/cuda/cfd/labelledData.csv

Example content of labelled training dataset:
```
InputData,Kernel,Data,DataID,Memory Frequency,SOL FB,Elapsed Cycles,SM Frequency,Memory [%],Duration,SOL L2,SM Active Cycles,SM [%],SOL TEX,Executed Ipc Active,Executed Ipc Elapsed,Issued Ipc Active,Issue Slots Busy,SM Busy,Memory Throughput,Mem Busy,Max Bandwidth,L2 Hit Rate,Mem Pipes Busy,L1 Hit Rate,Active Warps Per Scheduler,Eligible Warps Per Scheduler,No Eligible,Instructions Per Active Issue Slot,Issued Warp Per Scheduler,One or More Eligible,Avg. Not Predicated Off Threads Per Warp,Avg. Active Threads Per Warp,Warp Cycles Per Executed Instruction,Warp Cycles Per Issued Instruction,Warp Cycles Per Issue Active,Avg. Executed Instructions Per Scheduler,Executed Instructions,Avg. Issued Instructions Per Scheduler,Issued Instructions,Block Size,Grid Size,Registers Per Thread,Shared Memory Configuration Size,Dynamic Shared Memory Per Block,Static Shared Memory Per Block,Threads,Waves Per SM,Block Limit SM,Block Limit Registers,Block Limit Shared Mem,Block Limit Warps,Achieved Active Warps Per SM,Achieved Occupancy,Theoretical Active Warps per SM,Theoretical Occupancy,variant,BeginAddr,EndAddr,DataSize,CPUPageFault,GPUPagePault,HtoD,DtoH,RemoteMap,label
097K,cuda_compute_flux,h_areas,0,855612379.1818607,35.504186046511634,48253.906976744176,1260954128.7597673,35.504186046511634,38140.279069767435,31.70139534883721,36773.15720930233,23.682093023255817,29.556511627906985,1.2325581395348837,0.9432558139534885,1.2362790697674415,30.930232558139533,30.930232558139533,311041577410.956,31.70139534883721,35.504186046511634,72.77418604651164,5.659767441860465,28.141162790697685,6.285581395348838,0.5130232558139532,68.47558139534884,1.0,0.31558139534883745,31.52441860465117,26.61418604651163,27.793953488372086,20.078604651162788,19.99255813953488,19.99255813953488,11336.228837209304,3627593.2325581396,11387.350930232556,3643952.325581395,192.0,506.0,60.0,0.0,0.0,0.0,97152.0,1.2700000000000011,32.0,5.0,32.0,10.0,24.589069767441863,38.41883720930233,30.0,46.88000000000007,111,0x7fd202000000,0x7fd20205ee00,388608,3,11,512.0,0.0,0.0,6
097K,cuda_compute_flux,h_elements_surrounding_elements,1,855612379.1818607,35.504186046511634,48253.906976744176,1260954128.7597673,35.504186046511634,38140.279069767435,31.70139534883721,36773.15720930233,23.682093023255817,29.556511627906985,1.2325581395348837,0.9432558139534885,1.2362790697674415,30.930232558139533,30.930232558139533,311041577410.956,31.70139534883721,35.504186046511634,72.77418604651164,5.659767441860465,28.141162790697685,6.285581395348838,0.5130232558139532,68.47558139534884,1.0,0.31558139534883745,31.52441860465117,26.61418604651163,27.793953488372086,20.078604651162788,19.99255813953488,19.99255813953488,11336.228837209304,3627593.2325581396,11387.350930232556,3643952.325581395,192.0,506.0,60.0,0.0,0.0,0.0,97152.0,1.2700000000000011,32.0,5.0,32.0,10.0,24.589069767441863,38.41883720930233,30.0,46.88000000000007,111,0x7fd20205ee00,0x7fd2021da600,1554432,10,17,1536.0,0.0,0.0,0
097K,cuda_compute_flux,h_normals,2,855612379.1818607,35.504186046511634,48253.906976744176,1260954128.7597673,35.504186046511634,38140.279069767435,31.70139534883721,36773.15720930233,23.682093023255817,29.556511627906985,1.2325581395348837,0.9432558139534885,1.2362790697674415,30.930232558139533,30.930232558139533,311041577410.956,31.70139534883721,35.504186046511634,72.77418604651164,5.659767441860465,28.141162790697685,6.285581395348838,0.5130232558139532,68.47558139534884,1.0,0.31558139534883745,31.52441860465117,26.61418604651163,27.793953488372086,20.078604651162788,19.99255813953488,19.99255813953488,11336.228837209304,3627593.2325581396,11387.350930232556,3643952.325581395,192.0,506.0,60.0,0.0,0.0,0.0,97152.0,1.2700000000000011,32.0,5.0,32.0,10.0,24.589069767441863,38.41883720930233,30.0,46.88000000000007,111,0x7fd202200000,0x7fd202672800,4663296,33,24,4556.0,0.0,0.0,2
097K,cuda_compute_step_factor,h_areas,0,787314688.5766665,45.43999999999999,10506.2,1164327823.9353333,45.43999999999999,9011.2,13.316666666666665,8074.781333333332,19.165999999999997,11.28133333333333,0.9826666666666666,0.7586666666666666,0.994,24.875999999999998,24.875999999999998,366295905221.2373,13.316666666666665,45.43999999999999,15.373999999999995,5.429999999999999,0.0,7.751333333333332,0.45799999999999996,74.42,1.0,0.25533333333333336,25.58,25.807999999999996,27.694666666666667,30.80133333333333,30.448666666666664,30.448666666666664,1987.178,635897.0,2010.4226666666666,643334.6,192.0,506.0,20.0,0.0,0.0,0.0,97152.0,0.6300000000000001,32.0,14.0,32.0,10.0,30.26466666666667,47.288,60.0,93.75,111,0x7fd202000000,0x7fd20205ee00,388608,3,11,512.0,0.0,0.0,0
097K,cuda_compute_step_factor,h_elements_surrounding_elements,1,787314688.5766665,45.43999999999999,10506.2,1164327823.9353333,45.43999999999999,9011.2,13.316666666666665,8074.781333333332,19.165999999999997,11.28133333333333,0.9826666666666666,0.7586666666666666,0.994,24.875999999999998,24.875999999999998,366295905221.2373,13.316666666666665,45.43999999999999,15.373999999999995,5.429999999999999,0.0,7.751333333333332,0.45799999999999996,74.42,1.0,0.25533333333333336,25.58,25.807999999999996,27.694666666666667,30.80133333333333,30.448666666666664,30.448666666666664,1987.178,635897.0,2010.4226666666666,643334.6,192.0,506.0,20.0,0.0,0.0,0.0,97152.0,0.6300000000000001,32.0,14.0,32.0,10.0,30.26466666666667,47.288,60.0,93.75,111,0x7fd20205ee00,0x7fd2021da600,1554432,10,17,1536.0,0.0,0.0,0
097K,cuda_compute_step_factor,h_normals,2,787314688.5766665,45.43999999999999,10506.2,1164327823.9353333,45.43999999999999,9011.2,13.316666666666665,8074.781333333332,19.165999999999997,11.28133333333333,0.9826666666666666,0.7586666666666666,0.994,24.875999999999998,24.875999999999998,366295905221.2373,13.316666666666665,45.43999999999999,15.373999999999995,5.429999999999999,0.0,7.751333333333332,0.45799999999999996,74.42,1.0,0.25533333333333336,25.58,25.807999999999996,27.694666666666667,30.80133333333333,30.448666666666664,30.448666666666664,1987.178,635897.0,2010.4226666666666,643334.6,192.0,506.0,20.0,0.0,0.0,0.0,97152.0,0.6300000000000001,32.0,14.0,32.0,10.0,30.26466666666667,47.288,60.0,93.75,111,0x7fd202200000,0x7fd202672800,4663296,33,24,4556.0,0.0,0.0,5
```
## Details of instances in the dataset
Here is the breakdown for the 2688 instance and both IBM and Intel should have 2688 instances respectively:
BFS: 200
CFD: 270
Hotspot 16
Gaussian:2202

Explanation here:
Each instance represents the labelled data for a data object in a kernel of a benchmark with a specific input data.  Each benchmark might launch a kernel multiple times. Nsight tool re-runs each kernel to capture the profile data. We exploit this capability to increase the overall number of data instances. Here we collect the top 5 (for Gaussian) or 10 (for rest) kernel launch instances from the raw measurements.  The number of kernel+input+data combinations are the following:
BFS: (2 kernels) x (4 data objects) x (3 input) = 24
CFD: (4 kernels) x (3 data objects) x (3 input) = 36
Hotspot: (1 kernels) x (2 data objects) x (8 input) = 16
Gaussian: (2 kernels) x (3 data objects) x (75 input) = 450

BFS should have 24x10 = 240 instances but we have only 200.  Some kernels were launched less than 10 times with certain input data. We have ((10+10) + (6 + 7) + (8 + 9)) x 4 = 200 instances
CFD should have 36x10 = 360 instances but we have only 270.  One kernel, cuda_initialize_variables, is not profiled by Nsight. That leads to only 27 combinations and 270 instances as result.
Hotspot should have 16x10 = 160 instances but we have only 16.  Following the default execution command the kernel is only launched once in each run. Therefore, there are only 16 overall instances that can be collected.
Gaussian should have 450x5 = 2250 instances but we have only 2202.  Less kernel launches observed with smaller data size. Two of them lead to less than 10 kernel launches. One input, matrix3, has only one kernel launched.  2202 = 73x2x3x5 + 1x1x3x1 + 1x3x(1+2) = 2202

# Step 4. Generate the Model

Use the sample data from cfd:
* ./rodinia_3.1/cuda/cfd/labelledData.csv
  CFD: 28 rows, 27 records,  3 kernels x 3 data sizes x 3 arrays = 27 , merged from 3*3 * 7*7*7 instances
* ./rodinia_3.1/cuda/bfs/labelledData.csv , 
  BFS: 25 rows, 24 records, 2 kernels x 3 data sizes x 4 arrays = 24
* ./rodinia_3.1/cuda/gaussian/labelledData.csv
  Gaussian: 448 rows, 447 records, 2 kernels x 75 data sizes x 3 arrays= 450 (It needs to subtracts 3 because only 1 kernel is profiled using input data matrix3. )

Instructions:
* Put the sample data into Weka, normalize all values, and remove the features that have same values (all 0, 1 or others)
* Dataset samples are here: 
   https://github.com/AndrewXu22/optimal_unified_memory/blob/master/data/data_IBM_%26_AWS_082020/AWS_2688data.csv.arff
   https://github.com/AndrewXu22/optimal_unified_memory/blob/master/data/data_IBM_%26_AWS_082020/IBM_2688data.arff
   Note: When using it, please remove the first four features (InputData, Kernel, Data, DataId) in Weka.

Another normalized dataset sample:
    ./data/performance_results_dataset/GPU_dataset.arff
    
* Run with several tree models in Weka to test: e.g., Random Tree (66% train and 33% test): 
    Note that the results are not very good since only sample data is used. You should get more accurate models with full datasets


More info. Train a model with the training dataset

Option 1: use the Weka software interface to do the training work
*  Step (1). Open Weka, click "Explorer", go to the new Explorer interface
* Step (2). Click "Open file", then select the training set in .arff format, then it will display the details of dataset with attributes and class, etc.
* Step (3). Click "Classify" button in the upside, then click "choose", where allows you to select the model you want to use
           e.g., choose -> trees -> RandomForest. Note here you can click Random Forest to modify more details about the model like number of trees.
* Step (4). In "Test options", click "Cross-validation", you can choose Folds as 10
* Step (5). Click "Start" button, it will run the training process
* Step (6). After training done, the results will be displayed in Classifier output.In the left downside, you can see a new ino shows the time with the model name:
           e.g., 13:23:45 - trees.RandomForest, right click this one, then select "save model", you can choose the directory you want to save and name it. 
           Then the training model is saved.
* Step (7). To use the trained model, in this same place, you can right click the blank spalce, then select "load model", you can load the model you just saved. 

That's just how to do the test (prediction) work when you want to use the training model. 

Options 2: use command line to do the training work
here is an example about using models with multiple classifiers, please use your 
 own and modify more details to use other model
 here is the official docu: https://www.cs.waikato.ac.nz/~remco/weka_bn/node13.html
 https://weka.sourceforge.io/doc.dev/weka/classifiers/meta/FilteredClassifier.html
```
# -t : training file
# -T : test file
# -W : classifier_name
# -F filter_specification, followed by filter options
java -classpath weka.jar weka.classifiers.meta.FilteredClassifier \
  -t ~/weka-3-7-9/data/ReutersCorn-train.arff \
  -T ~/weka-3-7-9/data/ReutersCorn-test.arff \
 -F "weka.filters.MultiFilter \
     -F weka.filters.unsupervised.attribute.StringToWordVector \
     -F weka.filters.unsupervised.attribute.Standardize" \
 -W weka.classifiers.trees.RandomForest -- -I 100 \
 

# Examples in our case .........

WEKA_FILE_PATH=/home/ubuntu/opt/weka-3-9-4/weka.jar
ARFF_FILE_PATH=/home/ubuntu/optimal_unified_memory/data/performance_results_dataset/GPU_dataset.arff

java -classpath $WEKA_FILE_PATH weka.classifiers.functions.Logistic -x  -t $ARFF_FILE_PATH  # use Logistic to train, then get the Logistic model, may need to mannually save the model

java -classpath $WEKA_FILE_PATH weka.classifiers.trees.J48  -T $ARFF_FILE_PATH -l J48.model # use J48 model to test
```
# Step 5. Use the model to predict a new kernel’s object policies

Option 1: To use  Weka software interface for the prediction. 
(i) Pre-processing: 
Open the test data set file in csv file, replace the last column 'labelled' with "?". This serves as a placeholder to store the predicted classes. 
Add the necessary headers and save as .arff file format.

(ii) Prediction
* Step (1). Open Weka, click "Explorer", go to the new Explorer interface
* Step (2). Click "Classify", then load the saved model (.model format that is saved after training) 
* Step (3). Select the Test options->Supplied test set option to choose the test data set file generated after pre-processing. In 'More options' check the 'Output Predictions" format to "plain text".
* Step (4). Right click on the model and choose "Re-evaluate model on current test set".
* Step (5). The 'Classifier Output' pane shows the predictions in 5-column format " inst#     actual  predicted error prediction". The 2nd column is the ground truth/Labelled data and 3rd column is the predicted class. The 4th column 'error' shows a "+" symbol if there are any mispredictions and the last column shows the probability distribution.
* Step (6) Evaluate the number of correctly predicted instances among all instances. This gives the predicition efficiency of the trained model on a test data set. 

(iii) Evaluation of overheads
* Step (1). Use a script to run the command to train and test via the Weka model. Here is one sample:
```
java -classpath CLASSPATH:weka.jar weka.classifiers.trees.RandomForest -x 5 -t ~/lassen_dataset.arff -T ~/lassen_dataset.arff
```
* Step (2). Add timestamp in the script to count the time for the above processing
* Step (3). Get the execution time of specific benchmark in the IBM/Intel machine
* Step (4). The test time from Weka is for the test of entire dataset. If this time is much larger than the execution time of one benchmark, use the test time divide by the number of instances in the dataset, we can get the test time for one specific instance, then calculate the percentage of overhead.

