#!/bin/bash

# This is a script to create the offline training model. 
# It includes several steps such as
#    data collection, 
#    data normalization, and 
#    model training. 

#----------Prerequisites---------
# Hardware and Software configuration
# Weka can be installed on 
# OS: Ubuntu 18.04.4 LTS
# sudo apt-get update -y
# sudo apt-get install -y weka

#-------------Baseline Data Collection ----------------------------
#1. Run nsight with benchmarks to get all metrics
# This step will run a program and obtain profiling data.
#Here is what is needed: 
# (a) nsight from root access 
# (b) benchmark and input data files (assume you already put here)
# (c) feature list file that contains the metrics nsight can fetch
# (d) specify the path where to store the collected metrics


# build an example benchmark program: rodinia's bfs
# Enter to the top level directory of this git repo
cd ../.

# build the runtime adaptor # TODO: is this the right step?
make -C ./rodinia_3.1/cuda-adapter clean
make -C ./rodinia_3.1/cuda-adapter

# This environment variable depends on where you cuda is installed.
export CUDA_HOME=/usr/local/cuda-10.2
# build the BFS programs
make -C ./rodinia_3.1/cuda/bfs clean
make -C ./rodinia_3.1/cuda/bfs 
# two executables will be gnerated: bfs and bfs_adapt
#TODO: The build may fail: 

# More details: 
#   (a) find the proper path to "nv-nsight-cu-cli"
#   (b) --metrics collect the features from the related feature list file 207.txt, 
#     so need to put the ./test_740_feature/207.txt into the current directory.
#   (c) --csv store the collect logs into csv file
#   (d) ./benchmarks/bfs/bfs_adapt_00 ./benchmarks/data/bfs/graph65536.txt use 
#       the benchmark with input file
#   (e) >> ./logs/nsight_bfs_UM  store the logs with csv format into "nsight_bfs_UM" file

# usually you need to use sudo with nsignt compute
# sudo /usr/local/cuda-10.1/NsightCompute-2019.3/nv-nsight-cu-cli
# On LLNL's LC machines, Nsight is installed/configured that you don't need sudo
# to run.

# TODO: confirm the workflow: we use the original version to collect metrics
# not the adapt version. 

# we use cfd to test this command first:
# we use bfs_adapt to test this command first:
# --metrics: specify all metrics to be profiled, the metric names are from a text file
# --csv: use comma-separated values in the screen output
# bfs 
# Note: to facilitate processing of the output files, we use a convention of 
# prefix nsight_* for all generated text files storing profiling metric values.
# A later python script will use this prefix to find/process all profiling files for a program.
sudo nv-nsight-cu-cli --metrics $(<./test_740_feature/207.txt) --csv ./rodinia_3.1/cuda/bfs/bfs ./rodinia_3.1/data/bfs/graph65536.txt > ./data_and_logs/Rodinia_bfs/nsight_bfs_65536.log

# Note: if it complains nv-nsight-cu-cli cannot be found, it can be caused by the path to 
# nv-nsight-cu-cli is not set within the sudo account. 
# You can use the absolute path to nv-nsight-cu-cli
# e.g. sudo /usr/local/cuda-10.2/bin/nv-nsight-cu-cli ... 

# We save a sample output to the following file as a reference.
# data_and_logs/Rodinia_bfs/nsight_bfs_65536.log.example

# TODO: How to extract the working 207 metrics on a new system?
# TODO: the 207 metrics do not overlap with the metric sets I got on Volta.
# https://gitlab.com/DATA-PLACEMENT-LDRD/optimization_unified_memory/-/issues/36

#-------------Data Formatting----------------------------
#2. Run the python script to format the collected csv logs into the train dataset
# here need to put the python script into the directory
# 
# Why need reformat? Right now the fetched metrics are in the original formats. 
# But the data used for the machine learning model or Weka need another format. 
# So we need to change the format of the original metrics into the normal format 
# that machine learning model can process, the normal format is like
# this: < f1, f2, f3,.. fn, label >. 
#
# Now let's focus on the features not the label, we will talk about label in next step.
# To normalize original metrics into feature set, we need to use "logs_format_to_dataset.py" 
#    the input : original mertics file that extractData.py feteched
#    the output: a new csv file that contain reformatted features
# "logs_format_to_dataset.py" will keep all feature name with theire specific values into one set like :
# kenel_info	ID	benchmark_name	Memory Frequency	SOL FB	Elapsed Cycles	SM Frequency
# cuda_compute_flux	0	cfd1	877401025.3	0.74	640492	1234468931	2.32	518112  xxx xxx
# cuda_compute_flux	1	cfd1	875906527	0.75	637110	1232146777	2.34	516256  xxx xxx
# cuda_compute_flux	2	cfd1	889706336.9	0.74	648930	1252215997	2.31	517600  xxx xxx

