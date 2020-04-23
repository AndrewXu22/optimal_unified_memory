#!/usr/bin/python
import sys
import re
import csv

csvfilename = 'hotspot_stat.csv'
inputdata = ['64', '128', '256', '512', '1024', '2048', '4096', '8192']

csvcolumn = ["kernel", "MemLocation","Input","MatrixTemp","FilesavingPower","label","TimePerc","Time","calls","AVG","MIN","MAX"]
kernels = ["calculate_temp"]

with open(csvfilename, 'wb') as output_file:
  writer = csv.writer(output_file)
  writer.writerow(csvcolumn)
  
for d in inputdata:
  for k in kernels:
     for w in range(0, 2):
       if w == 0:
         memloc = "Global"
       elif w == 1:
         memloc = "Host"
       
       for x in range(0, 6):
         if x == 0:
           MatrixTemp = "none"
         elif x == 1:
           MatrixTemp = "cudaMemAdviseSetReadMostly"
         elif x == 2:
           MatrixTemp = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 3:
           MatrixTemp = "cudaMemAdviseSetAccessedByGPU"
         elif x == 4:
           MatrixTemp = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 5:
           MatrixTemp = "cudaMemAdviseSetPreferredLocationCPU"

         for y in range(0, 6):
           if y == 0:
             FilesavingPower = "none"
           elif y == 1:
             FilesavingPower = "cudaMemAdviseSetReadMostly"
           elif y == 2:
             FilesavingPower = "cudaMemAdviseSetPreferredLocationGPU"
           elif y == 3:
             FilesavingPower = "cudaMemAdviseSetAccessedByGPU"
           elif y == 4:
             FilesavingPower = "cudaMemAdviseSetPreferredLocationGPU"
           elif y == 5:
             FilesavingPower = "cudaMemAdviseSetPreferredLocationCPU"

           label = str(w)+str(x)+str(y)
           filename = 'output_'+label+'_'+d+'.log'
           print "processing " + filename + " " 
           with open(filename, 'r') as f:
             lines = f.readlines()
             for line in lines:
               if re.search('%s'%k, line):
                 line2 = re.search('(.+)%s'%k, line).group(1)
                 print line2
                 rr = re.findall("[-+]?[.]?[\d]+(?:,\d\d\d)*[\.]?\d*(?:[eE][+\-]?\d+)?",line2)
                 #rr = re.findall("([+-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+))",line)
                 rr.insert(0, label)
                 rr.insert(0, FilesavingPower)
                 rr.insert(0, MatrixTemp)
                 rr.insert(0, memloc)
                 rr.insert(0, d)
                 rr.insert(0, k)
                 print rr
                 with open(csvfilename, 'a') as output_file:
                   writer = csv.writer(output_file)
                   writer.writerow(rr)
                 break
