#! /bin/bash -x

# By Jonah Shaw, 03032020
# Interpolating existing GOCCP data to a different resolution.
# Modelled after lines 207-230 in conv_ERA_interim.sh
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
year=${args[0]}         # Year to process

# Directory path for observations
obs="$HOME/p/jonahks/GOCCP_data/2Ddata"

# Directory path for new resolution
newres="$HOME/p/jonahks/resolution_stuff/res_file_f19_tn14.nc"

cd $obs/$year/

# Path for interpolated output
mkdir -p $obs/f19_tn14_interpolation/$year
outdir=$obs/f19_tn14_interpolation/$year


first_file=`ls | sort -n | head -1`
echo "First file: " $first_file

# Create weights file:
cdo genbil,$newres $first_file $obs/remapweights.nc 
new_weights=$obs/remapweights.nc

files_old=$(find *MapLowMidHigh*)  # find all GOCCP files

# iterate through and interpolate using the new res and weight files
for file_in in $files_old
do
    echo $file_in

    # I shouldn't have to do this at each step, but it removes an error that was coming up.
    cdo genbil,$newres $file_in $obs/remapweights.nc

    cdo -s remap,$newres,$new_weights $file_in $outdir/$file_in
done


