#!/bin/bash
# ^specify bash as interpreter

# Copied from slf_ibkt.sh by Jonah Shaw 19/11/05
# Testing bash scripts offline to learn functionality

############
# FUNCTIONS
############

# Search and replace function
function ponyfyer() {
    local search=$1 ;
    local replace=$2 ;
    local loc=$3 ;
    # Note the double quotes
    sed -i "s/${search}/${replace}/g" ${loc} ;
}

############
# SET INPUT ARGS
############

args=("$@")
CASENAME=${args[0]}  # uniquecasename, maybe add a timestamp in the python script
wbf=${args[1]}          # wbf multiplier
inp=${args[2]}          # inp multiplier

#echo ${args[0]} ${args[1]} ${args[2]}

############
# SET CASE PARAMETERS
############

models=("noresm-dev" "cesm" "noresm-dev-10072019")
compsets=("NF2000climo" "N1850OCBDRDDMS")
resolutions=("f19_tn14")
machines=('fram')
projects=('nn9600k')

# Where ./create_case is called from:
ModelRoot=/cluster/home/jonahks/p/jonahks/models/${models[0]}/cime/scripts

# Where the case it setup, and user_nl files are stored
CASEROOT=/cluster/home/jonahks/p/jonahks/cases

# Where FORTRAN files contains microphysics modifications are stored
# May require future subdirectories
ModSource=/cluster/home/jonahks/sourcemods/wbf_slf
#ModSource=/cluster/home/jonahks/git_repos/all_cloud_mods

# Case name, unique, could be configured as an input arg:
# CASENAME=NF2000climo_reshere_initialtest

# Set indices to select from arrays here
COMPSET=${compsets[0]}
RES=${resolutions[0]}
MACH=${machines[0]}
PROJECT=${projects[0]}
MISC=--run-unsupported

# COMPSET=NF2000climo
# RES=f19_tn14
# MACH=fram
# PROJECT=nn9600k

echo ${CASEROOT}/${CASENAME} ${COMPSET} ${RES} ${MACH} ${PROJECT} $MISC

#############
# Main Script
#############

cd ${ModelRoot} # Move to appropriate directory
#pwd

#exit 1

# Create env_*.xml files
./create_newcase --case ${CASEROOT}/${CASENAME} \
                 --compset ${COMPSET} \
                 --res ${RES} \
                 --mach ${MACH} \
                 --project ${PROJECT} \
                 $MISC

exit 1

cd ${CASEROOT}/${CASENAME} # Move to the case's dir

# Set run time and restart variables within env_run.xml
#./xmlchange --file=env_run.xml RESUBMIT=3
./xmlchange --file=env_run.xml STOP_OPTION=nmonth
./xmlchange --file=env_run.xml STOP_N=1
# ./xmlchange --file=env_batch.xml JOB_WALLCLOCK_TIME=00:50:00 --subgroup case.run
#./xmlchange --file=env_run.xml REST_OPTION=nyears
#./xmlchange --file=env_run.xml REST_N=5
#./xmlchange -file env_build.xml -id CAM_CONFIG_OPTS -val '-phys cam5'

# Do I need to modify the env_mach_pres.xml file here? How do I do that?

# Move modified WBF process into SourceMods dir:
cp ${ModSource}/micro_mg_cam.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam
cp ${ModSource}/micro_mg2_0.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam

# Move modified INP nucleation process into SourceMods dir:
# cp ${ModSource}/microp_aero.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam
#cp ${ModSource}/nucleate_ice_cam.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam
# cp ${ModSource}/nucleate_ice.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam
cp ${ModSource}/hetfrz_classnuc_cam.F90 /${CASEROOT}/${CASENAME}/SourceMods/src.cam

# Now use ponyfyer to set the values within the sourcemod files. Ex:
# ponyfyer 'wahooey' 'BUTT' 'pretend_fortran.F90'
mg2_path=/${CASEROOT}/${CASENAME}/SourceMods/src.cam/micro_mg2_0.F90
#ponyfyer 'wbf_tag' ${wbf} ${mg2_path}
ponyfyer 'wbf_tag = 1.' ${wbf} ${mgcam_path}


nuc_i_path=/${CASEROOT}/${CASENAME}/SourceMods/src.cam/hetfrz_classnuc_cam.F90
ponyfyer 'inp_tag = 1.' ${inp} ${nuc_i_path}

exit 1
# Will need to set these values in some manner now

# Set up case, creating user_nl_* files
./case.setup

# Will need to modify the nl files appropriately here to choose output
# CAM adjustments, I don't entirely understand the syntax here, but all the formatting after the first line is totally preserved:
# list variables to add to first history file here
cat <<TXT2 >> user_nl_cam
&aerosol_nl  # Not sure what this is.
fincl1 = 'BERGO', 'BERGSO', 'SLFXCLD_ISOTM', 'SADLIQXCLD_ISOTM', 'SADICEXCLD_ISOTM', 'BERGOXCLD_ISOTM',
         'BERGSOXCLD_ISOTM', 'CLD_ISOTM', 'CLDTAU', 'CLD_SLF', 'CLD_ISOTM_SLF', 'MNUCCTO', 'MNUCCRO', 'MNUCCCO', 'MNUCCDOhet', 'MNUCCRO'
         'DSTFREZIMM', 'DSTFREZCNT', 'DSTFREZDEP', 'BCFREZIMM', 'BCFREZCNT', 'BCFREZDEP',
         'NUMICE10s', 'NUMICE10sDST', 'NUMICE10sBC',
         'dc_num', 'dst1_num', 'dst3_num', 'bc_c1_num', 'dst_c1_num', 'dst_c3_num'

use_hetfrz_classnuc = .true.

TXT2

exit 1

# build, create *_in files under run/
./case.build

# Submit the case
./case.submit
