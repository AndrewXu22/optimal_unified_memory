"""
Script to train model based on csv 
arguments: input_filename saved_filename model_type hyperparamters (optional)
"""
import sklearn as sk
from sklearn import ensemble
from sklearn.metrics import make_scorer
import sklearn.model_selection as model_selection
from sklearn.ensemble import GradientBoostingClassifier
from sklearn import preprocessing
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score
import sklearn.svm as svm
from sklearn import tree
import os
from tkinter import filedialog
import pandas as pd
import numpy as np
import pickle
import time
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
import numpy as np
import sys
#from hyperparameterOptimization.py import *

DEFAULT_ITERS = 20
DEFAULT_K_FOLDS = 10

''' Helper Functions '''
def is_float(x):
    try:
        a = float(x)
    except ValueError:
        return False
    else:
        return True

def is_int(x):
    try:
        a = float(x)
        b = int(a)
    except ValueError:
        return False
    else:
        return a == b

def default_grid_values(model):
    
    if(model == 'DecisionTree'):
        return {
            'criterion': ['gini','entropy'],
            'max_depth': [5,10,15,None]  
            }
    elif(model == 'RandomForest'):
        return {
            'n_estimators': [50,100,150,200,250,300],
            'max_features': ["auto","sqrt","log2"],
            'max_samples': [0.33,0.5,1.0]
            }
    elif(model == 'SVM'):
        return {
            'C': [0.1, 1, 10, 100, 1000],  
            'gamma': [1, 0.1, 0.01, 0.001, 0.0001]
            }
    elif(model == 'Bagging'):
        return {
            'n_estimators': [5,10,15,20,25,30],
            'max_samples': [0.33,0.5,1.0],
            'max_features': [0.33,0.5,1.0]
            }
    elif(model == 'Adaboost'):
        return {'n_estimators': [100,200,300],
                'learning_rate': [0.33,0.5,1.0]
                    }
    elif(model == 'GradientBoost'):
        return { 'n_estimators' : [100,200,300], 
                'learning_rate': [0.1,1,10,100],
                'max_depth': [3,5,7,9],
                'max_features': ["auto", "sqrt", "log2"]
            }
    else:
        print("ERROR: " + model + " is not a valid model type")
        return None
    
    return 

def interpret_type(var):
    #Dictionary - recursive
    if(var[0] == '{'):
        dictionary_list = var.split(';')
        var_dict = {}
        
        del dictionary_list[-1]
        del dictionary_list[0]
        
        for i in range(0, len(dictionary_list), 2):
            var_dict[interpret_type(dictionary_list[i])] = dictionary_list[i + 1]
            
        return var_dict
    
    #Array
    if(var[0] == '['):
        array_list  = var.split(';')
        var_array = []
        
        del array_list[-1]
        del array_list[0]
        
        for i in range(0, len(array_list)):
            var_array.append(interpret_type(array_list[i]))
            
        return var_array
    
    #Int     
    if(is_int(var)):
        return int(var)
    
    #Float
    if(is_float(var)):
        return float(var)
        
    #Bool
    if( (var == 'True') | (var == 'False') ):
        return bool(var)
    
    #String
    else:
        return var
      
def extract_iters_kfolds_and_grid_values(additional_vars,model):
    iters = DEFAULT_ITERS
    kfolds = DEFAULT_K_FOLDS 
    grid_values = {}
    
    hasGridBeenPassed = False
    
    list_vars = additional_vars.split(',')
    
    for i in range(0,len(list_vars)):
        word = list_vars[i]
        if(word == 'iters'):
            i += 1
            iters = list_vars[i]
            continue
        elif(word == 'range'):
            hasGridBeenPassed = True
            i += 1
            while(i + 1 < len(list_vars) & list_vars[i] != 'iters'):
                grid_values[interpret_type(list_vars[i])] =  grid_values[interpret_type(list_vars[i+1])]
            continue

        elif(word == 'kfolds'):
            i += 1
            kfolds = list_vars[i]
            continue
    
    if (hasGridBeenPassed != True):
        grid_values = default_grid_values(model)
    
    return kfolds,grid_values,iters
                
                
