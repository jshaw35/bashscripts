# ---extractFields.sh------------------------------------------------------
# 
# This shell script reads a single field from a case/experiment
# archive from the NorESM and writes it to a new file only
# retaining years given within the interval given by startYr and
# stopYr. The purpose is to manage the memory usage of the feedback
# analysis code, and the save time when re-running the code.
#
# ARGUMENTS:
#
# - $1 dataSource: current option is "noresm". If you want to extract
#   fields from other data sources, you must make sure that the files
#   and directory structures match noresm, or add code for an
#   additional dataSource option below.
#
# - $2 fieldId: name of the field to be processed
#
# - $3 path2inputData: complete path to the input data case folder
#
# - $4 path2outputData: complete path to the output data folder (where
#   the resulting file will be stored)
#
# - $5 run: name of the relevant case/run/experiment. The name must
#   math the name of a subfolder in the folder given by path2inputData.
#
# - $6 history: history file number in which the field given by
#   fieldId can be found. Only used when dataSource is noresm.
#
# - $7 and $8: retain only years within the interval defined by the
#   startYr ($5) and stopYr ($6). For the noresm, startYr and stopYr
#   are assumed to be the actual first and last years of the time
#   period to be extracted. 
#
#
# Written by Lise Seland Graff, lisesg@met.no
#

#!/bin/bash

if [ "$#" -ne 8 ]; then
    echo "Usage: $0 data-source path2intputData path2outputData fieldId run history startYr stopYr "
    echo "Example: $0 noresm /projects/NS2345K/noresm/cases /scratch/lisesg/noresm/cases TS N1850AERCN_f19_g16_161015 h0 0631 6032"
    exit 1
else
    dataSource=$1
    fieldId=$2
    path2inputData=$3
    path2outputData=$4
    run=$5
    history=$6
    startYr=$(printf "%04d" $7)
    stopYr=$(printf "%04d" $8)
fi

# Function for extracting NorESM data
if [ "$dataSource" == "noresm" ] ; then
    # ---Output file name and directory----------------------------------------
    outFile=$path2outputData/${run}_${history}_${fieldId}_${startYr}-${stopYr}.nc
    if [ ! -e $path2outputData/ ] ; then
	mkdir -p $path2outputData/
    fi
    
    # ---Loop over years between startYr and stopYr, extracting the variable fieldId for each year
    tell=0
    for yr in $(seq -w ${startYr} ${stopYr}) ; do
        # List files for year current year (yr)
        files=$(ls $path2inputData/*$history*$yr*.nc)
        # Loop through files, extracting variable fieldId to a separate file
        for file in $files ; do
#     	ncks -O -v $fieldId,hyam,hybm,P0,gw $file $path2outputData/${fieldId}_$(printf "%05d" $tell).nc
ncks -O -v $fieldId $file $path2outputData/${fieldId}_$(printf "%05d" $tell).nc
    	tell=$(($tell+1))
        done
    done
    
    # ---Merge files----------------------------------------------------------- 
    ncrcat -O $path2outputData/${fieldId}_*.nc $outFile
    
    # ---Delete redundant files------------------------------------------------
    rm $path2outputData/${fieldId}_*.nc
fi