# This script will find all profiling result files with a prefix nsight_* and 
# merge and format them into a training data set.
# You must run this script within a director with nsight_* log files
# sample logs files are located in
# ./data_and_logs/cfd_nsight_5classes/nsight_cfd2M00001
# ./data_and_logs/cfd_nsight_5classes/nsight_cfd2M00002
# ./data_and_logs/cfd_nsight_5classes/nsight_cfd2M00003

#again, we will use the sample file within data_and_logs/Rodinia_bfs to show 
# how to use this script:
cd data_and_logs/Rodinia_bfs
python ../../prototype/logs_format_to_dataset.py

# The script will read all nsight_* files under the current path and generate 
# a training data set file dataset.csv
# an intermidate file interim_logs.csv will also be generated. You can ignore this file
# A sample dataset.csv is provided as a reference: 
#   data_and_logs/Rodinia_bfs$ vi dataset.csv.sample

#-------------Finding the best Code Variants----------------------------
#3. The labeling step is to find the best performing code variants and record
# the best memory use option. 
#
# To complete the labeling work, we need to use the runtime latency to find the 
# minimal latency (best performance with specific advice) to do it, we need to 
# mannually add the advice into the benchmark, note here we need to think about 
# the advice in the kernel level or data object level, if we choose kernel level, 
# for the data objects in each kernel, we need to give same advice; if we choose
# data object level, we need to give different advice for each data obejct

# TODO: how to prepare a program to be adaptive.
# After giving new advice, we run them and get the runtime latency. 
cd rodinia_3.1/cuda/bfs

# Compile different variants of bfs_adapt: a set of bfs_adapt_xxx will be generated.
# You need to adjust the paths in compile.sh, depending on your machine environment
# TODO: what is m, i, and j in the script? 
# All executables are output to data-level-measurement/lassen
# i,j,k variables represent arrays used for different memory advises
# each array has options 0-7; 0 uses discrete memory, 1 uses unified memory with no
# memory advise, 2 to 6 use unified memory with different advises. 
./compile.sh 

# Run the code variants with different input data sizes 
cd rodinia_3.1/cuda/bfs/data-level-measurement

./run.sh # generate a set of log files like output_165_graph65536.log

outputs are currently collected in data-level-measurement/lassen-log 
# Two sets of output will be generated:
# 1. output* files represent measurement of time for each kernel
# 2. GPUTrace* files represent data collected to measure data-level details

# Next, we use the script to extract the runtime latency from the log files.
#extractData.py is used to normalize all runtime latency into one file, so we can find the minimal latency
python ../../../../prototype/extractData.py  # this will generate a .csv file in the current path

# TODO: provide sample csv output file so users know what to expect

# Assume now you have the file of execution latency: bfs_stat.csv ?
# TODO: need sample input and output file content so readers know what to expect.


#-------------Attaching Labels----------------------------
#4. We next manually attach the labels we get from Step 2 to the formatted dataset

# Now you need to complete the labeling work (Manul Work, do no use script), assume you already 
# have the runtime latency of each benchmark (in hotspot_stat.csv), you need to 
# select the modified one with minimal latency, for example, if hotspot with 
# ReadMostly advice has the minimal latency, you can label the data in the set 
# as <hotspot metrics, ReadMostly>. Note the lable can be given in the kernel 
# level or data object level, this depends on the policy that we modify the 
# benchmark in kernel or data object level.
# Note: when labeling the test data from new dataset, still following the same 
# role when collecting and labeling the training data

# Data before labeling:
# kenel_info	ID	benchmark_name	Memory Frequency	SOL FB	Elapsed Cycles	SM Frequency xxx
# cuda_compute_flux	0	cfd1	877401025.3	0.74	640492	1234468931	2.32	518112  xxx
# cuda_compute_flux	1	cfd1	875906527	0.75	637110	1232146777	2.34	516256  xxx
# cuda_compute_flux	2	cfd1	889706336.9	0.74	648930	1252215997	2.31	517600  xxx

# Data after labeling: (sample, not real results)
# kenel_info	ID	benchmark_name	Memory Frequency	SOL FB	Elapsed Cycles	SM Frequency	Label
# cuda_compute_flux	0	cfd1	877401025.3	0.74	640492	1234468931	2.32	518112   ReadMostly
# cuda_compute_flux	1	cfd1	875906527	0.75	637110	1232146777	2.34	516256  PreferredLocation
# cuda_compute_flux	2	cfd1	889706336.9	0.74	648930	1252215997	2.31	517600   AccessedBy


