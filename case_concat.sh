#! /bin/bash -x

############
# SET INPUT ARGS
############

args=("$@")
dir_path=${args[0]}     # Directory path to h0 files

# If running out of a directory and not passing it as an argument
if [ $# -eq 0 ] ;  then
   FILES=$(find *.nc)
else
   cd  ${dir_path}
fi

echo combining files in ${dir_path}

FILES=$(find *.nc)
echo $FILES

# Weird for loop to grab casename.
noth=0
for i in $FILES
do
    if [ $noth -eq 0 ]
    then
        noth=2
        # casename=${i%%.*} # problem here if '.' included in the casename. What to do?
        casename=${i::-18} # This should work for the extension format '.cam.h0.0002-03.nc'
    fi
done

echo $casename.nc

#exit 1 

cdo -f nc2 mergetime *h0* ${casename}.nc # merge all h0 files and name with the casename

exit 1
