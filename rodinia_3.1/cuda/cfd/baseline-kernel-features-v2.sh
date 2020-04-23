#!/bin/bash -x
# example script to collect several metrics for a cuda program
# this does not work properly. 
# the log file names have specific fields for the python scripts to work. 
# right now, just follow the original script's way for log file names. 

##### These are shell commands

BIN_PATH=`hostname`-executable
RESULT_PATH=`hostname`-kernel-level-measurement
NSIGHT_TOOL=/usr/local/cuda-10.2/bin/nv-nsight-cu-cli
date

if [ ! -d "$BIN_PATH" ]; then
 echo "$BIN_PATH" does not exist!
 exit 1
fi



if [ ! -d "$RESULT_PATH" ]; then
  mkdir -p $RESULT_PATH
fi

if [ ! -d "$RESULT_PATH" ]; then
 echo "$RESULT_PATH" does not exist!
 exit 1
fi


echo 'CFD'


dataSizes=(
    "fvcorr.domn.097K"
    "fvcorr.domn.193K"
    "missile.domn.0.2M"
    )
# get length of an array
tLen=${#dataSizes[@]}

# use for loop read all filenames
for (( i=0; i<${tLen}; i++ ));
do
echo "-----------${dataSizes[$i]}----------"
#  nv-nsight-cu-cli --section ${myArray[$i]} --list-metrics

 if [ ! -f ./$BIN_PATH/cfd_000 ] ; then
     echo "./$BIN_PATH/cfd_000 does not exist. aborting..."
     exit 1
 fi

 if [ ! -f ../../data/cfd/${dataSizes[$i]} ] ; then
     echo "../../data/cfd/${dataSizes[$i]} does not exist. aborting..."
     exit 1
 fi

# -s 3: Set the number of kernel launches to skip before starting to profile.
# -c 100 : Limit the number of collected profile results.
# cfd has three different data input sizes
# cfd_000 means all three objects are using descrete memory

  $NSIGHT_TOOL -s 3 -c 100  --csv ./$BIN_PATH/cfd_000 ../../data/cfd/${dataSizes[$i]} > ./$RESULT_PATH/nsight_cfd_${dataSizes[$i]}.log 

  if [ $? -ne 0 ]; then
    echo "Fatal error: nv-nsight-cu-cli error!"
    exit 1
  fi

done

echo 'Done'