#-------------Normalize the training dataset----------------------------
#5. Use weka to format the train set in arff and normalize the dataset
# note that before to use models in weka, you need to 0-1 normalize the original data, you can use the function
# in Weka to do that, this will change the original dataset into following format:
#
# Go to Weka, select "Explorer", then in the new window, click "open file", choose the dataset file, then in
# the "filter", click "choose", select "weka-filters-unspervised-attribute-Normalize", then click "apply", the dataset 
# will be normalzied, sample format like below: (for easy use, u can delete the first coloum about kenel_info )

# ID	benchmark_name	Memory Frequency	SOL FB	Elapsed Cycles	SM Frequency	Label
# 0	cfd1	0.32	0.74	0.4	0.9	0.4	0.8   ReadMostly
# 1	cfd1	0.45	0.75	0.8	0.9	0.4	0.72  PreferredLocation
# 2	cfd1	0.87	0.74	0.6	0.8	0.4	0.76   AccessedBy

java -cp ./weka.jar weka.core.converters.CSVLoader train.csv > train.arff

# this step is the commandline method for dataset normalization, you can use it or use Weka GUI interface.
# command line help info. https://weka.sourceforge.io/doc.dev/weka/filters/unsupervised/attribute/Normalize.html
# -S <num> : The scaling factor for the output range. (default: 1.0)
# -T <num> : The translation of the output range.  (default: 0.0)
# default range is [0,1]: new_range = default*scale + translation
java -cp ./weka.jar weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0 -i train.arff -o train_normalized.arff


#-------------Selecting useful features----------------------------
# Useful metrics are selected by using feature correlation and information gain algorithms in Weka. 

# Feature correlation can select the most relevant features from the dataset, 
# and information gain algorithm can select features that can contribute to high information gain value.
#
# Step 1: To select features, you can open Weka. in Explorer, select the dataset, then click the button "Select Atttributes"
#   In this table, use "Attributer Evaluator" to choose the algorithm you want to use, such like "InfoGainAttributeEval"
#   then in "Attribute Selection Mode", you can select "Crooss-validation", then click "start" button,
#
# Step 2: Results will be displayed in the output, you can check the average merit with values and average rank with attributes
#   How to select the proper features is based on the personal view, you can chooose the top 20 features in rank, or the 
#   features that have value large than a threshold (e.g., 0.9), then select the subset
# 
# Step 3: next can go back to Preprocess, select the reduced features and create a new dataset, use the new dataset in "Classify"
#   to run cross validation to see if the results are still good, (good mean the TP rate, Precision, Recall, F-Measure maintains high valus e.g. 0.95)
# Step 4: if the results are good, you can go back to Step 1, reduce several features, e.g. choose the top 15 features,
#   then create a new dataset to evaluate it and repeat these steps.
#
# Step 5: when you reduce the features into minimal number (means if you reduce one more feature, the classify results will be greatly impacted with lower performance)
#   the feature selection process can be done.



#-------------Train a Model----------------------------
#6. Train a model with the training dataset

# Option 1: use the Weka software interface to do the training work
# Step (1). Open Weka, click "Explorer", go to the new Explorer interface
# Step (2). Click "Open file", then select the training set in .arff format, then it will display the details of dataset with attributes and class, etc.
# Step (3). Click "Classify" button in the upside, then click "choose", where allows you to select the model you want to use
#           e.g., choose -> trees -> RandomForest. Note here you can click Random Forest to modify more details about the model like number of trees.
# Step (4). In "Test options", click "Cross-validation", you can choose Folds as 10
# Step (5). Click "Start" button, it will run the training process
# Step (6). After training done, the results will be displayed in Classifier output.In the left downside, you can see a new ino shows the time with the model name:
#           e.g., 13:23:45 - trees.RandomForest, right click this one, then select "save model", you can choose the directory you want to save and name it. 
#           Then the training model is saved.
# Step (7). To use the trained model, in this same place, you can right click the blank spalce, then select "load model", you can load the model you just saved. 
#           That's just how to do the test (prediction) work when you want to use the training model. 


# Options 2: use command line to do the training work
# here is an example about using models with multiple classifiers, please use your 
# own and modify more details to use other model
# here is the official docu: https://www.cs.waikato.ac.nz/~remco/weka_bn/node13.html
# https://weka.sourceforge.io/doc.dev/weka/classifiers/meta/FilteredClassifier.html
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
