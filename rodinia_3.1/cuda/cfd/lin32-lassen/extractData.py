#!/usr/bin/python
import sys
import re
import csv

csvfilename = 'cfd_stat.csv'
inputdata = ['0.2M', '097K', '193K']

csvcolumn = ["kernel", "InputData", "MemLocation","h_areas","h_elements_surrounding_elements","h_normals","label","TimePerc","Time","calls","AVG","MIN","MAX"]
kernels = ["cuda_compute_flux", "cuda_time_step","cuda_compute_step_factor","cuda_initialize_variables"]

with open(csvfilename, 'wb') as output_file:
  writer = csv.writer(output_file)
  writer.writerow(csvcolumn)
  
for k in kernels:
  for d in inputdata:
     for w in range(0, 2):
       if w == 0:
         memloc = "Global"
       elif w == 1:
         memloc = "Host"
       
       for x in range(0, 6):
         if x == 0:
           hareas = "none"
         elif x == 1:
           hareas = "cudaMemAdviseSetReadMostly"
         elif x == 2:
           hareas = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 3:
           hareas = "cudaMemAdviseSetAccessedByGPU"
         elif x == 4:
           hareas = "cudaMemAdviseSetPreferredLocationGPU"
         elif x == 5:
           hareas = "cudaMemAdviseSetPreferredLocationCPU"

         for y in range(0, 6):
           if y == 0:
             helements = "none"
           elif y == 1:
             helements = "cudaMemAdviseSetReadMostly"
           elif y == 2:
             helements = "cudaMemAdviseSetPreferredLocationGPU"
           elif y == 3:
             helements = "cudaMemAdviseSetAccessedByGPU"
           elif y == 4:
             helements = "cudaMemAdviseSetPreferredLocationGPU"
           elif y == 5:
             helements = "cudaMemAdviseSetPreferredLocationCPU"

           for z in range(0, 6):
             if z == 0:
               hnormals = "none"
             elif z == 1:
               hnormals = "cudaMemAdviseSetReadMostly"
             elif z == 2:
               hnormals = "cudaMemAdviseSetPreferredLocationGPU"
             elif z == 3:
               hnormals = "cudaMemAdviseSetAccessedByGPU"
             elif z == 4:
               hnormals = "cudaMemAdviseSetPreferredLocationGPU"
             elif z == 5:
               hnormals = "cudaMemAdviseSetPreferredLocationCPU"

             label = str(w)+str(x)+str(y)+str(z)
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
                   rr.insert(0, hnormals)
                   rr.insert(0, helements)
                   rr.insert(0, hareas)
                   rr.insert(0, memloc)
                   rr.insert(0, d)
                   rr.insert(0, k)
                   print rr
                   with open(csvfilename, 'a') as output_file:
                     writer = csv.writer(output_file)
                     writer.writerow(rr)
                   break
