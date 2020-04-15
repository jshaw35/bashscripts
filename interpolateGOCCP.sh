#! /bin/bash -x

# By Jonah Shaw, 03032020
# Interpolating existing reanalysis data to a different resolution.
# Modelled after lines 207-230 in conv_ERA_interim.sh
# TO-DO: build in 'help' feature using getopt

# Example use:
# sh interpolate.sh ERA_f19_tn14/res_file_T.nc ERA_f09f09_32L_days/ ERA_f19_tn14/ 2008


############
# SET INPUT ARGS
############

args=("$@")
res_file=${args[0]}     # Path to an output file with appropriate resolution
old_path=${args[1]}     # Directory path to reanalysis files to interpolate
new_path=${args[2]}     # Directory path to store data
year=${args[3]}         # Year to process

echo $res_file $old_path $new_path $year # this works

# Create weights file from res_file:
# 1: Grab T coordinates from res_file (simplest option)
# cdo -s selname,T $res_file $new_path/res_file_T.nc
# new_res=$new_path/res_file_T.nc 

first_file = ls $old_path/ | head -n 1
echo $first_file

# 2: Create weights file for res_file's resolution
cdo -s genbil,$res_file $first_file $new_path/weights.nc
new_weights=$new_path/weights.nc

# Say ifile contains fields on a quadrilateral curvilinear grid. 
# To remap all fields bilinear to a Gaussian N32 grid use: 
# cdo genbil,n32 ifile remapweights.nc # creates the weights file
# cdo remap,n32,remapweights.nc ifile ofile


# cdo genbil,grid.nc infile weights.nc # grid.nc is the new grid, inf
# cdo remap,grid.nc,weights.nc infile remapped.nc

cd $old_path

files_old=$(find *MapLowMidHigh*)  # find all files for your year

echo $files_old

exit 1

# iterate through and interpolate using the new res and weight files
for file_in in $files_old
do
    echo $file_in
    cdo -s remap,$new_res,$new_weights $file_in $new_path/$file_in
done

exit 1
