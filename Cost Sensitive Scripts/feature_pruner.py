"""
Feature pruner: removes all but 13 features, plus labels and costs (if they exists)
"""

import pandas as pd
import os
import sys

input_filename = sys.argv[1]
input_file = pd.read_csv(input_filename)  
output_file = pd.DataFrame()

allowable_columns = ['Executed Ipc Elapsed','Issued Warp Per Scheduler','Avg. Executed Instructions Per Scheduler', 'Block Size'
                      ,'Registers Per Thread','Threads','Waves Per SM','Block Limit Registers','Block Limit Warps','CPUPageFault',	
                      'GPUPagePault','HtoD','DtoH', 'Costs','label']


for column_name in allowable_columns:
    output_file[column_name] = input_file[column_name]
filename, file_extension = os.path.splitext(input_filename)
output_file.to_csv(filename + "_pruned" + file_extension,index=False)
