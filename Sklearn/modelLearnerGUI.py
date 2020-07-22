import sklearn as sk
from sklearn import ensemble
import sklearn.model_selection as model_selection
from sklearn.tree import export_text
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score
from sklearn import preprocessing
import sklearn.svm as svm
from sklearn import tree
import tkinter as tk
import os
from tkinter import filedialog
import pandas as pd
import numpy as np
import pickle
import time
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
import numpy as np

global currentDataFile  #Contents of currently opened filed
global trainedModel #sklearn trained model
global featureNames #name of features

'''
Structure of input file

Last column: Labels

'''
def classifyAndTest():
    global currentDataFile 
    global trainedModel
    
    #Read in file panda dataframe 
    try:
        numColumns = len(currentDataFile.columns)
        X_input = currentDataFile.iloc[:,0:(numColumns - 1)]
        y = currentDataFile.iloc[:,(numColumns - 1): (numColumns)]
        
        '''Deal with Categorical Features'''
        categoricals = X_input.select_dtypes(include=['object'])
    
        if (not categoricals.empty):
            ohe_categoricals = pd.get_dummies(X_input.select_dtypes(include=['object']).copy())
        else:
            ohe_categoricals = categoricals

        X = pd.concat([X_input.select_dtypes(exclude=['object']), ohe_categoricals],axis = 1)       
        featureLabels = X.columns.values[0:]
        #feature_labLabelsels = np.concatenate((X.columns.values[0:],y.columns.values[0:]))

        X = X.to_numpy()
        y = y.to_numpy()
    except:
        print("Invalid File")
        return
        
    models = {
        'Decision Tree': tree.DecisionTreeClassifier(), 
        'SVM': svm.SVC(),
        'Random Forest': ensemble.RandomForestClassifier(),
        'Adaboost': ensemble.AdaBoostClassifier(),
        'Bagging': ensemble.BaggingClassifier(),
        }  
 
    clf = models.get(modelChoice.get(),"Invalid choice of Model")
         
    #print(sk.metrics.confusion_matrix(y,y_predict))
    
    '''Write Results '''
    skf = StratifiedKFold(n_splits=crossVals.get(), shuffle = True)
    
    stratifiedAccuracy = 0.0
    for train_indices, test_indices in skf.split(X, np.ravel(y)):
        clf_test = clf.fit(X[train_indices],np.ravel(y[train_indices]))
        y_pred = clf_test.predict(X[test_indices])
    
        stratifiedAccuracy += accuracy_score(y[test_indices], y_pred) *100
    
    start = time.time()
    trainedModel  = clf.fit(X,np.ravel(y))
    elapsed_time = (time.time() - start)
    
    y_predict = clf.predict(X)
    
    modelTrainingResults.insert(tk.END, "Results for " + str(dataFileName.get()) + " using " + str(modelChoice.get()) + "\n")
    modelTrainingResults.insert(tk.END, "Time to build model is " + str(elapsed_time) + " seconds\n" )
    modelTrainingResults.insert(tk.END, "Accuracy when trained on all data is " + str(clf.score(X, y) * 100) + "%\n" )
    modelTrainingResults.insert(tk.END, "Average accuracy over cross-validated sets is " + str(stratifiedAccuracy/crossVals.get()) + "%\n\n")

def openFile():
        global currentDataFile 
        filename = filedialog.askopenfilename(filetypes=[("CSV files","*.csv")])  

        try:
            currentDataFile = pd.read_csv(filename)
            #currentDataFile = open(filename, 'r')
            dataFileName.set(os.path.splitext(os.path.basename(filename))[0])

        except:
            print("No file exists or invalid file type")

def saveFile():
    global trainedModel
    
    #Save to an ONNX file
    initial_type = [('float_input', FloatTensorType([None, 4]))]
    onx = convert_sklearn(trainedModel, initial_types=initial_type)
    with open(saveFileName.get() + ".onnx", "wb") as f:
        f.write(onx.SerializeToString())
    
    #Save via pickle
    #pickle.dump(trainedModel, open(saveFileName.get() + ".pkl", 'wb'))
    return 

def openModel():
    return 
    
#Main Window
mainWindow = tk.Tk(className= "Model learner")
mainWindow.geometry("800x500")

#Open data File Button
openFileButton = tk.Button(mainWindow, text = "Open Data File", command = openFile)
openFileButton.place(x = 10,y = 25)

#Label to let you know what file is open
dataFileName = tk.StringVar()
fileOpenLabel = tk.Label(mainWindow, textvariable= dataFileName)
dataFileName.set('None')
fileOpenLabel.place(x = 135, y = 60)

fileOpenLabel = tk.Label(mainWindow, text = "File Currently Opened:")
fileOpenLabel.place(x = 10, y = 60)

#Model Selector
modelSelectorLabel = tk.Label(mainWindow, text = "Choose Model:")
modelSelectorLabel.place(x = 10,y = 385)

modelChoice = tk.StringVar()
models = {'Decision Tree','SVM', 'Random Forest', 'Adaboost', 'Bagging'}
modelChoice.set('Decision Tree') # set the default option
modelSelectorMenu = tk.OptionMenu(mainWindow, modelChoice, *models)
modelSelectorMenu.place(x = 100,y = 378)

#Cross Validations
crossValsLabel = tk.Label(mainWindow, text = "Number of Cross Validations:")
crossValsLabel.place(x = 10,y = 425)

#Classify button (also tests using cross validation)
classifyButton = tk.Button(mainWindow, text = "Classify and Test", command = classifyAndTest)
classifyButton.place(x = 10,y = 460)

crossVals = tk.IntVar()
numCrossVals = {2,3,4,5,6,7,8,9,10} #Can add n manually to do "Leave one out"
crossVals.set(10) # set the default option
crossValsMenu = tk.OptionMenu(mainWindow, crossVals, *numCrossVals)
crossValsMenu.place(x = 175,y = 418)

#Save Button
saveModelButton = tk.Button(mainWindow, text = "Save Model", command = saveFile)
saveModelButton.place(x = 410,y = 470)

saveFileLabel = tk.Label(mainWindow, text = "Save File Name:")
saveFileLabel.place(x = 500,y = 470)

saveFileName = tk.StringVar()
saveFileEntry = tk.Entry(mainWindow, textvariable= saveFileName)
saveFileEntry.place(x = 600,y = 470, width = 190)

#Model Training Results
modelTrainingResultsLabel = tk.Label(mainWindow, text = "Training Output")
modelTrainingResultsLabel.place (x = 250, y = 10)
modelTrainingResults = tk.Text(mainWindow, height = 21, width = 66, bg = "white")
modelTrainingResults.place(x = 250,y = 30)

#Instantiate Main Tkinter window
mainWindow.mainloop()