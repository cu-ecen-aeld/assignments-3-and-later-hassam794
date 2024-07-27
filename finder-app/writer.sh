#!/bin/bash

writefile=$1
writestr=$2

if [ -z $writefile ] || [ -z $writestr ]; then
echo 'Parameter mismatch: ./writer.sh <directory> <string>' 
exit 1
else
    if mkdir -p $(dirname $writefile)
    then
    echo $writestr > $writefile
    exit 0
    else
    echo "Error: File not created"
    exit 1
    fi
fi
