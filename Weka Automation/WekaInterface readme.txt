WekaInterface readme

To use this, you need to have java and Weka installed and have the environemntal variables set (JAVA_HOME and WEKA_JAR_PATH)

This script helps build, test and predict with models in Weka.  To do this, there are three possible flags with different inputs that perform each of these functions:

1) -b (stands for build)

Format: 

WekaInterface -b inputFilename modelChoice outputFilename optionalAddtionalArguments

This takes in a set of data (contained in inputFilename, which should be a csv or arff file. It is necessary to specify the file extension), a choice of model and an
output filename (no file extension needs to be specified). The options for models are (these options are case sensitive):

1) DecisionTree (J4.5 decision tree)
2) RandomTree 
3) RandomForest
4) REPtree
5) Bagging

Addtional arguments (like filters) can be added. See weka documentation to see the structure of these.

This will save the model as outputFilename_typeofmodel.model (see the other flags for why the _typeofmodel is added). 

Ex: WekaInterface -b data.csv RandomForest builtModel  

2) -t(stands for test)

Format:

WekaInterface -t modelFile dataFilename 

This flag runs the model on a set of labelled data and prints out relevent statistics for how the model performed (accuracy, confusion matrix e.t.c.). The 
dataFilename shoudl be in the csv or arff filetype and the extension should be specified. 

NOTE: Model filenames must be formated with the model type written into the name for this to work. Models built with the build flag will automatically be named properly.

3) -p (stands for predict)

Format:

WekaInterface modelFile trainingFilename dataToPredictFilename outputFilename 

NOTE: as before, the model filename must be formatted properly, which is done automically by the build flag option.

This takes in a model (saved as a .model file) and the file it was trained on (trainingFilename, which should be a csv with the extension specified) and 
a file with data points to predict in a csv file (dataToPredictFilename). It saves the predictions in a csv with the name specified in outputFilename.

The dataToPredictFilename should have the same features as used to train the model. The final column of the csv should all be marked as ? (i.e. with no
prediction for the values we are trying to clasiffy).

