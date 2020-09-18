"""
Sorts kernal_stat
"""

import pandas as pd
import sys, os

input_file = pd.read_csv("kernel_stat.csv")
input_file = input_file.sort_values(by = ['kernel','InputData','AVG'])

os.remove('kernel_stat.csv')
input_file.to_csv("kernel_stat.csv",index=False)

 

