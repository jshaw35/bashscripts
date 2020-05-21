#! /bin/bash -x

cd /work/bm0960/b380761/ATM/high/

#extracting variables from runs
for run in 03 04 05 06 07 08 09 10 11; do
for year in 1536 1537 1538 1539 1540 1541 1542 1543 1544 1545 1546 1547 1548 1549 1550; do
for var in var130 var131 var151 var156; do

cdo -f nc copy run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_${year}_after.grb run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_${year}_after.nc
cdo selvar,${var} run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_${year}_after.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_${year}_after_${var}.nc

done
done
done

#concatenating years
for run in 03 04 05 06 07 08 09 10 11; do
for var in var130 var131 var151 var156; do 

cdo cat run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1536_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1537_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1538_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1539_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1540_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1541_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1542_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1543_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1544_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1545_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1546_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1547_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1548_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1549_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1550_after_${var}.nc run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1536_1550_${var}_cat.nc

#mv run${run}/ue536a${run}_r1i1p1-LR_echam6_echam_1536_1550_${var}_cat.nc exp/${var}
 
done
done
