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
* a GPU machine running Ubuntu 18.04 LTS
* p3.2xlarge: AWS vm instance with Volta GPU 
* Nvidia CUDA toolkit 10.2: nvcc --version, V10.2.89
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

You may need to use sudo to run the script since it uses nv-nsight-cu-cli to collect hardware counter information. Or you may get the error message like "The user does not have permission to access NVIDIA GPU Performance Counters".  

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

# Step 2. Merge kernel and object level features 

The Merge script: 
* ./prototype/merger.py

You need to make sure 
```
df1 = pd.read_csv("./kernel-level-measurement/dataset.csv")
df2 = pd.read_csv("./data-level-measurement/GPUTrace.csv")
```
e.g. run it  under ~/optimization_unified_memory/rodinia_3.1/cuda/cfd
python3 $PATH_TO_PROJECT/scripts/labeler-v2.py 

Output of merged data:
* ./rodinia_3.1/cuda/cfd/mergedDataSet.csv

A similar file for aws volta machine: mergedDataSet-ip-128-115-246-7.csv 

Command to run merger:
* python3 $PATH_TO_PROJET/optimization_unified_memory/prototype/merger.py


Merged_feature = Kernel_vector X Object_vector


M (K1-A-B) = [ < f(K1) + f(A) > // feature vector length (n+m)
                       <  f(k1) + f(B)> ]

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

Generate kernel-based run for all variants:
* ./rodinia_3.1/cuda/cfd/run_variants.sh

./rodinia_3.1/cuda/cfd$ nohup ./run_variants-v2.sh &

Outputi sample:
* ./rodinia_3.1/cuda/cfd/ip-128-115-246-7-kernel-level-measurement/variants 
There should be 7*7*7*3 = 1029 log files :up to 3 objects, each 7 variants, 3 input data sizes for cfd

Post-process script:
*./scripts/extractData.py

Command: 
* python3 $PATH_TO_PROJECT/scripts/extractData.py

Outputi Summary in csv: 
* ./rodinia_3.1/cuda/cfd/kernel-level-measurement/data-level-measurement/GPUTrace.csv

Best-performed data group by kernel and inputdata:
https://gitlab.com/DATA-PLACEMENT-LDRD/optimization_unified_memory/-/blob/master/rodinia_3.1/cuda/cfd/kernel-level-measurement/lassen-log/kernel-data-best.csv


Applying Labels:
Script:
* ./scripts/labeler.py
Command:
```
cd $PATH_TO_PROJET/optimization_unified_memory/rodinia_3.1/cuda/cfd
Python3 $PATH_TO_PROJET/prototypes/labeler.py
```

Output labelled data:
* ./rodinia_3.1/cuda/cfd/labelledData.csv

Add label into the merged feature vector
* <Kernel-feature, data-object-feature, label>

// How to label the data with object level adaptation ： assuming 7 options for data placement
best execution of variants: 
* SC paper:  object variants: each object within a kernel, different placement  policies 
* Once we find the best performing one of the 49 variants.: we use the labels for each data object . 

Currently the kernel-level results (using minimum nvprof option) is collected at 
./rodinia_3.1/cuda/cfd/data-level-measurement/dataset.csv

We can sort the csv file to find the best execution time for each kernel.
  
cuda_compute_flux,0.2M,0,000,66.45,402.5463,6000,0.067091,0.058240,0.070912

Labeled_Vector =  M_Vector + Labels

Key components: Kernel, input, array object, features ,label

			< 8991, 3520, 9.27, 9982, 334, 42, 3, policy>   
			< 8991, 3520, 9.27, 3434, 78, 83, 123, policy> 

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
* The sample data has a total 499 (498?) instances, and I keep all features.
* Dataset sample is here: 
    https://drive.google.com/file/d/1K_JETvyH4pY8X7ua3CJastjcDmMpb6fy/view?usp=sharing
* Normalized dataset:
    https://drive.google.com/file/d/1mAvaauCsGCXEqgd-CuGnB-j23czTWKBu/view?usp=sharing
    Note: When using it, please remove the first four features (InputData, Kernel, Data, DataId) in Weka.
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
```

