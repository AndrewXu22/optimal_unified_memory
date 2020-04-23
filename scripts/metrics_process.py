# This is a python script that is used for pre-processing the original logs from GPU metrics
import csv
import glob
import re
import os

#Here code to delete useless data lines and format to a new dataset

filenames = sorted(glob.glob('nsight_*'))

benchname_num = 0

for f1 in filenames:
    #benchmark_name = re.findall('nsight_(\d+).txt', f1)
    #print benchmark_name[0]
    #benchname_num += 1
    benchmark_name = re.split("[_.]", f1)[-1]
    print benchmark_name

    with open(f1, "r") as f:
        lines = f.readlines()
    with open("interim_logs.csv", "a") as f:
        for line in lines:
            line = line.replace('"', '')
            #here to attach the name of benchmark, so that can merge them together at one time
            line = ','.join([line.strip(), benchmark_name, '\n'])
            #line.append(benchmark_name)
            num_instance = line.split(",")[0]
            if num_instance.isdigit():  #num_instance == "ID" 
                f.write(line)
 
  
feature_write_signal = 0

features = []
feature_num =0
units = []
values_line = []
nID_value = []  #use for identify if nID has been recorded

#first_line = f.readline()
original_nID = ""
original_pID = 0
k = -1
n = 1
i = 1

f1 = open('interim_logs.csv')
csv_f1 = csv.reader(f1)
row1 = next(csv_f1) 
bench_title = row1[12]

f = open('interim_logs.csv')
csv_f = csv.reader(f)
for row in csv_f:
    nID = row[0]
    bench_name = row[12]

    #print nID,pID
    if bench_name == bench_title :
        #bench_title = benchmark_name
        if nID != original_nID : 
            #original_pID = pID
            original_nID = nID
            values_line.append([]) # add a new line to record
            k += 1  
            m = int(nID)
            if m not in nID_value: #nID only record once
                nID_value.append(m)
                #benchmark_set.append(row[2])
                if n == 1 : #here record "kernel_info" and "ID" only once
                    features.append("kenel_info") # kernel name
                    features.append("ID")
                    features.append("benchmark_name")
                    features.append(row[9]) # metric name
                    n = n - 1
                #features.append(row[12])  #benchmark name
                
                values_line[k].append(row[4]) #here record the kernel name
                values_line[k].append(row[0]) # here record the nID
                values_line[k].append(row[12]) #benchmark name
                values_line[k].append(row[11].replace("\\", "")) # values of metric
        elif nID == original_nID : #and nID == original_nID :
            #print pID, nID
            if nID == '0' and row[12] == bench_title: # here to record all feature name only once
                features.append(row[9])
                units.append(row[10])
            values_line[k].append(row[11].replace("\\", ""))
    else: # row[2](benchmark_name) != bench_title  means read data from another benchmark
        nID = row[0]
        if nID != original_nID : 
            #original_pID = pID
            original_nID = nID
            values_line.append([]) # add a new line to record
            k += 1  
            values_line[k].append(row[4]) #here record the kernel name
            values_line[k].append(row[0]) # here record the nID
            values_line[k].append(row[12]) #benchmark name
            values_line[k].append(row[11].replace("\\", "")) # values of metric
        elif nID == original_nID : #and nID == original_nID :
            values_line[k].append(row[11].replace("\\", ""))
    #print k
    #print values_line
#feature_set = set(features)
#print feature_set    
with open('bfs_final.csv','a+') as myfile:
    wr = csv.writer(myfile,delimiter=',') #, quoting=csv.QUOTE_ALL)    
    wr.writerow(features)
    wr.writerows(values_line)
#os.remove("interim_logs.csv")