def choose_model(model,hyperparams_dict):
    if(model == 'DecisionTree'):
        return tree.DecisionTreeClassifier(**hyperparams_dict)
    elif(model == 'RandomForest'):
        return ensemble.RandomForestClassifier(**hyperparams_dict)
    elif(model == 'SVM'):
        return svm.SVC(**hyperparams_dict)
    elif(model == 'Bagging'):
        return ensemble.BaggingClassifier(**hyperparams_dict)
    elif(model == 'Adaboost'):
        return ensemble.AdaBoostClassifier(**hyperparams_dict)
    elif(model == 'GradientBoost'):
        return GradientBoostingClassifier(**hyperparams_dict)
    else:
        print("ERROR: " + model + " is not a valid model type")
        return None
         
def process_input_file(input_file):
    numColumns = len(input_file.columns)
    X_input = input_file.iloc[:,0:(numColumns - 1)]
    y = input_file.iloc[:,(numColumns - 1): (numColumns)]

    '''Deal with Categorical Features'''
    categoricals = X_input.select_dtypes(include=['object'])
        
    if (not categoricals.empty):
        ohe_categoricals = pd.get_dummies(X_input.select_dtypes(include=['object']).copy())
    else:
        ohe_categoricals = categoricals
    
    X = pd.concat([X_input.select_dtypes(exclude=['object']), ohe_categoricals],axis = 1)       
    feature_labels = X.columns.values[0:]
    
    X = X.to_numpy()
    y = y.to_numpy()  
    return X,y,feature_labels

def print_accuracy_and_save_model(clf,trainedModel,save_filename):
    skf = StratifiedKFold(n_splits=10, shuffle = True)
        
    stratifiedAccuracy = 0.0
    
    for train_indices, test_indices in skf.split(X, np.ravel(y)):
        clf_test = clf.fit(X[train_indices],np.ravel(y[train_indices]))
        y_pred = clf_test.predict(X[test_indices])    
        stratifiedAccuracy += accuracy_score(y[test_indices], y_pred) *100
    
    print("Average accuracy over cross-validated sets is " + str(stratifiedAccuracy/10) + "%\n\n")
    
    initial_type = [('float_input', FloatTensorType([None, 4]))]
    onx = convert_sklearn(trainedModel, initial_types=initial_type)
    with open(save_filename + ".onnx", "wb") as f:
        f.write(onx.SerializeToString())
        
    return 

def stratifiedKFoldAccuracy(clf,X,y):
    skf = StratifiedKFold(n_splits=10, shuffle = True)
    
    stratifiedAccuracy = 0.0

    for train_indices, test_indices in skf.split(X, np.ravel(y)):
        clf_test = clf.fit(X[train_indices],np.ravel(y[train_indices]))
        y_pred = clf_test.predict(X[test_indices])    
        stratifiedAccuracy += accuracy_score(y[test_indices], y_pred) *100
    return stratifiedAccuracy/10.0
    
'''Start of script  '''

input_args = sys.argv

input_file = pd.read_csv(input_args[1])  
save_filename = input_args[2] 
learning_type_flag = input_args[3]

#Manual
if(learning_type_flag == "-m"):
    model = input_args[4]

    if(len(input_args) >= 6):
        hyperparameters = input_args[5].split(",")
        hyperparams_dict =  {interpret_type(hyperparameters[i]): interpret_type(hyperparameters[i + 1]) for i in range(0, len(hyperparameters), 2)} 
    else:
        hyperparams_dict  = {}
        
    X,y,feature_labels = process_input_file(input_file)     
    clf = choose_model(model,hyperparams_dict)
    trainedModel = clf.fit(X,y.ravel())
    print_accuracy_and_save_model(clf,trainedModel,save_filename)

