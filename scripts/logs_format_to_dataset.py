# This is a python script that is used for pre-processing the original logs from GPU metrics
import csv
import glob
import re
import os,getopt

def replacecomma(matchobj):
  result = matchobj.group(0).replace(',',"")
  return result

#Here code to delete useless data lines and format to a new dataset

filenames = sorted(glob.glob('nsight_*'))

benchname_num = 0
os.remove("interim_logs.csv") if os.path.exists("interim_logs.csv") else None
for f1 in filenames:
    #benchmark_name = re.findall('nsight_(\d+).txt', f1)
    #print benchmark_name[0]
    #benchname_num += 1
    benchmark_name = re.split("[_]|.log", f1)[1]
    datasize = re.split("[_]|.log", f1)[2]
    #print(benchmark_name)

    with open(f1, "r") as f:
        lines = f.readlines()
    with open("interim_logs.csv", "a") as f:
        for line in lines:
            #r1 = re.findall('"\d+,[,|\d]+[\.]?[\d]+"',line)
            #print("1:"+line)
            line = re.sub('"\d+,[,|\d]+[\.]?[\d]+"',replacecomma,line)
            #print("2:"+line)

            line = line.replace('\n','')
            elements = re.split('","|["]$|^["]',line)
            if len(elements) > 1:
              elements = elements[1:-1]
              #print(elements)
              num_instance = elements[0] 
              if num_instance.isdigit():  #num_instance == "ID" 
                  #removing unused data  
                  del elements[1:4]
                  del elements[2:6]
                  funcname = elements[1]
                  newname = funcname.split('(')[0]
                  elements[1] = newname
                  elements.append(benchmark_name)
                  elements.append(datasize)
                  #print(elements)
                  newline = ','.join(elements)
                  f.write(newline)
                  f.write('\n') 

 
# output list:
# ID, kernelname, feature, unit, feature value, benchmark name, inputdata 

feature_write_signal = 0

# the feature list
features = ["Benchmark","InputData","ID", "Kernel"]
# the feature count
feature_num = 0
# the unit of the features
units = ["","",""]
# the value of the collected data
values_line = []

nID_value = []  #use for identify if nID has been recorded

firstrowchecked = 0
rowID = -1
currentID = ""
currentInput = ""

f = open('interim_logs.csv')
csv_f = csv.reader(f)
for row in csv_f:
   nID = row[0] 
   kernelname = row[1]
   feature = row[2]
   unit = row[3]
   value = row[4]
   bench_title = row[5]
   inputdata = row[6]

   # starting new rowID for a new kernel of a benchmark with a input data 
   if (nID != currentID) or (inputdata != currentInput):
      currentID = nID 
      currentInput = inputdata 
      values_line.append([]) # add a new line to record
      rowID += 1
      # only append these data if a new row is added 
      values_line[rowID].append(bench_title)
      values_line[rowID].append(inputdata)
      values_line[rowID].append(nID)
      values_line[rowID].append(kernelname)
   values_line[rowID].append(value)
      
   if firstrowchecked == 0:
     firstrowID = nID
     firstGroupInput = inputdata
     firstrowchecked = 1  
   # collecting features only when first ID is shown
   if (nID == firstrowID) and (inputdata == firstGroupInput) :
     features.append(feature)
     units.append(unit)
     feature_num += 1

with open('dataset.csv','w') as myfile: #you can modify output to train.csv or test.csv based on your processing
    wr = csv.writer(myfile,delimiter=',') #, quoting=csv.QUOTE_ALL)    
    wr.writerow(features)
    wr.writerows(values_line)
#print(features)
#print(values_line)
