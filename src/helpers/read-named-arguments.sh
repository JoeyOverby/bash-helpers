#!/bin/bash


# Reference: https://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts a:b:c: flag;
do
    case "$flag" in 
        a) var1=$OPTARG;;

    esac

done

echo "Var1: $var1"