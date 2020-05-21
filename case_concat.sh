#! /bin/bash -x

##########################
# Variables to concatenate
##########################

# Get all possible variables of use, just not selected if not present.
# vars="NUMICE,BERGO,BERGSO,MNUCCTO,MNUCCRO,MNUCCCO,MNUCCDOhet,MNUCCDO,DSTFREZIMM,\
# DSTFREZCNT,DSTFREZDEP,BCFREZIMM,BCFREZCNT,BCFREZDEP,NUMICE10s,NUMICE10sDST,\
# NUMICE10sBC,dst1_num,dst3_num,bc_c1_num,dst_c1_num,dst_c3_num,\
# bc_num_scaled,dst1_num_scaled,dst3_num_scaled,DSTNIDEP,DSTNICNT,DSTNIIMM,\
# BCNIDEP,BCNICNT,BCNIIMM,NUMICE10s,NUMIMM10sDST,NUMIMM10sBC,MPDI2V,MPDI2W,\
# QISEDTEN,NIMIX_CNT,NIMIX_IMM,NIMIX_DEP,MNUDEPO,NNUCCTO,NNUCCCO,\
# NNUDEPO,NIHOMOO,HOMOO,SLFXCLD_ISOTM,CLD_ISOTM,CT_SLFXCLD_ISOTM,CT_CLD_ISOTM,\
# AREI,AREL,FREQI,FREQL,AWNI,AWNC,ACTNI,ACTNL,ACTREI,ACTREL,CLDFREE,CLDHGH,\
# CLDICE,CLDLIQ,CLDLOW,CLDMED,CLDTAU,CLDTOT,CLOUD,IWC,LWCF,SWCF,NUMLIQ,gw,\
# NUMRAI,PS,T,TS,CLDLOW_CAL,CLDMED_CAL,CLDHGH_CAL,CLDTOT_CAL,CLD_CAL,CLD_CAL_LIQ,\
# CLD_CAL_ICE,CLD_CAL_UN,CLDTOT_CAL_ICE,CLDTOT_CAL_LIQ,CLDTOT_CAL_UN,CLDHGH_CAL_ICE,\
# CLDHGH_CAL_LIQ,CLDHGH_CAL_UN,CLDMED_CAL_ICE,CLDMED_CAL_LIQ,CLDMED_CAL_UN,\
# CLDLOW_CAL_ICE,CLDLOW_CAL_LIQ,CLDLOW_CAL_UN,CLTMODIS,CLWMODIS,CLIMODIS,\
# CLHMODIS,CLMMODIS,CLLMODIS,\
# FCTI,FCTL,FLDS,FLNS,FLNSC,FLNT,FLNTC,FLNTCLR,FLUT,FLUTC,FSDSC,FSNS,FSNSC,FSNT,FSNTC,\
# FSNTOA,FSNTOAC,FSUTOA"

# Selected variables.
vars="gw,LANDFRAC,FSNT,FLNT,PS,T,TS,LWCF,SWCF,\
SLFXCLD_ISOTM,CLD_ISOTM,CT_SLFXCLD_ISOTM,CT_CLD_ISOTM,\
AREI,AREL,FREQI,FREQL,AWNI,AWNC,ACTNI,ACTNL,ACTREI,ACTREL,CLDLIQ,CLDICE,NUMICE,\
CLDHGH,CLDLOW,CLDMED,CLDFREE,CLDTOT,CLDTAU,CLOUD,NUMLIQ,\
CLDLOW_CAL,CLDMED_CAL,CLDHGH_CAL,CLDTOT_CAL,CLD_CAL,CLD_CAL_LIQ,\
CLD_CAL_ICE,CLD_CAL_UN,CLDTOT_CAL_ICE,CLDTOT_CAL_LIQ,CLDTOT_CAL_UN,CLDHGH_CAL_ICE,\
CLDHGH_CAL_LIQ,CLDHGH_CAL_UN,CLDMED_CAL_ICE,CLDMED_CAL_LIQ,CLDMED_CAL_UN,\
CLDLOW_CAL_ICE,CLDLOW_CAL_LIQ,CLDLOW_CAL_UN,DSTFREZCNT,DSTFREZDEP,DSTFREZIMM,\
DST_A2,DST_A2_OCW,DST_A3,DST_A3_OCW,dst1_num,dst3_num,dst_c1_num,dst_c3_num"
# echo $cospvars

#exit 1

###########
# SET INPUT ARGS
############

#args=("$@")
dir_path=${1:-none}

# If running out of a directory and not passing it as an argument
if [ $# -eq 0 ] ;  then
   FILES=$(find *.nc)
else
   cd  ${dir_path}
fi

echo combining files in ${dir_path}

FILES=$(find *.nc)
#echo $FILES

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

# exit 1

#cdo -f nc2 mergetime *h0* ${casename}.nc # merge all h0 files and name with the casename

#cdo select,name=u_gr_p,v_gr_p,u_10m_gr,v_10m_gr,DateTime $FILES ${casename}.nc
cdo select,name=$vars *h0* ${casename}.nc

# move to the general case output directory
mv ${casename}.nc ../../

exit 1
