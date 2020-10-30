This repo contains the instructions, scripts, and codes needed to reproduce the
experiments for our SC paper named:
"XPlacer: A framework for Guiding Optimal Use of GPU Unified Memory"

Overview of major steps
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
* Weka : https://waikato.github.io/weka-wiki/downloading_weka/#linux_1

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
* ./rodinia_3.1/cuda/cfd/kernel-level-measurement/GPU-log/kernel-data-best.csv

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
* Dataset samples are here: 
   https://github.com/AndrewXu22/optimal_unified_memory/blob/master/example/IBM_2688_13features.arff
   https://github.com/AndrewXu22/optimal_unified_memory/blob/master/example/AWS_4878_13features.arff 
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

