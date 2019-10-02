#!/bin/bash
# ^specify bash as interpreter

# Started by Jonah Shaw 19/10/02
# Testing passed values from parameter .csv through python

#echo $# arguments passed
args=("$@")
echo ${args[0]} ${args[1]} ${args[2]}
sleep 20