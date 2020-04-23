#This script is used to get the kernel execution time from bfs logs
import csv
import glob
import re
import os

#Here code to delete useless data lines and format to a new dataset

filenames = sorted(glob.glob('output_*'))

benchname_num = 0

for f1 in filenames:
    #benchmark_name = re.findall('nsight_(\d+).txt', f1)
    #print benchmark_name[0]
    #benchname_num += 1
    benchmark_name = re.split("[_.]", f1)[2]
    advice_name = re.split("[_]", f1)[1]
    print advice_name
    #print benchmark_name
    fp = open(f1)
    with open("bfs_time.csv", "a") as f:
        for i, line in enumerate(fp):
            if i == 4:
                kernel_time = line.split(" ")[7]
                line = ','.join([advice_name, benchmark_name, "kernel", kernel_time,  '\n'])
                #print line
                f.write(line)
            elif i == 5:
                kernel2_time = line.split(" ")[21]
                line = ','.join([advice_name, benchmark_name,  "kernel2", kernel2_time, '\n'])
                print line
                f.write(line)
        fp.close()