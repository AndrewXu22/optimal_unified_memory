#!/usr/bin/python
import sys
import re
import csv
import glob
import pandas as pd
import numpy as np



funcname = re.compile("[\S]\([^%]*\)")

kernels = []

filenames = sorted(glob.glob('output_*'))
variant = re.split("[_]|.log", filenames[0])[1]
variants = list(variant)
variantscount = len(variants)
with open(filenames[0], "r") as f:
  lines = f.readlines()
  for line in lines: 
    if funcname.search(line):
      kernelname = re.findall("[\S]*\(",line)[0]
      #print(kernelname)
      kernels.append(kernelname[:-1])

csvcolumn = ["kernel", "InputData"]
for c in range (0, variantscount):
  csvcolumn.append("advise"+str(c))
csvcolumn.extend(["variant","TimePerc","Time","calls","AVG","MIN","MAX"])

csvfilename = 'kernel_stat.csv'


with open(csvfilename, 'w') as output_file:
  writer = csv.writer(output_file)
  writer.writerow(csvcolumn)

for k in kernels:
  for f1 in filenames:
    variant = re.split("[_]|.log", f1)[1]
    inputData = re.split("[_]|.log", f1)[2]
    variants = list(variant)
    variantscount = len(variants)
    with open(f1, "r") as f:
      lines = f.readlines()
      for line in lines:
        if re.search('%s'%k, line):
          line2 = re.search('(.+)%s'%k, line).group(1)
          #print(line2)
          rr = re.findall("[-+]?[.]?[\d]+(?:,\d\d\d)*[\.]?\d*(?:[eE][+\-]?\d+)?",line2)
          #rr = re.findall("([+-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+))",line)
          rr.insert(0, variant)
          for c in reversed (range(variantscount)):
            rr.insert(0, variants[c])
          rr.insert(0, inputData)
          rr.insert(0, k)
          #print(rr)
          with open(csvfilename, 'a') as output_file:
            writer = csv.writer(output_file)
            writer.writerow(rr)
          break




df1 = pd.read_csv(csvfilename)
df1 = df1.sort_values(["kernel","InputData","AVG"]).groupby(["kernel","InputData"]).head(1)   
df1.to_csv("kernel-data-best.csv",index=False) 
