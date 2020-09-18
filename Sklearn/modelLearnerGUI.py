import sklearn as sk
from sklearn import ensemble
import sklearn.model_selection as model_selection
from sklearn.tree import export_text
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.naive_bayes import GaussianNB
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
from skl2onnx import to_onnx
from skl2onnx.common.data_types import FloatTensorType,Int64TensorType,StringTensorType
import numpy as np

global currentDataFile #Contents of currently opened filed
global trainedModel #sklearn trained model
global featuresList #name of features
global predictedLabels #current predicted labels

'''
Structure of input file
Last column: Labels
'''

#Cost matrix using min-max normalized average missclassification cost
def minmax_normalized_cost_matrix_estimator(costs,labels,num_labels):
    cost_matrix = np.zeros((num_labels,num_labels))    
    count_matrix = np.zeros((num_labels,num_labels))
    
    data_points = len(labels)
    
    for i in range(0,data_points - 1):
        label = labels[i][0]
        for j in range(0,num_labels):
                costs_list = costs[i].split(',')
                missclassification_costs_lists = [float(x) - float(costs_list[label]) for x in costs_list]
                
                cost_matrix[j][label] += (missclassification_costs_lists[j] - min(missclassification_costs_lists))/(max(missclassification_costs_lists) - min(missclassification_costs_lists))  #float(costs_list[j]) - float(costs_list[label])
                count_matrix[j][label] += 1
                       
    for i in range(0,num_labels - 1):
        for j in range(0,num_labels - 1):
            if(count_matrix[j][i] !=0):
                cost_matrix[j][i] /= count_matrix[j][i]
            
    return cost_matrix

#Cost matrix using mean normalized average missclassification cost
def mean_normalized_cost_matrix_estimator(costs,labels,num_labels):
    cost_matrix = np.zeros((num_labels,num_labels))    
    count_matrix = np.zeros((num_labels,num_labels))
    
    data_points = len(labels)
    
    for i in range(0,data_points - 1):
        label = labels[i][0]
        for j in range(0,num_labels):
                costs_list = costs[i].split(',')
                
                missclassification_costs_lists = [float(x) - float(costs_list[label]) for x in costs_list]
                mean = sum(missclassification_costs_lists)
                
                cost_matrix[j][label] += (missclassification_costs_lists[j] - mean)/(max(missclassification_costs_lists) - min(missclassification_costs_lists))  #float(costs_list[j]) - float(costs_list[label])
                count_matrix[j][label] += 1
                       

    for i in range(0,num_labels - 1):
        for j in range(0,num_labels - 1):
            if(count_matrix[j][i] !=0):
                cost_matrix[j][i] /= count_matrix[j][i]
                
    return cost_matrix

#Cost matrix using average missclassification cost
def cost_matrix_estimator(costs,labels,num_labels):
    cost_matrix = np.zeros((num_labels,num_labels))    
    count_matrix = np.zeros((num_labels,num_labels))
    
    data_points = len(labels)
    
    for i in range(0,data_points - 1):
        label = labels[i][0]
        for j in range(0,num_labels):
            if(j != label):
                costs_list = costs[i].split(',')
                cost_matrix[j][label] += float(costs_list[j]) - float(costs_list[label])
                count_matrix[j][label] += 1
                
    for i in range(0,num_labels - 1):
        for j in range(0,num_labels - 1):
            if((j != -i )  & ( count_matrix[j][i] !=0 ) ):
                cost_matrix[j][i] /= count_matrix[j][i]
    return cost_matrix

def construct_count_vector(labels,num_labels):
    count_vector = [0] * num_labels
    counts = labels['label'].value_counts()
    
    for index, row in counts.iteritems():
        count_vector[index] = row
    
    return count_vector
    

