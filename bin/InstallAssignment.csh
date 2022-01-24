#!/bin/csh
#---------------------------------------------------------------
# File name:  InstallAssignment.csh
# Purpose:    Install new assignment from PROGx.tar file.
# Invocation: InstallAssignment.csh ASSIGNID
# Example:    InstallAssignment.csh PROG1
# Date:       2021 August 29
# Author:     Dr. Jones
#----------------------------------------------------------------
if ($#argv != 4) then
   repeat 2 echo ""
   echo "USAGE:   InstallAssignment.csh term COURSE ASSIGNID progname"
   echo ""
   echo "Example: InstallAssignment.csh 2218 COP2233 PROG2 memo"
   repeat 2 echo ""
   exit 1
endif

cd ~/workspace/

set term = $1
set COURSE = $2
set ID = $3
set family = $4
set tarF = ${term}${COURSE}_${ID}${family}.tar

if ( ! -e $tarF ) then
   repeat 2 echo " "
   echo "FATAL ERROR: $tarF not found. "
   repeat 2 echo " "
   exit 1
endif

#------------------------------------------------
#-| Perform install from staging area.
#------------------------------------------------
mkdir STAGING
cp $tarF STAGING/
cd STAGING/
mkdir WORKSPACE BIN GRADING 
tar xvf $tarF.tar
mv WORKSPACE.tar WORKSPACE
mv BIN.tar BIN
mv GRADING.tar GRADING

#------------------------------------------------
#-| Extract and copy bin files.
#------------------------------------------------
cd BIN
tar xvf BIN.tar
rm *.tar
chmod 755 *
cp * ~/workspace/bin/
cd ..

#------------------------------------------------
#-| Extract and copy workspace files.
#------------------------------------------------
cd WORKSPACE 
tar xvf WORKSPACE.tar
rm *.tar
chmod 555 *.csh *crun
chmod 666 *.cpp 
cp * ~/workspace/
cd ..

#------------------------------------------------
#-| Extract and copy grading files.
#------------------------------------------------
cd GRADING
tar xvf GRADING.tar
rm *.tar
chmod 444 *expf* *tcf* *dcf
chmod 555 *.csh *.crun
cp * ~/workspace/grading/


#------------------------------------------------
#-| Show teacher the grading, bin, and workspace directories.
#------------------------------------------------r
cd ~/workspace/
repeat 2 echo "BIN directory: "
ls -lt bin/*grade*
repeat 2 echo "GRADING directory: "
ls -lt grading/
repeat 2 echo "WORKSPACE directory: "
ls -lt 

#------------------------------------------------
#-| Remind teacher to delete STAGING directory when done.
#------------------------------------------------r
repeat 2 echo " "
echo -n "Delete staging area (Y/N): "
set go = ( $< N)
if ( $go[1] == Y | $go[1] == y) then
   rm -f $1.tar 
   rm -fr STAGING/
else
   repeat 2 echo " "
   echo "DELETE STAGING directory when done."
   echo " rm -rf STAGING/"
   echo "DELETE $1.tar file when done."
   echo " rm -f $1.tar"
endif
repeat 2 echo " "


