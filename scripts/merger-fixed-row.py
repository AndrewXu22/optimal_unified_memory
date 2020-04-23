import csv
import pandas as pd
import numpy as np

df1 = pd.read_csv("./kernel-level-measurement/dataset.csv")
df2 = pd.read_csv("./data-level-measurement/GPUTrace.csv")

df1 = df1.groupby(["InputData","Kernel"], as_index=False).head(10)
df1 = df1.drop(columns=["ID"])
df3 = pd.merge(df1, df2, on=["InputData"], how='outer')

# remove column with same value
df3.loc[:, ~(df3 == df3.iloc[0]).all()]

# move data column to front
data = df3['Data']
df3.drop(labels=['Data'], axis=1,inplace = True)
df3.insert(2, 'Data', data)
dataID = df3['DataID']
df3.drop(labels=['DataID'], axis=1,inplace = True)
df3.insert(3, 'DataID', dataID)

df3.to_csv("mergedDataSet-fixedrow.csv",index=False)
