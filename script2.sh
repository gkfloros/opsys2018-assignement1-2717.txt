#!/bin/bash
resources="resources"
assignments="assignments"
rm -rf $resources
rm -rf $assignments
#check for only one parameter
if [ $# -ne 1 ]
then
  echo "$0 needs to a tar.gz file to read"
fi
mkdir -p $resources
mkdir -p $assignments
tar xz $1 -C $resources
cd $resources
#find all the simple text files (.txt) get the line starts with https
for i in `find . -type f -name "*.txt"`; do
  gitUrl=`cat $i | grep "^https" | head -1`
  if [ "$gitUrl" != "" ]; then
    cd ../$assignments
    git clone -q $gitUrl >/dev/null 2>&1 #redirecting in case if fails
    if [ $? -eq 0 ]; then
      echo $gitUrl ": Cloning OK"
    else
      echo $gitUrl ": Cloning FAILED" >&2
    fi
    cd ../$resources
  fi
done
cd ../$assignments
for i in `ls`; do
  echo "$i :"
  numberOfDirectries=`find $i -type d | grep -v "$i/.git" | wc -l`
  numberOfDirectries=$((numberOfDirectries-1))
  numberOfTxts=`find $i -type f | grep -v "$i/.git" | grep ".txt$"| wc -l`
  numberOfRest=`find $i -type f | grep -v "$i/.git" | grep -v ".txt$"| wc -l`
  echo "Number of direcories : $numberOfDirectries"
  echo "Number of txt files : $numberOfTxts"
  echo "Number of other files : $numberOfRest"
  if [ $numberOfDirectries -eq 1 ] && [ $numberOfTxts -eq 3 ] && [ $numberOfRest -eq 0 ]; then
    if [ `find $i -type f | grep "$i/dataA.txt" | wc -l` -eq 1 ] && [ `find $i -type f | grep "$i/more/dataB.txt" | wc -l` -eq 1 ] && [ `find $i -type f | grep "$i/more/dataC.txt" | wc -l` -eq 1 ]
    then
      echo Directory Structure is OK
    else
      echo Directory Structure is NOT OK
    fi
  else
    echo Directory Structure is NOT OK
fi
done
    
