#!/bin/csh
#---------------------------------------------------------------
# File name:  PackAssignment.csh
# Purpose:    Package components of new assignment so they can
#             be unpacked within grading project.
# Invocation: PackAssignment.csh term COURSE ASSIGNID progname
# Example:    PackAssignment.csh 2218 COP3014C PROG1 memo
# Date:       2021 August 29
# Author:     Dr. Jones
#----------------------------------------------------------------
if ($#argv != 4) then
   repeat 2 echo ""
   echo "USAGE:   PackAssignment.csh term COURSE ASSIGNID progname"
   echo ""
   echo "Example: PackAssignment.csh 2218 COP3330 PROG2 memo"
   repeat 2 echo ""
   exit 1
endif

set term = $1
set COURSE = $2
set ID = $3
set family = $4
set basename = ${term}${COURSE}_${ID}$family
set tarF = $basename.tar

#------------------------------------------------
#-| Create packing directory. 
#------------------------------------------------
cd ~
if (-e PACKING) then
  rm -f PACKING/* 
else
   mkdir PACKING 
endif

#------------------------------------------------
#-| Gather and tar grader files from bin.
#------------------------------------------------
cd ~/workspace/bin/ 
tar cvf ~/PACKING/BIN.tar InstallAssignment.csh \
    gradeMy_$family.* grade${ID}_$family.csh 

#------------------------------------------------
#-| Gather files from grading/ directory.
#------------------------------------------------
cd ~/workspace/grading/
tar cvf ~/PACKING/GRADING.tar ${family}:* 


#------------------------------------------------
#-| Gather files from workspace/ directory.
#------------------------------------------------
cd ~/workspace/
if (-e starter_$family.cpp) then
   tar cvf ~/PACKING/WORKSPACE.tar _${ID}_${family}_Instructions.txt  \
        key-${family}.crun starter_${family}.cpp gradeMy_${family}.crun
else
   tar cvf ~/PACKING/WORKSPACE.tar _${ID}_${family}_Instructions.txt  \
        key-${family}.crun gradeMy_${family}.crun

endif

#------------------------------------------------
#-| Produce overall assignment tar file.
#------------------------------------------------
cd ~/PACKING/
tar cvf $tarF BIN.tar GRADING.tar WORKSPACE.tar 

echo "PACKING DIRECTORY"
ls 

echo "================ DONE"
exit

