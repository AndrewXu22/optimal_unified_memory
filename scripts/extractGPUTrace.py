#!/opt/anaconda3/bin/python3
import sys
import glob
import re
import csv

filenames = sorted(glob.glob('GPUTraceOutput_*'))

csvfilename = 'GPUTrace.csv'
# key words printed by adapter library
regex = re.compile('in api range')
# key words printed in code to identify data name
match = re.compile('alloc ')

csvcolumn = ["Data","DataID", "variant", "InputData", "BeginAddr", "EndAddr","DataSize", "CPUPageFault", "GPUPagePault", "HtoD", "DtoH", "RemoteMap" ]

with open(csvfilename, 'w') as output_file:
  writer = csv.writer(output_file)
  writer.writerow(csvcolumn)


for f1 in filenames:
    variant = re.split("[_]|.log", f1)[1]
    inputData = re.split("[_]|.log", f1)[2]
    #print("%s %s",variant, inputData) 
    dataset = {}
    GPUFault = {}
    CPUFault = {}
    HtoD = {}
    DtoH = {}
    RemoteMap = {}
    with open(f1, "r") as f:
        lines = f.readlines()
        for line_i, line  in enumerate(lines):
            if regex.search( line ):
              #print (re.findall("0x[0-9a-fA-F]+",line)[0])
              #print (re.findall("0x[0-9a-fA-F]+",line)[1])
              nameline = lines[line_i-2]
              if match.match(nameline):
                dataset[nameline[match.search(nameline).end():-1]] = [re.findall("0x[0-9a-fA-F]{12}",line)[0], re.findall("0x[0-9a-fA-F]+",line)[1]]

    for k, v in dataset.items():
      # k is data name; v[0] is lower bound of address; v[1] is upper bound of address
      # print(v[0],v[1])
      # convert address to int for comparison
      lowbound = int(v[0], 16)
      upbound = int(v[1], 16)
      dataSize = upbound - lowbound
      GPUFault[k] = 0
      CPUFault[k] = 0
      HtoD[k] = 0.
      DtoH[k] = 0.
      RemoteMap[k] = 0.
      # going through the log second time to get the counts for each details
      for line  in lines:
        if(re.search("0x[0-9a-fA-F]{12}",line)):
          addr = re.search("0x[0-9a-fA-F]{12}",line)[0]
          addrint = int(addr, 16) 
          # check if the virtual address fit into the data address range      
          if(addrint >= lowbound and addrint <= upbound):          
            if re.search("Unified Memory GPU page", line):
              faultcount = re.search("[0-9]+[ ]{3}"+addr,line)[0]
              faultcount = faultcount.replace('   '+addr,'')
              GPUFault[k] = GPUFault[k]+int(faultcount,10)
              #print(GPUFault[k],":",faultcount)
            elif re.search("Unified Memory CPU page", line):
              CPUFault[k] = CPUFault[k]+1
            elif re.search("Unified Memory Memcpy HtoD", line):
              HtoDsize = re.search("[0-9]+[.][0-9]+[GMK][B][ ]{3}"+addr,line)[0]
              HtoDsize = HtoDsize.replace('   '+addr,'')
              size = 0.
              if(re.search("GB",HtoDsize)):
                size = float(HtoDsize.replace('GB','')) * 1048576.
              elif(re.search("MB",HtoDsize)):
                size = float(HtoDsize.replace('MB','')) * 1024.
              else:
                size = float(HtoDsize.replace('KB','')) * 1.
    
              HtoD[k] = HtoD[k]+size
              #print(HtoD[k],":",size)
            elif re.search("Unified Memory Memcpy DtoH", line):
              DtoHsize = re.search("[0-9]+[.][0-9]+[GMK][B][ ]{3}"+addr,line)[0]
              DtoHsize = DtoHsize.replace('   '+addr,'')
              size = 0.
              if(re.search("GB",DtoHsize)):
                size = float(DtoHsize.replace('GB','')) * 1048576.
              elif(re.search("MB",DtoHsize)):
                size = float(DtoHsize.replace('MB','')) * 1024.
              else:
                size = float(DtoHsize.replace('KB','')) * 1.
    
              DtoH[k] = DtoH[k]+size
              #print(DtoH[k],":",size)
            elif re.search("Unified Memory remote map", line):
              RemoteMapsize = re.search("[0-9]+[.][0-9]+[GMK][B][ ]{3}"+addr,line)[0]
              RemoteMapsize = RemoteMapsize.replace('   '+addr,'')
              size = 0.
              if(re.search("GB",RemoteMapsize)):
                size = float(RemoteMapsize.replace('GB','')) * 1048576.
              elif(re.search("MB",RemoteMapsize)):
                size = float(RemoteMapsize.replace('MB','')) * 1024.
              else:
                size = float(RemoteMapsize.replace('KB','')) * 1.
    
              RemoteMap[k] = RemoteMap[k]+size
              #print(RemoteMap[k],":",size)
      #print(list(dataset.keys()).index(k))
      rdata = [k, list(dataset.keys()).index(k), variant, inputData, v[0], v[1], dataSize, CPUFault[k],GPUFault[k], HtoD[k], DtoH[k]  ,RemoteMap[k]]
      #print(rdata)
      with open(csvfilename, 'a') as output_file:
        writer = csv.writer(output_file)
        writer.writerow(rdata)

