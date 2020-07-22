"""
Script to train model based on csv 
arguments: input_filename model_type saved_filename
"""
import sklearn as sk
from sklearn import ensemble
import sklearn.model_selection as model_selection
from sklearn import preprocessing
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


input_file = pd.read_csv(sys.argv[1])  
model = sys.argv[2] 
save_filename = sys.argv[3] 


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
feature_labels = np.concatenate((X.columns.values[0:],y.columns.values[0:]))

X = X.to_numpy()
y = y.to_numpy()

models = {
        'DecisionTree': tree.DecisionTreeClassifier(), 
        'RandomForest': ensemble.RandomForestClassifier(),
        'SVM': svm.SVC(),
        'Bagging': ensemble.BaggingClassifier(),
        'Adaboost': ensemble.AdaBoostClassifier
}  
 
clf = models.get(model,"Invalid choice of Model")
   
trainedModel = clf.fit(X,y)

initial_type = [('float_input', FloatTensorType([None, 4]))]
onx = convert_sklearn(trainedModel, initial_types=initial_type)
with open(saveFileName.get() + ".onnx", "wb") as f:
    f.write(onx.SerializeToString())

#Save file via pickle
#pickle.dump(trainedModel, open(save_filename + ".pkl", 'wb'))
    