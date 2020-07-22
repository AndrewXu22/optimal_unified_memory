Readme: python sklearn files

Overview:


Most scikit-learn libraries cannot handle categorical features. Both the script and GUI handle this by one hot enoding them. The 
name of the new features are "Feature name_label".

Python Libraries required:

Scikit-learn
Pandas
skl2onnx
onnxruntime

Script (offline_trainer.py):

The script takes in three arguments. To run the script, use the following command:

python modelLearner.py InputFile ModelName OutputFilename

The InputFile is the csv fiel with features and labels, the ModelName is the name of the model used on the data and OutputFilename
is the name of the onnx file that will be created when the model is trained. The options for ModelName are:

-DecisionTree
-RandomForest
-SVM
-Bagging
-Adaboost

GUI (modelLearnerGUI):

The GUI allows you to read in a csv file and will dislay the currently opened file. You can choose what model to use and
how many cross validations to use to test. If you click the "Classify and Test" button you will train the model on all the data.
You will also get as an output the accuracy when trained on the whole model, the average accuracy on over all k folds and the time
taken to create the model when trained on all the data
