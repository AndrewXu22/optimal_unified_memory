#!/bin/bash

#This is the script normalizes metricss into test dataset, then use the offline trained model
#to get the prediciton of unified memory advice, finally implement the new 
#advice into the benchmark code

#1. Run script to format the collected csv logs into the test dataset
# here need to put the python script into the directory

#you can modify the output file name in the logs_format_to_dataset.py
python logs_format_to_dataset.py

#2. Use weka to format the test set in arff and normalize the dataset
java -cp ./weka.jar weka.core.converters.CSVLoader test.csv > test.arff

java -cp ./weka.jar weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0 -i test.arff -o test_normalized.arff

#3. Use the offline trained weka model to get perdiciton on test dataset

java -cp ./weka.jar weka.classifiers.trees.J48 \
-classifications "weka.classifiers.evaluation.output.prediction.CSV" \
-T test_normalized.arff -l ./J48.model \
|tail -n+5  >> ./label.txt

#4. Here to find the correct label for the benchmark and then update the benchmark code

python find_advice_for_benchmark.py  #here should add a para to transfer the name of benchmark

cd $HOME/prototype_llnl/benchmark

#here to make the benchmark and get new app with advice
make
