#!/bin/csh
#---------------------------------------------------------------
# File name: DoAll.csh 
# Purpose:   Repeat command, replacing argment at position p
#            with a studlogin.
# Invocation: DoAll.csh position command
# Example:    DoAll.csh 2 grade anystud add.cpp 
#               Repeats command:  grade studK add.cpp
#----------------------------------------------------------------.

repeat 2 echo " "

if ($#argv < 3) then
   echo "USAGE: DoAll.csh position command"
   echo "EX: DoAll.csh 2 grade anystud add.cpp"
   repeat 2 echo " "
   exit 1
endif

if (-e ROSTER) then
   set ALL = (` cat ROSTER `)
else   
   echo "ROSTER not found ... retry"
   repeat 2 echo " "
   exit 2
endif

set CMD = ( $argv )
echo "ARGS = $CMD"
@ position = $argv[1]
shift CMD
echo "CMD = $CMD"

#-| Separate command into BEFORE/AFTER insertion point.
set BEFORE = ( )
set AFTER  = ( )
@ p = 1
while ( $p < $position)
   set BEFORE = ( $BEFORE $CMD[$p] )
   @ p++
end
echo "BEFORE = $BEFORE"
@ p++
while ( $p <= $#CMD )
   set AFTER = ( $AFTER  $CMD[$p] )
   @ p++
end
echo "AFTER = $AFTER"

#----------------------------------------------------------------
# Repeat command for each studlogin.
#----------------------------------------------------------------
foreach s ( $ALL )
   set cmd = ( $BEFORE $s $AFTER )
   echo "Next CMD = | $cmd |"
   $cmd
end

