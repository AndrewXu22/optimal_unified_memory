"""
Converts kernal stats to averages 
"""
import pandas as pd
import numpy as np 

#def(write to csv and reset costs/counts)

#df1 = pd.read_csv("./kernel-level-measurement/lassen-log/kernel_stat.csv")
df1 = pd.read_csv("kernel_stat.csv")

max_num_advise = 0

for col in df1.columns:
    if ( (len(col) > 6) & (col[0:6] == 'advise')):
        advise_num = int(col[6:len(col)]) 
        if(advise_num > max_num_advise):
            max_num_advise = advise_num
        
advise_columns = []
advise_dict = {}

for i in range(0,max_num_advise + 1):
    advise_columns += ['advise' + str(i)]
    advise_dict[str(i)] = [np.array([0.0,0.0,0.0,0.0,0.0,0.0,0.0]), np.array([0,0,0,0,0,0,0])]

#df2 = pd.DataFrame(columns= ['kernel','InputData', 'advise0', 'advise1', 'advise2'])
df2 = pd.DataFrame(columns= ['kernel','InputData'] + advise_columns)
df3 = pd.read_csv('kernel-data-best.csv')

curr_kernel = df1['kernel'].iloc[0]
curr_input_data = df1['InputData'].iloc[1]


input_dict = {}

for index, row in df1.iterrows():

    row_kernel = row['kernel']
    row_input_data = row['InputData']
    
    
    if( (row_kernel != curr_kernel) | (row_input_data != curr_input_data) ):
    
        bestData = df3[(df3['kernel'] == curr_kernel) & (df3['InputData'] == curr_input_data)]
        input_dict['kernel'] = curr_kernel
        input_dict['InputData'] = curr_input_data
        
        
        
        for i in range(0,max_num_advise + 1):
            input_dict['advise' + str(i)] = [np.divide(advise_dict[str(i)][0],advise_dict[str(i)][1]).tolist(),bestData['advise' + str(i)].values[0]]
            advise_dict[str(i)] = [np.array([0.0,0.0,0.0,0.0,0.0,0.0,0.0]), np.array([0,0,0,0,0,0,0])]

        
        df2 = df2.append(input_dict, ignore_index=True)
        #df2 = df2.append({'kernel': curr_kernel,'InputData': curr_input_data, 'advise0': [np.divide(costs_0,counts_0).tolist(),bestData['advise0'].values[0]], 'advise1': [np.divide(costs_1,counts_1).tolist(),bestData['advise1'].values[0]], 'advise2': [np.divide(costs_2,counts_2).tolist(),bestData['advise2'].values[0]] }, ignore_index=True)

        
        
        '''costs_0 = np.array([0.0,0.0,0.0,0.0,0.0,0.0,0.0])
        counts_0 = np.array([0,0,0,0,0,0,0])
        
        costs_1 = np.array([0.0,0.0,0.0,0.0,0.0,0.0,0.0])
        counts_1 = np.array([0,0,0,0,0,0,0] )
        
        costs_2 = np.array([0.0,0.0,0.0,0.0,0.0,0.0,0.0])
        counts_2 = np.array([0,0,0,0,0,0,0])'''
        
        curr_kernel = row_kernel
        curr_input_data = row_input_data

    for i in range(0,max_num_advise + 1):
        advise_dict[str(i)][0][row[['advise' + str(i)]].values[0]] += row['AVG']
        advise_dict[str(i)][1][row[['advise' + str(i)]].values[0]] += 1

    '''costs_0[row['advise0']] += row['AVG']
    counts_0[row['advise0']] += 1
    
    costs_1[row['advise1']] += row['AVG']
    counts_1[row['advise1']] += 1
    
    costs_2[row['advise2']] += row['AVG']
    counts_2[row['advise2']] += 1'''
 
bestData = df3[(df3['kernel'] == curr_kernel) & (df3['InputData'] == curr_input_data)]
input_dict = {'kernel': curr_kernel,'InputData': curr_input_data}
   
for i in range(0,max_num_advise + 1):
    input_dict['advise' + str(i)] = [np.divide(advise_dict[str(i)][0],advise_dict[str(i)][1]).tolist(),bestData['advise' + str(i)].values[0]]
           
    
df2 = df2.append(input_dict, ignore_index=True)
    
#bestData = df3[(df3['kernel'] == row_kernel) & (df3['InputData'] == row_input_data)]     
#df2 = df2.append({'kernel': curr_kernel,'InputData': curr_input_data, 'advise0': [np.divide(costs_0,counts_0).tolist(),bestData['advise0'].values[0]], 'advise1': [np.divide(costs_1,counts_1).tolist(),bestData['advise1'].values[0]], 'advise2': [np.divide(costs_2,counts_2).tolist(),bestData['advise2'].values[0]] }, ignore_index=True)

df2.to_csv("kernal_costs.csv",index=False)
    
    
    
    
    
    