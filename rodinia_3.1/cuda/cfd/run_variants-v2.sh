#!/bin/bash -x

BIN_PATH=`hostname`-executable
RESULT_PATH=`hostname`-kernel-level-measurement/variants

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


for i in `seq 0 6`;
do

echo "----------------------"
echo date
echo $i 


for j in `seq 0 6`;
do
for k in `seq 0 6`;
do
echo $i $j $k
nvprof -u ms --log-file ./$RESULT_PATH/output_$i$j${k}_097K.log ./$BIN_PATH/cfd_$i$j$k ../../data/cfd/fvcorr.domn.097K
if [ $? -ne 0 ]; then
    echo "Fatal error: nvprof error for 097k !"
    exit 1
fi

nvprof -u ms --log-file ./$RESULT_PATH/output_$i$j${k}_193K.log ./$BIN_PATH/cfd_$i$j$k ../../data/cfd/fvcorr.domn.193K
if [ $? -ne 0 ]; then
    echo "Fatal error: nvprof error for 193k !"
    exit 1
fi
nvprof -u ms --log-file ./$RESULT_PATH/output_$i$j${k}_missile.domn.0.2M.log ./$BIN_PATH/cfd_$i$j$k ../../data/cfd/missile.domn.0.2M
if [ $? -ne 0 ]; then
    echo "Fatal error: nvprof error for 0.2M !"
    exit 1
fi
done    
done    
done    
