"""
Merger for cost-sensitive learning
"""
import pandas as pd
import numpy as np


#if(system args exists), use as directories. Else use hardcoded values

#df1 = pd.read_csv("./kernel-level-measurement/lassen-log/kernal_costs.csv")
#df2 = pd.read_csv("./mergedDataSet.csv")

df1 = pd.read_csv("kernal_costs.csv")
df2 = pd.read_csv("mergedDataSet.csv")

df2['Costs'] = "" 
df2['label'] = ""


#Go through rows of mergedDataset
for index, row in df2.iterrows():
 
    kernel = row['Kernel']
    InputData = row['InputData']
    DataID = row['DataID'] 
    
    advise = 'advise'+str(DataID)  
    
    
    cost_index = 'advise' + str(DataID)

    
    cost_row = df1[(df1['kernel'] == kernel) & (df1['InputData'] == InputData)]
            

    df2.iloc[index,df2.columns.get_loc('Costs')] = ','.join(cost_row[advise].values[0].strip('][').split(',')[0:7]).strip('[]') 
    df2.iloc[index,df2.columns.get_loc('label')] = cost_row[advise].values[0].strip('][').split(',')[7] 
    
    #df2.iloc[index,df2.columns.get_loc('Costs')] = cost_row[advise].values[0]
    #df2.iloc[index,df2.columns.get_loc('Labels')] = cost_row[advise].values[0]

df3 = df2
df3.to_csv("costLabelledData.csv",index=False)


