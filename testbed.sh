#!/bin/bash
# ^specify bash as interpreter

# Started by Jonah Shaw 19/9/26
# Testing bash scripts offline to learn functionality

dir1=~/Documents/bash_scripts

cd $dir1

models=("noresm-dev", "cesm", "noresm-dev-10072019")
compsets=("NF2000climo", "N1850OCBDRDDMS")
resolutions=("f19_tn14")

# Where ./create_case is called from:
Modelroot=/cluster/home/jonahks/p/jonahks/models/${models[2]}/cime/scripts

# Where the case it setup, and user_nl files are stored
CASEROOT=/cluster/home/jonahks/p/jonahks/cases

# Where FORTRAN files contains microphysics modifications are stored
# May require future subdirectories
ModSource=/cluster/home/jonahks/p/jonahks/modfiles

# Case name, unique, could be configured as an input arg:
CASENAME=NF2000climo_reshere_initialtest

COMPSET=${compset[0]} 		# NF2000climo
RES=${resolutions[0]}           # f19_tn14
MACH=fram
PROJECT=nn9600k
MISC=--run-unsupported

# Create env_*.xml files
./create_newcase --case ${CASEROOT}/${CASENAME} \
                 --compset ${COMPSET} \
                 --res ${RES} \
                 --mach ${MACH} \
                 --project ${PROJECT} \
                 $MISC

cd $CASEROOT/${CASENAME} # Move to the case's dir

# Set run time and restart variables within env_run.xml
#./xmlchange --file=env_run.xml RESUBMIT=3
./xmlchange --file=env_run.xml STOP_OPTION=nmonth
./xmlchange --file=env_run.xml STOP_N=1
#./xmlchange --file=env_run.xml REST_OPTION=nyears
#./xmlchange --file=env_run.xml REST_N=5
#./xmlchange -file env_build.xml -id CAM_CONFIG_OPTS -val '-phys cam5'

# Do I need to modify the env_mach_pres.xml file here? How do I do that?

# Move modified WBF process into SourceMods dir:
cp $ModSource/micro_mg_cam.F90 /$CASEROOT/${CASENAME}/SourceMods/src.cam
cp $ModSource/micro_mg2_0.F90 /$CASEROOT/${CASENAME}/SourceMods/src.cam

# Move modified INP nucleation process into SourceMods dir:
cp $ModSource/microp_aero.F90 /$CASEROOT/${CASENAME}/SourceMods/src.cam
cp $ModSource/nucleate_ice_cam.F90 /$CASEROOT/${CASENAME}/SourceMods/src.cam
cp $ModSource/nucleate_ice.F90 /$CASEROOT/${CASENAME}/SourceMods/src.cam


# Will need to set these values in some manner now

# Set up case, creating user_nl_* files
./case.setup

# Will need to modify the nl files appropriately here to choose output
# CAM adjustments, I don't entirely understand the syntax here, but all the formatting after the first line is totally preserved:
#cat <<TXT2 >> user_nl_cam
#&aerosol_nli  # Not sure what this is.
# fincl1 = # list variables to add to first history file here
# TXT2

# build, create *_in files under run/
./case.build

# Submit the case
./case.submit


