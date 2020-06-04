#!/bin/bash 

WEKA_FILE_PATH=/home/ubuntu/opt/weka-3-9-4/weka.jar
ARFF_FILE_PATH=/home/ubuntu/public-github/optimal_unified_memory/data/performance_results_dataset/lassen_dataset.arff

SECONDS=0

#  java -classpath CLASSPATH:weka.jar weka.classifiers.trees.RandomForest -I 100 -x 10 -t ~/lassen_dataset.arff
# java -classpath weka.jar weka.classifiers.meta.FilteredClassifier -t ~/lassen_dataset.arff -W weka.classifiers.trees.RandomTree -- -K 100
# java -classpath weka.jar weka.classifiers.meta.FilteredClassifier -t ~/lassen_dataset.arff -W weka.classifiers.functions.Logistic
# java -classpath weka.jar weka.classifiers.meta.FilteredClassifier -t ~/lassen_dataset.arff -W weka.classifiers.bayes.NaiveBayes
java -classpath $WEKA_FILE_PATH weka.classifiers.functions.Logistic -x  -t $ARFF_FILE_PATH  # use Logistic to train, then get the Logistic model, may need to mannually save the model
java -classpath $WEKA_FILE_PATH weka.classifiers.trees.J48  -T $ARFF_FILE_PATH -l J48.model # use J48 model to test

duration=$SECONDS
  echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds  elapsed."
 echo RandomForest: "$(($duration / 60)) minutes and $(($duration % 60)) seconds  elapsed." > test.txt;


#sar -u 1 5
#top -d 1 >11.txt
#top -n 1 -b
#free -k;
#/> watch -d -n 1 'df -h; ls -l'
