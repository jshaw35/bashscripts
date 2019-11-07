#!/bin/bash
# ^specify bash as interpreter

# Search and replace function
function ponyfyer() {
    local search=$1 ;
    local replace=$2 ;
    local loc=$3 ;
    # Note the double quotes
    sed -i "s/${search}/${replace}/g" ${loc} ;
}

# value='unchanged'

# echo $value

# Change the 12th line of the file print_params.sh to "changed_now"
# sed -i '12s/.*/'value='"changed_now"/' print_params.sh

# ./print_params.sh

# sed -i '15s/.*/'value='"changed_now"/' pretend_fortran.F90
# sed -i 's/^change_mult_here.*/'value='"changed_now"/' pretend_fortran.F90

#sed -i "s/^change_mult_here.*/Current date is today/" pretend_fortran.F90

pwd

CASEROOT=~/git_repos/bashscripts
CASENAME=pretend_fortran.F90

cd
pwd

mgcam_path=/${CASEROOT}/${CASENAME}
ponyfyer 'before' 'after' ${mgcam_path}