#!/bin/bash

filesdir=$1
searchstr=$2
noArgu=$#


if [ -d $filesdir  ]
then
	if [ $noArgu -eq  2 ]
	then
	#grep -r --color $searchstr $filesdir
	matchingStr=$(grep -r -h --color $searchstr $filesdir | wc -l)
	nooffiles=$(ls -1 $filesdir | wc -l)
	echo "The number of files are $nooffiles and the number of matching lines are $matchingStr"
	exit 0
	else
	echo 'Parameter mismatch: ./finder.sh <directory> <string>'
	exit 1
	fi
else
echo 'First parameter does not represent a directory on the filesystem.'
exit 1
fi