#Weight vector using SimpleCost algorithm
def construct_weight_vector_simple(costs,labels,cost_matrix_type):
    num_labels = labels['label'].nunique()
    count_vector = construct_count_vector(labels,num_labels)
    
    weights = {}    
    cost_matrix_types_dict = {'Mean Estimate': cost_matrix_estimator(costs,labels.to_numpy(),num_labels),
                              "Min-Max Normalized": minmax_normalized_cost_matrix_estimator(costs,labels.to_numpy(),num_labels),
                              "Mean Normalized": mean_normalized_cost_matrix_estimator(costs,labels.to_numpy(),num_labels)}
    
    cost_matrix = cost_matrix_types_dict.get(cost_matrix_type,"Invalid Choice of weight vector")
    
    n = len(labels)
    column_sum_matrix = [np.sum(cost_matrix[0:num_labels][i]) for i in range(0,num_labels)]

    for i in range(0,num_labels):
        weights[i] = (n*column_sum_matrix[i])/(np.sum(np.multiply(count_vector,column_sum_matrix)))
               
    return weights

def convert_dataframe_schema(X):
    features = []
    for k, v in zip(X.columns, X.dtypes):
        if v == 'int64':
            t = Int64TensorType([None, 1])
        elif v == 'float64':
            t = FloatTensorType([None, 1])
        else:
            t = StringTensorType([None, 1])
        features.append((k, t))
    return features

def classifyAndTest():
    global currentDataFile 
    global trainedModel
    global featuresList
    global predictedLabels

    #Variables for Cost sensitive learning
    has_costs_columns_boolean = False
    costs = []

    #Read in file panda dataframe 
    try:
        numColumns = len(currentDataFile.columns)
        X_input = currentDataFile.iloc[:,0:(numColumns - 1)]
        y = currentDataFile.iloc[:,(numColumns - 1): (numColumns)]
  
        if 'Costs' in X_input.columns:
            has_costs_columns_boolean = True
            costs = X_input['Costs'].to_numpy()
            del X_input['Costs']
            
        
        '''Deal with Categorical Features'''
        categoricals = X_input.select_dtypes(include=['object'])
    
        if (not categoricals.empty):
            ohe_categoricals = pd.get_dummies(X_input.select_dtypes(include=['object']).copy())
        else:
            ohe_categoricals = categoricals

        X = pd.concat([X_input.select_dtypes(exclude=['object']), ohe_categoricals],axis = 1)       
         
        featuresList = convert_dataframe_schema(X)   

        X = X.to_numpy()
        y = y.to_numpy()
    except:
        modelTrainingResults.insert(tk.END,"ERROR: Unable to process file\n")
        return
    
    if(costSensitiveToggle.get()):
        if not (has_costs_columns_boolean):
            modelTrainingResults.insert(tk.END,"ERROR: No costs for cost-sensitive learning\n") 
            return
        else:
            y_pandas = currentDataFile.iloc[:,(numColumns - 1): (numColumns)]
            weight_dict = construct_weight_vector_simple(costs,y_pandas,costSensitiveType.get())
            clf = tree.DecisionTreeClassifier(class_weight = weight_dict)
       
    else:   
        models = { 
            'SVM': svm.SVC(),
            'Random Forest': ensemble.RandomForestClassifier(),
            'Adaboost': ensemble.AdaBoostClassifier(),
            'Bagging': ensemble.BaggingClassifier(),
            'Gradient Boosting': GradientBoostingClassifier(loss = 'deviance', max_depth = 6, n_estimators = 100),
            'Decision Tree': tree.DecisionTreeClassifier()
            }  
     
        clf = models.get(modelChoice.get(),"Invalid choice of Model")
         
    '''Write Results '''
    skf = StratifiedKFold(n_splits=crossVals.get(), shuffle = True)
    stratifiedAccuracy = 0.0
    
    num_file = 1
    for train_indices, test_indices in skf.split(X, np.ravel(y)):
        clf_test = clf.fit(X[train_indices],np.ravel(y[train_indices]))
        y_pred = clf_test.predict(X[test_indices])
        stratifiedAccuracy += accuracy_score(y[test_indices], y_pred) *100
       
    start = time.time()
    trainedModel  = clf.fit(X,np.ravel(y))
    elapsed_time = (time.time() - start)
    
    predictedLabels = clf.predict(X)
    
    modelTrainingResults.insert(tk.END, "Results for " + str(dataFileName.get()) + " using " + str(modelChoice.get()) + "\n")
    modelTrainingResults.insert(tk.END, "Time to build model is " + str(elapsed_time) + " seconds\n" )
    modelTrainingResults.insert(tk.END, "Accuracy when trained on all data is " + str(clf.score(X, y) * 100) + "%\n" )
    modelTrainingResults.insert(tk.END, "Average accuracy over cross-validated sets is " + str(stratifiedAccuracy/crossVals.get()) + "%\n\n")

    

