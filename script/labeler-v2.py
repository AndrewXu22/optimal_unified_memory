import csv
import pandas as pd
import numpy as np

df1 = pd.read_csv("./ip-128-115-246-7-kernel-level-measurement/variants/kernel-data-best.csv")
df2 = pd.read_csv("./mergedDataSet-ip-128-115-246-7.csv")

df2['label'] = "" 

for index, row in df2.iterrows():
    kernel = row['Kernel']
    InputData = row['InputData']
    Data = row['Data'] 
    DataID = row['DataID'] 
    #print(kernel, InputData, Data, DataID)
    bestData = df1[(df1['kernel'] == kernel) & (df1['InputData'] == InputData)]
    advise = 'advise'+str(DataID)  
    #print(advise, bestData[advise].values[0])
    df2.iloc[index,df2.columns.get_loc('label')] = bestData[advise].values[0]
df3 = df2
df3.to_csv("labelledData-ip-128-115-246-7.csv",index=False)
