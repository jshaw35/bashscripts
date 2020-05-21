#! /bin/bash -x

# By Jonah Shaw, 03032020
# TO-DO: build in 'help' feature using getopt

# Example use:
# sh interpolateGOCCP.sh 2009

# How-to on regridding:

# Say ifile contains fields on a quadrilateral curvilinear grid.
# To remap all fields bilinear to a Gaussian N32 grid use:
# cdo genbil,n32 ifile remapweights.nc # creates the weights file
# cdo remap,n32,remapweights.nc ifile ofile


############
# SET INPUT ARGS
############

args=("$@")
# year=${args[0]}         # Year to process

# Directory path for observations
data="$HOME/p/jonahks/satcomp/CESM2_slfvars"

# Directory path for new resolution
newres="$HOME/p/jonahks/resolution_stuff/res_file_f19_tn14.nc"
res_dir="$HOME/p/jonahks/resolution_stuff"

# Path for interpolated output
# mkdir -p $obs/f19_tn14_interpolation/$year
outdir=$data

file="CESM2_slfvars.nc"

# Create weights file:
cdo genbil,$newres $data/$file $res_dir/remapweights.nc 
new_weights=$res_dir/remapweights.nc


cdo -s remap,$newres,$new_weights $data/$file $outdir/"CESM_slfvars_regrid.nc"

rm $res_dir/remapweights.nc