def openFile():
        global currentDataFile 
        filename = filedialog.askopenfilename(filetypes=[("CSV files","*.csv")])  

        try:
            currentDataFile = pd.read_csv(filename)
            dataFileName.set(os.path.splitext(os.path.basename(filename))[0])

        except:
            print("No file exists or invalid file type")

def saveFile():
    global trainedModel
    global featuresList
    global currentDataFile 
    
    #Save to an ONNX file
    numColumns = len(currentDataFile.columns)
    X_input = currentDataFile.iloc[:,0:(numColumns - 1)]
    
    onx = to_onnx(trainedModel, X_input, saveFileName.get())
    
    with open(saveFileName.get() + ".onnx", "wb") as f:
        f.write(onx.SerializeToString())
    
    return 

def savePredictedModel():
    global predictedLabels
    global currentDataFile 
    
    currentDataFile['predicted label'] =  predictedLabels #pd.Series()
    currentDataFile.to_csv(savePredictedFileName.get() + ".csv",index=False)
    #Get rid of new column
    #currentDataFile.drop('predicted label')
    
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
models = {'Decision Tree','SVM', 'Random Forest', 'Adaboost', 'Bagging', 'Gradient Boosting'}
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

#Button to select Cost-sensitive learning
costSensitiveToggle = tk.BooleanVar()
costSensitiveToggle.set(False) # set the default option
costSensitiveToggleButton = tk.Checkbutton(mainWindow, text="Use Cost-sensitive learning", variable=costSensitiveToggle )
costSensitiveToggleButton.place(x = 225, y = 382)

#Button to choose between types of cost-sensitive learning
costSensitiveType = tk.StringVar()
costSensitiveTypeLabel =  tk.Label(mainWindow, text = "Cost-sensitive estimation type:")
costSensitiveTypeLabel.place(x = 400, y = 385)
costSensitveLearningTypes = {"Mean Estimate","Min-Max Normalized","Mean Normalized"}
costSensitiveOptions = tk.OptionMenu(mainWindow, costSensitiveType, *costSensitveLearningTypes)
costSensitiveOptions.place(x = 570, y = 381)

#Save Predicted File
savePredictedButton = tk.Button(mainWindow, text = "Save Predicted File", command = savePredictedModel)
savePredictedButton.place(x = 350,y = 440)

savePredictedLabel = tk.Label(mainWindow, text = "Save Predicted Filename:")
savePredictedLabel.place(x = 470,y = 440)

savePredictedFileName = tk.StringVar()
savePredictedFileEntry = tk.Entry(mainWindow, textvariable= savePredictedFileName)
savePredictedFileEntry.place(x = 600,y = 440, width = 190)

#Save Model Button
saveModelButton = tk.Button(mainWindow, text = "Save Model", command = saveFile)
saveModelButton.place(x = 387,y = 470)

saveFileLabel = tk.Label(mainWindow, text = "Save Model Filename:")
saveFileLabel.place(x = 470,y = 470)

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