#!/bin/bash

writefile=$1
writestr=$2

if [ -z $writefile ] || [ -z $writestr ]; then
echo 'Parameter mismatch: ./writer.sh <directory> <string>' 
exit 1
else
mkdir -p $(dirname $writefile)
echo $writestr > $writefile
exit 0
fi
