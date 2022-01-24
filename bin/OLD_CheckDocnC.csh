#!/bin/csh
# -------------------------------------------------------------------------
# File name:  CheckDocnC.csh
#
# Purpose:    Codio: Check C++ source against documentation standards.
#
# Invocation: CheckDocnC.csh assignID prog stud docnPts grept
#
# Example:    CheckDocnC.csh add01 ejones 7 PROG4:add01_gradingreport-ejones 
#
# Arguments: 
#            (1) assignID - assignment ID.
#            (2) prog - name of program.
#            (3) stud - Unix login of student.
#            (4) docnPts - max points for documentation output.
#            (5) grept - grading report file.
#
# Returns:   #points awarded.
#
# -------------------------------------------------------------------------

if ($#argv != 5) then
   repeat 2 echo ""
   echo "ERROR: Wrong number of arguments ..."
   echo ""
   echo "USAGE: "
   echo "      CheckDocnC.csh assignID prog stud docnPts gradingreport"
   echo " Ex:  CheckDocnC.csh PROG2 add2 ejones 7 PROG2:add2_gradingreport-ejones" 
   repeat 2 echo ""
   exit 1
endif

set assignID = $1
set prog = $2
set stud = $3
@ docnPts = $4
set g = $5

#-| ---------------------------------------------------------------------------
#-| Initialize variables needed to process multiple test cases.
#-| ---------------------------------------------------------------------------
@ totRight = 0 
@ totChecks = 0

#-| ---------------------------------------------------------------------------
#-| Initialize file names for student's work.
#-| ---------------------------------------------------------------------------
set src = $prog-$stud.cpp 
set res = $prog-docn.res 

#-| ---------------------------------------------------------------------------
#-| Generate default documentation checks.
#-| ---------------------------------------------------------------------------
set dcf = ${prog}:dcf 
rm -f DCF 
#cp ~/bin/$dcf

echo "I File name: $prog.cpp" > DCF
echo "w Author: $stud" >> DCF
echo "w // -----" >> DCF
echo "+ +<//-|>+<.>"  >> DCF
echo "+ +<;>+<//>"  >> DCF
echo "w (c) 2021, $stud" >> DCF
cp DCF DOCNcheck

#-|---------------------------------------------------------------
#-| If a :dcf file is provided, save it, and append DCF to it.
#-| Otherwise, used DCF as the :dcf file, but erase it afterwards.
#-|---------------------------------------------------------------
#CPcopy $dcf
if ( -e $dcf ) then
   cp $dcf saved_$dcf
   rm -f tDCFt
   cat DCF $dcf > tDCFt
   cp tDCFt $dcf
else
   cp DCF $dcf
endif


echo "-------------------------------------------------------------" >> $g
echo "DOCN_check  -- Documentation Correctness (${docnPts})" >> $g
echo "-------------------------------------------------------------" >> $g
echo "DOCN_check  -- Documentation Correctness (${docnPts})" 
echo 

~/workspace/bin/match.crun $dcf $src $res
#match.crun $dcf $src $res

#-|---------------------------------------------------------------
#-| Restore the saved :dcf file, or remove the temp file.
#-|---------------------------------------------------------------
if ( -e saved_$dcf) then
   cp saved_$dcf $dcf
else
   rm -f $dcf
endif

set PTS = ( 0 0 1 0 ) 

if ( -e $res ) then
   set PTS = ( `tail -1 $res`  $PTS )
endif

echo "match.crun DOCUMENTATION => ( $PTS ) "

@ totRight = $PTS[1]
@ totChecks = $PTS[3]

@ roundoff = $totChecks / 2
@ roundoff++
@ pts = $totRight * $docnPts
@ pts = $roundoff + $pts
@ pts = $pts / $totChecks 

@ score = $pts

cat $res >> $g

SHOWRESULTS:
echo "        $totRight / $totChecks CORRECT documentation"
echo "        $totRight / $totChecks CORRECT documentation" >> $g
echo "        " >> $g

if ($score < 0) then
   echo "*** NO DOCUMENTATION POINTS EARNED ... " >> $g
   @ score = 0
endif

#-| Print final score.
echo "            Documentation Points = $score / $docnPts "
echo " " >> $g
echo "Documentation Points = $score / $docnPts " >> $g
echo " " >> $g

exit $score

