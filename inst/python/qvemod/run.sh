#!/bin/bash
cmd=$1
echo running $cmd

if [ $cmd = "build" ]
then
    docker build . -t small-scale-corona
elif [ $cmd = "interactive" ]
then
    docker run -it small-scale-corona 
fi


