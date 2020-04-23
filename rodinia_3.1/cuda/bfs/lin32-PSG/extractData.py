#!/usr/bin/python
import sys
import re
import csv

csvfilename = 'bfs_stat.csv'
inputdata = ['graph4096', 'graph65536', 'graph1MW_6']

csvcolumn = ["kernel", "Input", "MemLocation","Array","MemAdvise","label","TimePerc","Time","calls","AVG","MIN","MAX"]
kernels = ["Kernel","Kernel2"]

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
           advise = "none"
         elif x == 1:
           advise = "cudaMemAdviseSetReadMostly"
         elif x == 2:
           advise = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 3:
           advise = "cudaMemAdviseSetAccessedByGPU"
         elif x == 4:
           advise = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 5:
           advise = "cudaMemAdviseSetPreferredLocationCPU"

         for y in range(0, 7):
           if y == 0:
             target = "none"
           elif y == 1:
             target = "h_graph_nodes"
           elif y == 2:
             target = "h_graph_edges"
           elif y == 3:
             target = "h_graph_mask"
           elif y == 4:
             target = "h_updating_graph_mask"
           elif y == 5:
             target = "h_graph_visited"
           elif y == 6:
             target = "h_cost"


           label = str(w)+str(y)+str(x)
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
                 rr.insert(0, advise)
                 rr.insert(0, target)
                 rr.insert(0, memloc)
                 rr.insert(0, d)
                 rr.insert(0, k)
                 print rr
                 with open(csvfilename, 'a') as output_file:
                   writer = csv.writer(output_file)
                   writer.writerow(rr)
                 break
