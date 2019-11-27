#! /bin/bash -x

#TEST=$(pwd)
#echo $TEST

FILES=$(find *.nc)
#echo $FILES

noth=0
for i in $FILES
do
    if [ $noth -eq 0 ]
    then
        noth=2
        casename=${i%%.*}
    fi
done

echo $casename.nc

#exit 1 

cdo -f nc2 mergetime *h0* ${casename}.nc # merge all h0 files and name with the casename

exit 1