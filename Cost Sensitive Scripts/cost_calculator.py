# -*- coding: utf-8 -*-
"""
Cost test

Use class weight vectors

"""

import sys
import pandas as pd
import os

classification_filename = sys.argv[1]
#costsensitive_filename = sys.argv[2]

classification_file = pd.read_csv(classification_filename)  
#costsensitive_file  = pd.read_csv(costsensitive_filename) 

classification_file['Predicted cost'] = ""
classification_file['Predicted cost differential'] = ""
    
#costsensitive_file['Predicted cost'] = ""
#costsensitive_file['Predicted cost differential'] = ""
    
classify_average_cost = 0.0
classify_worst_cost_differential = 0.0
classify_average_normalized_cost = 0.0
    

#costsensitive_average_cost = 0.0
#costsensitive_worst_cost_differential = 0.0
    
classify_costs = classification_file['Costs']
classify_true_labels = classification_file['label']
classify_predicted_labels = classification_file['predicted label']
    
#costsensitive_costs = costsensitive_file['Costs']
#costsensitive_true_labels = costsensitive_file ['label']
#costsensitive_predicted_labels = classification_file['predicted label']
    
num_data_points = len(classify_costs)
    
#for i in range(0,num_data_points):    
for index, row in classification_file.iterrows():
 
    classify_cost_vector = row['Costs'].split(',')#classify_costs.iloc[i].split(',')
    
    
    classify_true_label = int(row['label']) #int(classify_true_labels.iloc[i])
    classify_predicted_label = int(row['predicted label']) #int(classify_predicted_labels.iloc[i])
        
    classify_average_cost += float(classify_cost_vector[classify_predicted_label])
    classify_cost_differential = float(classify_cost_vector[classify_predicted_label]) - float(classify_cost_vector[classify_true_label])
   
    classification_file.loc[index,'Predicted cost'] = float(classify_cost_vector[classify_predicted_label])
    classification_file.loc[index, 'Predicted cost differential'] = classify_cost_differential
    
    #row['Predicted cost'] = float(classify_cost_vector[classify_predicted_label])
    #row['Predicted cost differential'] = classify_cost_differential
    
    #classification_file.loc[classification_file.index[i],'Predicted cost'] = float(classify_cost_vector[classify_predicted_label])
    #classification_file.loc[classification_file.index[i],'Predicted cost differential'] = classify_cost_differential
    
    if(classify_cost_differential > classify_worst_cost_differential):
        classify_worst_cost_differential = classify_cost_differential
    
               
    
    
    #costsensitive_cost_vector = costsensitive_costs.iloc[i].split(',')
    #costsensitive_true_label = int(costsensitive_true_labels.iloc[i])
    #costsensitive_predicted_label = int(costsensitive_predicted_labels.iloc[i])
        
    #costsensitive_average_cost += float(costsensitive_cost_vector[costsensitive_predicted_label])
    #costsensitive_cost_differential = float(costsensitive_cost_vector[costsensitive_predicted_label]) - float(costsensitive_cost_vector[costsensitive_true_label])
    
    #costsensitive_file.loc[costsensitive_file.index[i],'Predicted cost'] = float(costsensitive_cost_vector[costsensitive_predicted_label])
    #costsensitive_file.loc[costsensitive_file.index[i],'Predicted cost differential'] = costsensitive_cost_differential
 
    #if(costsensitive_cost_differential > costsensitive_worst_cost_differential ):
        #costsensitive_worst_cost_differential = costsensitive_cost_differential
            
        
    
    #costsensitive_average_cost /= num_data_points 
   
classify_average_cost /= num_data_points      
print("Classification average cost is " + str(classify_average_cost))
print("Classification worst miss costs " + str(classify_worst_cost_differential))    
    

filename, file_extension = os.path.splitext(classification_filename)
classification_file.to_csv(filename + "_cost_calculated" + file_extension,index=False)
  
#print("Cost-sensitive average cost is " + str(costsensitive_average_cost))
#print("Cost-sensitive worst miss costs " + str(costsensitive_worst_cost_differential))   
      
#filename, file_extension = os.path.splitext(costsensitive_filename)
#costsensitive_file.to_csv(filename + "_cost_calculated" + file_extension,index=False)
