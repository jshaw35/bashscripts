#!/bin/bash

# Authors: 
# Inger Helene H. Karset <i.h.h.karset@geo.uio.no>
# Matthias Hummel <hummel@geo.uio.no>
# Date: 08.09.2016

# Script will create metdata for NorESM from ERA-interim data.
# Usage: ./conv_ERA-interim.sh <year>

# Download monthly ERA-interim 3D fields with upload_era_interim3D.py
# and name the files <year>_<mon>.grb
# Download yearly ERA-interim surface data with upload_era_interim_surf.py
# and name the file surf_<year>.grb

# Requires python and cdo modules
# Needs files date_info_day.py and modify_vct.py in same folder

# Needs old NorESM output file with requested horizontal resolution
# can be named res_file.nc in the same folder or specified later

# Output will be placed in a new folder called <year>

# Important note for running NorESM:
# calendar type ("CALENDAR") in env_buid.xml must be set to "GREGORIAN" for leap years

if [ -z $1 ]
then
  year="======= Year not specified! ========"
  echo $year
  echo "Usage: ./conv_ERA-interim.sh <year>"
  exit
elif [ -n $1 ]
then
  year=$1
fi

# create working directory
path=$(pwd)
#if [ -d "${path}/$year" ]
#then
#  echo "Error: Target folder already exists!"
#  exit
#else
#  mkdir ${path}/$year
#fi

# reads 3D grib files
files=./rawdata/${year}/${year}*.grb


# check if all months are present
check_months=(false false false false false false false false false false false false)
for file_in in $files
do
  months=${file_in#*_}
  months2=${months%.*}
  case $months2 in
    "jan") check_months[0]=true ;;
    "feb") check_months[1]=true ;;
    "mar") check_months[2]=true ;;
    "apr") check_months[3]=true ;;
    "may") check_months[4]=true ;;
    "jun") check_months[5]=true ;;
    "jul") check_months[6]=true ;;
    "aug") check_months[7]=true ;;
    "sep") check_months[8]=true ;;
    "oct") check_months[9]=true ;;
    "nov") check_months[10]=true ;;
    "dec") check_months[11]=true ;;
    *) echo "unknown months" ;;
   esac
done

for i in {0..11}
do
  if ! ${check_months[$i]}
  then
    echo "months" $((i+1)) "does not exist"
    read -r -p "continue anyway? (y/n)" yn
    case $yn in
      [Nn]) exit ;;
      [Yy]) ;;
      *) exit ;;
    esac
#  elif ${check_minths[$i]}
#  then
#    echo "months" $((i+1)) "is there"
  fi
done

# switch to working directory
#cd $year

# check for existing res_file.nc
if [ -f ${path}/res_file.nc ]
then
  spec_res_file=false
  cdo -s griddes ${path}/res_file.nc > res_file.txt
  xinc=$(grep "xinc" res_file.txt)
  yinc=$(grep "yinc" res_file.txt | head -1)
  echo -e "res_file.nc found in path "$path" \n ( resolution: " $xinc $yinc ")"
  read -r -p "use existing res_file? (y/n)" yn
  case $yn in
    [Yy]) ;; #cp ${path}/res_file.nc ${path}/${year}/res_file.nc ;;
    [Nn]) spec_res_file=true ;;
    *) exit ;;
  esac
  rm res_file.txt
  else
  spec_res_file=true
fi
if [ "$spec_res_file" = true ]
then
  read -r -p $'Please specify name of your res_file (including path) \n' path_resfile
  if [ -f $path_resfile ]
  then
    cp $path_resfile ${path}/${year}/res_file.nc
  else
    echo "Cannot find res_file " $path_resfile
    exit
  fi
fi

# ------------------------------------------------------------
# Start calculations

#convert surface data to netCDF
if [ -f ${path}/rawdata/${year}/surf_${year}.grb ]
then
  cdo -t ecmwf -f nc copy ./rawdata/${year}/surf_${year}.grb surf_${year}.nc
else
  echo "Cannot find surface pressure file " ${path}/rawdata/${year}/surf_${year}.grb
  exit
fi
#split surface data into monthly files
cdo -s splitmon surf_${year}.nc surf_tmp_mon
echo "------- Processing surface data done! -------"


