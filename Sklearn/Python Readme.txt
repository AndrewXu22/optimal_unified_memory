Readme: python sklearn files

Overview:

Most scikit-learn libraries cannot handle categorical features. Both the script and GUI handle this by one hot enoding them. The 
name of the new features are "Feature name_label".

Python Libraries required:

Scikit-learn
Pandas
skl2onnx
onnxruntime
hyperopt?

Script (offline_trainer.py):
The script requires at least three arguments. To run the script, use the following command:

python offline_trainer.py InputFile OutputFilename (manual or automatic)

The InputFile is the csv file with features and labels, the ModelName is the name of the model used on the data and OutputFilename
is the name of the onnx file that will be created when the model is trained. 
	
You must choose whether you do manual training (specify a model type and optionally its hyperparameters) or use automatic training 
(where multiple models are run and the best performing one is chosen)

1) Manual 

-m (manual) ModelName 

The options for ModelName are:

-DecisionTree
-RandomForest
-SVM
-Bagging
-Adaboost
-GradientBoost

The default hyperparameters will be used unless you specify specific hyperparameters of the model. Look at the sklearn documentation online 
to see what these are for a given model type. 

The format for the hyperparameters is: 

option1,value1,option2,value2,...

ex: 

python offline_trainer.py InputFile OutputFilename -m DecisionTree criterion,entropy,max_depth,5

b) -o (optimize). This option attempts to optimize over a single model type

Modelname is required

0: Grid search (can specify range or use default values)
1: Random search (can specifiy range and number of iterations or use default values)
2: TODO: perform bayesian optimization on all models (can specifiy range and number of iterations or use default values)

ex:
python offline_trainer.py InputFile OutputFilename -o Bagging 1

there are additional options you can pass

i) Format of grid range:

range,parameter1,array,parameter2,array

How parameters should be specified:
Dictionary: {parameter:value;parameter:value}
array: [value;value;value]
float: 1.5
int: 4
string: gaussian
bool: True

ii) Format of iterations

iters,num

ex: 
iters,5

iii) Number of fold (cross-validation)

kfolds,number

ex:

kfolds,5

Note for all these additional options (i,ii, adn iii) they must be passed as one single additional list. For example, if you wanted to
have a certain number of kfolds and iterations with a randomized search, you could pass in:

python offline_trainer.py InputFile OutputFilename -o DecisionTree iters,5,kfolds,15

c) -a (automatic). This option checks every type of model and chooses the best one

0: Check all models with default hyperparameters
1: Perform Grid search on all models (can specifiy range for each or use default values)
2: Perform random search on all models (can specifiy range and number of iterations or use default values)
3: TODO: perform bayesian optimization on all models (can specifiy range and number of iterations or use default values)

ex: 
python offline_trainer.py InputFile OutputFilename -a 0

This does not take in additional arguments like the -o setting does

GUI (modelLearnerGUI):

The GUI allows you to read in a csv file and will dislay the currently opened file. You can choose what model to use and
how many cross validations to use to test. If you click the "Classify and Test" button you will train the model on all the data.
You will also get as an output the accuracy when trained on the whole model, the average accuracy on over all k folds and the time
taken to create the model when trained on all the data