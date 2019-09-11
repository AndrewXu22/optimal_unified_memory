#!/bin/bash

#this is a script about the offline training model creation, it includes data collection, data normalization, model training

cd /Users/xu20/Documents/LLNL_work/prototype_llnl/output_to_arff

#1. Run nsight with benchmark to get all metrics
#Here needs: (a). nsight from root access (b). benchmark and input data files (assume you already put here)
#(c). feature list file that contains the metrics nsight can fetch
#(d). specify the path where to store the collected metrics
# More details: 
#   (a). find the proper path to "nv-nsight-cu-cli"
#   (b). --metrics collect the features from the related feature list file 207.txt, so need to put the 207.txt in the directory
#   (c). --csv store the collect logs into csv file
#   (d). ./benchmarks/bfs/bfs_adapt_00 ./benchmarks/data/bfs/graph65536.txt use the benchmark with input file
#   (e). >> ./logs/nsight_bfs_UM  store the logs with csv format into "nsight_bfs_UM" file

sudo /usr/local/cuda-10.1/NsightCompute-2019.3/nv-nsight-cu-cli --metrics $(./207.txt)  --csv ./benchmarks/bfs/bfs_adapt_00 ./benchmarks/data/bfs/graph65536.txt >> ./logs/nsight_bfs_UM


#2. Run script to format the collected csv logs into the train dataset
# here need to put the python script into the directory

#you can modify the output file name in the logs_format_to_dataset.py
python logs_format_to_dataset.py

#3. Use weka to format the train set in arff and normalize the dataset
java -cp ./weka.jar weka.core.converters.CSVLoader train.csv > train.arff

java -cp ./weka.jar weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0 -i train.arff -o train_normalized.arff

#4. Train a model with the training dataset

#here is an example about using models with multiple classifiers, please use your own and modify more details to use other model
#here is the official docu: https://www.cs.waikato.ac.nz/~remco/weka_bn/node13.html
java -classpath weka.jar weka.classifiers.meta.FilteredClassifier \
  -t ~/weka-3-7-9/data/ReutersCorn-train.arff \
  -T ~/weka-3-7-9/data/ReutersCorn-test.arff \
 -F "weka.filters.MultiFilter \
     -F weka.filters.unsupervised.attribute.StringToWordVector \
     -F weka.filters.unsupervised.attribute.Standardize" \
 -W weka.classifiers.trees.RandomForest -- -I 100 \