i=0
num_files=$(ls -l $files | wc -l)
for file_in in $files
do
  fname=$(basename "$file_in" .grb)
  echo -ne "Adding surface fields to 3D data " $i"/"$num_files "\r"
  # convert 3D grib file to netCDF file
  cdo -s -t ecmwf -f nc copy $file_in tmp_${fname}.nc

  # add corresponding surface data to 3D file
  months=${fname#*_}
  case $months in

    "jan") cdo -s merge surf_tmp_mon01.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "feb") cdo -s merge surf_tmp_mon02.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "mar") cdo -s merge surf_tmp_mon03.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "apr") cdo -s merge surf_tmp_mon04.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "may") cdo -s merge surf_tmp_mon05.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "jun") cdo -s merge surf_tmp_mon06.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "jul") cdo -s merge surf_tmp_mon07.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "aug") cdo -s merge surf_tmp_mon08.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "sep") cdo -s merge surf_tmp_mon09.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "oct") cdo -s merge surf_tmp_mon10.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "nov") cdo -s merge surf_tmp_mon11.nc tmp_${fname}.nc temp_${fname}.nc ;;
    "dec") cdo -s merge surf_tmp_mon12.nc tmp_${fname}.nc temp_${fname}.nc ;;
  esac
  i=$((i+1))

  # split monthly files in dayly files
  cdo -s splitday temp_${fname}.nc temp_${fname}_day
  rm temp_${fname}.nc
done
echo -ne "Adding surface fields to 3D data " $i"/"$num_files "\r"
echo -ne "\n"
echo "------- Processing 3D data done! -------"

rm tmp*.nc
rm surf_tmp*.nc
rm surf_${year}.nc


# ------------------------------------------------------------
# change vertical resolution
cdo -s vct res_file.nc > vct_wrong.txt
#cp ${path}/modify_vct.py .
python modify_vct.py

files_nc=temp_*_day*.nc

i=0
num_files=$(ls -l $files_nc | wc -l)
for ncfiles in $files_nc
do
  echo -ne "Changing vertical resolution " $i"/"$num_files "\r"
  cdo -s --no_warnings remapeta,vct_right.txt -chname,SP,APS -selname,U,V,T,Q,SP $ncfiles vert_$ncfiles
  i=$((i+1))
done
echo -ne "Changing vertical resolution " $i"/"$num_files "\r"
echo -ne "\n"
echo "------- Changing vertical resolution done! -------"

rm vct_wrong.txt
rm vct_right.txt
rm temp_${year}*.nc


# ------------------------------------------------------------
# change horizontal resolution
cdo -s selname,T res_file.nc res_file_T.nc
cdo -s genbil,res_file_T.nc vert_temp_${year}_jan_day01.nc weights.nc

files_vert=vert_temp_${year}*.nc
i=0
for file_in in $files_vert
do
  echo -ne "Changing horizontal resolution " $i"/"$num_files "\r"
  cdo -s remap,res_file_T.nc,weights.nc $file_in horiz_$file_in
  i=$((i+1))
  ncrename -v APS,PS horiz_$file_in
done
echo -ne "Changing horizontal resolution " $i"/"$num_files "\r"
echo -ne "\n"
echo "------- Changing horizontal resolution done! -------"

rm weights.nc
rm $files_vert
rm res_file_T.nc
#rm res_file.nc


# ------------------------------------------------------------
# add date and dateses to netCDF files
files_horiz=horiz_vert_temp_${year}*.nc
#cp ${path}/date_info_day.py .
i=0
for file_in in $files_horiz
do
  months=${file_in#*${year}_}
  months2=${months%_day*}
  case $months2 in
    "jan") mon_num=01 ;;
    "feb") mon_num=02 ;;
    "mar") mon_num=03 ;;
    "apr") mon_num=04 ;;
    "may") mon_num=05 ;;
    "jun") mon_num=06 ;;
    "jul") mon_num=07 ;;
    "aug") mon_num=08 ;;
    "sep") mon_num=09 ;;
    "oct") mon_num=10 ;;
    "nov") mon_num=11 ;;
    "dec") mon_num=12 ;;
  esac
  echo -ne "Adding date file " $i"/"$num_files "\r"
  day=${file_in#*_day}
  day_num=${day%.*}
  date=${year}-${mon_num}-${day_num}

  ncap2 -s "time@units=\"days since $date 00:00:00\"" $file_in
  ncap2 -s time=time/24 $file_in ${date}.nc

  python date_info_day.py $date
  i=$((i+1))
done
echo -ne "Adding date file " $i"/"$num_files "\r"
echo -ne "\n"
echo "------- Adding date file done! -------"

rm $files_horiz
#rm modify_vct.py
#rm date_info_day.py
#cd $path
echo "------- Completed! -------"

