#!/bin/csh
#--------------------------------------------------------------------------------
# Package student test programs into tar file.
# Invocation: packProgs.csh studlogin TESTID srcPrefix 
# ------------------------------------------------------------------------------
if ($#argv < 3) then
   repeat 2 echo ""
   echo "USAGE:   packProgs.csh studlogin TESTID srcPrefix" 
   echo "EXAMPLE: packProgs.csh teacherK123 TEST1 test1prog"
   repeat 2 echo ""
   exit 1
endif

set stud = $1
set TEST = $2
set base = $3

set tarF = ${stud}_${TEST}prog.tar

bin/compileall.csh

set RUN = ( $base*.crun )
echo "RUN = ( $RUN )"
set COMPILED = ( `echo $RUN | sed 's/\.crun/.cpp/g'` )
echo "COMPILED = ( $COMPILED )"

set TAR = ( )
foreach n ( $RUN $COMPILED)
   cp $n ${stud}_$n
   set TAR = ( $TAR ${stud}_$n )
end

echo "TAR = ( $TAR ) "


tar cvf $tarF $TAR

echo "************** TERMINATING packProg.csh $stud $TEST $base *********"
exit
exit
 

