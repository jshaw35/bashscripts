#/bin/bash!

#######################################################
###						    ###
###	Inger Helene Hafsahl Karset		    ###
###	February 10, 2020		  	    ###
### 						    ###
#######################################################

#++ Start of input to modify
#------------------------------------------------------------------

cmip6path="/projects/NS9252K/CMIP6"

outpath="/projects/NS9600K/ihkarset/CMIP6/MEAN/cloudoutpath"

varlist=("tas" "rsut" "rlut" "rsdt")		# Variable name. tas = global mean near surface temperature (GMST). Expand ex: ("tas" "clt") 
comrad=true				# combine radiation variables into one for energy imbalance at toa (restom=rsdt-rsut-rlut) 
mergetasrestom=true
table="Amon" 		 		# A: atmospheric variables, mon: monthly mean
member="r1i1p1f2" 	 		# realization, (just one set of initial conditions). usually r1i1p1f1. f2 for UKESM
simname="abrupt-4xCO2"	 		# name of CMIP-simulation. EX: abrupt-4xCO2, historical, 
#modnames=("CNRM-CM6-1" "CNRM-CM6-1-HR" "CNRM-ESM2-1" "UKESM1-0-LL")  
modnames=("UKESM1-0-LL") #"EC-Earth3-Veg" "NorESM2-LM" "NorESM2-MM") #("UKESM1-0-LL") #("NorESM2-LM" "NorESM2-MM" "EC-Earth3-Veg") # "UKESM1-0-LL")

#-------------------------------------------------------------------
#-- End of input to modify. Do not modify code below
 
for modname in ${modnames[*]}; do
	for var in ${varlist[*]}; do
		echo "Processing this variable: ${var} from model: ${modname}"

                echo "1) Combine all these files into one merged file:"
                allcombinedfile="${outpath}/${var}_${table}_${modname}_${simname}_${member}_ALLCOMBINEDFILE.nc"
                echo -e "name and path of merged file: ${allcombinedfile} \n"
                ncrcat ${cmip6path}/${simname}/${modname}/${member}/${var}_${table}_${modname}_${simname}_${member}*.nc ${allcombinedfile}

                echo "2) Extract the year 141-150 (120 months):"
                combinedfile="${outpath}/${var}_${table}_${modname}_${simname}_${member}_COMBINEDFILE.nc"
                ncks -F -d time,1681,1800 ${allcombinedfile} ${combinedfile}
                wait
                rm ${allcombinedfile}

                echo "2) Create monthly files (12 in total) with mean over the whole time period:"
                months=("JAN" "FEB" "MAR" "APR" "MAY" "JUN" "JUL" "AUG" "SEP" "OCT" "NOV" "DEC")
                for (( i=1; i<${#months[@]}+1; i++ )); do
                        monnum=$( printf '%02d' "$i" )
                        echo ${monnum} ${months[$i-1]}
                        monfile=${outpath}/${var}_${table}_${modname}_${simname}_${member}_${monnum}${months[$i-1]}MONCLIM.nc
                        ncra -F -d time,$i,,12 ${combinedfile} ${monfile}
                done
                wait
                rm ${combinedfile}

                echo "3) Combine monthly climatology into one file (with 12 months):"
                oneyrclim="${outpath}/${var}_${table}_${modname}_${simname}_${member}_ONEYRCLIM.nc"
                ncrcat ${outpath}/${var}_${table}_${modname}_${simname}_${member}_*MONCLIM.nc ${oneyrclim}
                wait
                rm ${outpath}/${var}_${table}_${modname}_${simname}_${member}_*MONCLIM.nc

                echo "4) Create annual mean file, weighted by number of days in each month"
                annmeanfile="${outpath}/${var}_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                ## -O flag to nco means that we overwrite the existing file, without the need to answer prompts.
                ncap2 -O -s "timewgt[time]={31,28,31,30,31,30,31,31,30,31,30,31}" ${oneyrclim} ${oneyrclim}
                wait
                ncwa -O -w timewgt -a time ${oneyrclim} ${annmeanfile}
                wait
                rm ${oneyrclim}
	done

        if (${combrad}); then
                echo "POST PROCESSING: Combine radiation fields into TOA energy imbalance (restom)"
                rsdtfile="${outpath}/rsdt_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                rsutfile="${outpath}/rsut_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                rlutfile="${outpath}/rlut_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                restomfile="${outpath}/restom_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                ncks -A ${rsdtfile} ${rsutfile}
                wait
                ncks -A ${rsutfile} ${rlutfile}
                wait
                ncap2 -O -s "restom=rsdt-rsut-rlut" ${rlutfile} ${restomfile}
                rm ${rsdtfile}
                rm ${rsutfile}
                rm ${rlutfile}
        fi

        if (${mergetasrestom}); then
                echo "POST PROCESSING: Combine tas and restom into one file pr model, named:"
                tasfile="${outpath}/tas_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                restomfile="${outpath}/restom_${table}_${modname}_${simname}_${member}_ANNMEAN.nc"
                tasrestomfile="${outpath}/tasrestom_${table}_${modname}_${simname}_ANNMEAN.nc"
                ncks -A ${tasfile} ${restomfile}
                wait
                mv ${restomfile} ${tasrestomfile}
                rm ${tasfile}
        fi


done

