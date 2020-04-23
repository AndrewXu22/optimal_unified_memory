#!/bin/bash -x
# this one does not work with later python3 scripts.
# they expect log names like _097K.log, _193K.log, _missile0.2M.log . 
BIN_PATH=`hostname`-executable
RESULT_PATH=`hostname`-data-level-measurement

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

 if [ ! -f ./$BIN_PATH/cfd_111 ] ; then
     echo "./$BIN_PATH/cfd_111 does not exist. aborting..."
     exit 1
 fi

 if [ ! -f ../../data/cfd/${dataSizes[$i]} ] ; then
     echo "../../data/cfd/${dataSizes[$i]} does not exist. aborting..."
     exit 1
 fi

#  $NSIGHT_TOOL -s 3 -c 100  --csv ./$BIN_PATH/cfd_000 ../../data/cfd/${dataSizes[$i]} > ./$RESULT_PATH/nsight_cfd_${dataSizes[$i]}.log
  nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./$BIN_PATH/cfd_111 ../../data/cfd/${dataSizes[$i]} &> ./$RESULT_PATH/GPUTraceOutput_111_${dataSizes[$i]}.log
#nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/cfd_111 ../../data/cfd/fvcorr.domn.193K &> ./data-level-measurement/GPUTraceOutput_111_193K.log
#nvprof --unified-memory-profiling per-process-device --print-gpu-trace ./lassen-executable/cfd_111 ../../data/cfd/missile.domn.0.2M &> ./data-level-measurement/GPUTraceOutput_111_missile0.2M.log

  if [ $? -ne 0 ]; then
    echo "Fatal error: nvprof error!"
    exit 1
  fi

done

echo 'Done'
