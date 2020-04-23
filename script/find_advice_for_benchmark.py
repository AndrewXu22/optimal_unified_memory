#! /usr/bin/env python
# This is a python script that is used for find the right label for the benchmark 
#and add the new unified memory advise into the benchmark cuda code
import csv
import glob
#from add_advice_benchmark import add_UM_only, add_advice
import sys

def isfloat(x):
    try:
        a = float(x)
    except ValueError:
        return False
    else:
        return True

def add_UM_only():
    with open('gaussian.cu', "r") as f:
            lines = f.readlines()
    with open('gaussian-adapt.cu', 'a') as file:
        for line in lines:
            if keywords in line:
                # now find the data that need new memory advice 
                para1 = line.split('=',1)[0]
                #print para1
                if " " in para1:
                    var1 = para1.split(' ') # vara1 is the data that need unified memory advice
                    var1 = filter(None, var1) # remove the empty string in the list
                    #if '\t' in var1:
                        #var1 = var1.remove('\t')
                para2 = line.split('malloc',1)[1]
                #print para2
                length = len(para2)
                var2 = para2[1:length-3] #the size of data that shoule be used in unified memory
                #print var2
                line = line.replace("malloc", "xplacer_malloc")
                line = line.replace(");", ", managed);")
                #here only change to use default unified memory        
                newline = str(line) + "\n "
                line = newline
            file.write(line)

def add_advice(arg1):
    advice = arg1
    with open('gaussian.cu', "r") as f:
        lines = f.readlines()

    with open('gaussian-adapt.cu', 'a') as file:
        for line in lines:
            if keywords in line:
                # now find the data that need new memory advice 
                para1 = line.split('=',1)[0]
                #print para1
                if " " in para1:
                    var1 = para1.split(' ') # vara1 is the data that need unified memory advice
                    var1 = filter(None, var1) # remove the empty string in the list
                    #if '\t' in var1:
                        #var1 = var1.remove('\t')
                para2 = line.split('malloc',1)[1]
                #print para2
                length = len(para2)
                var2 = para2[1:length-3] #the size of data that shoule be used in unified memory
                #print var2
                line = line.replace("malloc", "xplacer_malloc")
                line = line.replace(");", ", managed);")
                indent = '    '
                #here add the cudaMemAdvice into the original line and output into the file
                #depedns on different benchmarks, can modigy the number of indent ot modereate the align              
                newline = str(line) + "\n " +indent + indent + indent + "cudaMemAdvise(" + " ".join(var1).replace('\t', '') +", "+ str(var2) +", " + advice + ", 0); \n"
                line = newline
            file.write(line)



keywords="malloc"
lineList = list()
with open("label.txt") as f:
    final_advice = 'none'
    for line in f:
        value = line.split(',')
        if len(value) > 1 :
            if isfloat(value[4]):
                #print value[2], value[4]
                final_advice=value[2].split(':')[1]
                prediction_value = value[4]
                print final_advice
    print ( "The proper advice should be: " + final_advice)
    if final_advice == 'none':
        print "no model outputed label!"
        sys.exit()
    elif final_advice =='noUM':
        sys.exit()
    elif final_advice == 'UM':
        add_UM_only()
    elif final_advice == 'RM':
        advice = 'cudaMemAdviseSetReadMostly'
        add_advice(advice)
    elif final_advice == 'PL':
        advice = 'cudaMemAdviseSetPreferredLocation'
        add_advice(advice)
    elif final_advice == 'AB':
        advice = 'cudaMemAdviseSetAccessedBy'
        add_advice(advice)
    #add_advice_benchmark.main(final_advice)
