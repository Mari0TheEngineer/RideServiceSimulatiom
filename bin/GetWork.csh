#!/bin/csh
#-----------------------------------------------------------------------------
# File name:  GetWork.csh  basename
# Purpose:    Open file for student work, eg., prog-stud.cpp
# Utilization: GetWork.csh basename
#-------------------------------------------------------------------------------
if ($#argv < 1) then
   echo "USAGE:  GetWork.csh  basename"
   repeat 2 echo ""
   exit 1
endif

set base = $1
set roster = ${base}_ROSTER

if ( ! -e $roster)  then
   echo "teacherK123" > $roster 
endif

repeat 2 echo ""
echo "Loading student source files for $base.cpp ..."
repeat 2 echo ""

echo -n "Enter login (STOP to terminate): "
set stud = $<
while ( $stud != STOP )
   
   vi $base-$stud.cpp
   echo $stud >> $roster 

   echo -n "Enter login (STOP to terminate): "
   set stud = $<
end

