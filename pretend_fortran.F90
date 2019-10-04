module jonahjoke
! pretend F90 file to modify

real(r8) :: wbfeffmult(mgncol,nlev) ! wbf efficiency multiplier !zsm

wbfeffmult = 1._r8 !zsm

if (mgrlats(i)*180._r8/3.14159_r8.gt.+66.66667_r8) wbfeffmult(i,k) = 2._r8 

!BUTT
BUTTadump

wbfeffmult(i,k) = 2._r8

value="changed_after"
value="changed_after"
end module jonahjoke
value="changed_after"

