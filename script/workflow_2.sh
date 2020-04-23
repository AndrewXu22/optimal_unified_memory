#!/bin/bash
# Online Runtime Data Collection:
# 
# TODO: need to run nvprof also to collect object level metrics.
#       the code's memory allocations have to be instrumented to correlate to virtual addresses.
# 
#2.1 You can use the script to run nsight command line to collect the runtime
#  logs from new benchmarks/applications (note that this script will automatically
#    format, normalize, and save the new data into test.arff file (the test dataset))
# 2.2 Details of normalization and label work follow the same role in workflow_1.sh
# 2.3 In some cases, if it takes more than several minutes in the nsight to
# fetch data, you can interrupt it

#This is the script that can run benchmark with nsight to collect metrics,
#due to some bechmarks may not finished with nsight in few minutes
#you can interrupt this to get the runtime logs

cd /Users/xu20/Documents/LLNL_work/prototype_llnl/output_to_arff

#1. Run nsight with benchmark to get all metrics
#Here needs: (a). nsight from root access (b). benchmark and input data files (assume you already put here)
#(c). feature list file that contains the metrics nsight can fetch
#(d). specify the path where to store the collected metrics
# More details: 
#   (a). find the proper path to "nv-nsight-cu-cli"
#   (b). --metrics collect the features from the related feature list file 207.txt, so need to put the 207.txt in the directory
#   (c). --csv store the collect logs into csv file
#   (d). ./benchmarks/bfs/bfs_adapt_00 ./benchmarks/data/bfs/graph65536.txt use the benchmark with input file
#   (e). >> ./logs/nsight_bfs_UM  store the logs with csv format into "nsight_bfs_UM" file

sudo /usr/local/cuda-10.1/NsightCompute-2019.3/nv-nsight-cu-cli --metrics $(./207.txt)  --csv ./benchmarks/bfs/bfs_adapt_00 ./benchmarks/data/bfs/graph65536.txt >> ./logs/nsight_bfs_UM