#Optimize over one model
elif(learning_type_flag == "-o"):
    model = input_args[4]
    optimize_type = input_args[5]

    X,y,feature_labels = process_input_file(input_file)
    

    if(len(input_args) >= 7):
        additional_vars = input_args[6].split(',')
        kfolds,grid_values,iters = extract_iters_kfolds_and_grid_values(additional_vars,model)
 
    else:
        kfolds,grid_values,iters = extract_iters_kfolds_and_grid_values("",model)

    models_dict = { 
            'SVM': svm.SVC(),
            'RandomForest': ensemble.RandomForestClassifier(),
            'Adaboost': ensemble.AdaBoostClassifier(),
            'Bagging': ensemble.BaggingClassifier(),
            'GradientBoost': GradientBoostingClassifier(loss = 'deviance', max_depth = 6, n_estimators = 100),
            'DecisionTree': tree.DecisionTreeClassifier()
            }  
    
    model_clf = models_dict[model]

    #Grid Search
    if(optimize_type == '0'):
        clf = model_selection.GridSearchCV(estimator = model_clf, param_grid = grid_values, cv = kfolds)
        
    #Random Search
    elif(optimize_type == '1'):
         clf = model_selection.RandomizedSearchCV(estimator = model_clf, param_grid = grid_values, cv = kfolds)
    
    #TODO: bayesian optimize
    #elif(optimize_type == '2'):
 
    else:
        print("ERROR: " + optimize_type + " is not valid")
        
    trainedModel = clf.fit(X,y.ravel())
    print_accuracy_and_save_model(clf,trainedModel,save_filename)
    
#Automatic
elif(learning_type_flag == "-a"):
    
    optimize_type = input_args[4]
    X,y,feature_labels = process_input_file(input_file)
    
    models = ['DecisionTree','RandomForest','SVM','Bagging','Adaboot','GradientBoost']

    models_dict = { 
            'SVM': svm.SVC(),
            'RandomForest': ensemble.RandomForestClassifier(),
            'Adaboost': ensemble.AdaBoostClassifier(),
            'Bagging': ensemble.BaggingClassifier(),
            'GradientBoost': GradientBoostingClassifier(loss = 'deviance', max_depth = 6, n_estimators = 100),
            'DecisionTree': tree.DecisionTreeClassifier()
            }  
     
    #Default Hyperparameters
    if(optimize_type == '0'):
        curr_accuracy = 0.0
        clf = None    
        for model in models:
            model_clf = models_dict[model]
            model_accuracy = stratifiedKFoldAccuracy(clf,X,y)  
            if(model_accuracy > curr_accuracy):
                curr_accuracy = model_accuracy 
                clf  =  model_clf
   
    #Grid Search    
    elif(optimize_type == '1'):
        curr_accuracy = 0.0
        clf = None    
        for model in models:
            grid_values = default_grid_values(model)
            model_clf = model_selection.GridSearchCV(estimator = models_dict[model], param_grid = grid_values, cv = DEFAULT_K_FOLDS)
            model_accuracy = stratifiedKFoldAccuracy(model_clf,X,y)  
            if(model_accuracy > curr_accuracy):
                curr_accuracy = model_accuracy 
                clf  =  model_clf
                

    #Random search
    elif(optimize_type == '2'):
        curr_accuracy = 0.0
        clf = None    
        for model in models:
            grid_values = default_grid_values(model)
            model_clf = model_selection.RandomizedSearchCV(estimator = model_dict[model], param_grid = grid_values, cv = DEFAULT_K_FOLDS)
        
            model_accuracy = stratifiedKFoldAccuracy(model_clf,X,y)  
            if(model_accuracy > curr_accuracy):
                curr_accuracy = model_accuracy 
                clf  =  model_clf
                
    #TODO: bayesian optimize
    #elif(optimize_type == '3'):
        
    else:
        print("ERROR: " + optimize_type + " is not valid")

    trainedModel = clf.fit(X,y.ravel())
    print_accuracy_and_save_model(clf,trainedModel,save_filename)

else:
    print("invalid learning type flag: " + learning_type_flag + " is not a valid option" )
