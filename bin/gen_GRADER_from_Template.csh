#!/bin/csh
#-----------------------------------------------------------
# File name:  gen_GRADER_from_template.csh
# Purpose:    Edit grader_template to produce PROGx grader.
# Output:     grade<ASSIGN>_profile
# Output:     grade<ASSIGN>_<basename.cpp>.csh
# Revision:   8 Nov 2020
#---------------------------------------------------------------

#-|---------------------------------------------------------------
#-| Read assignment parameters.
#-|---------------------------------------------------------------
echo -n "Enter ASSIGNID: " 
set assign = $<

echo -n "Enter current year: " 
set curyear  = $<

echo -n "Enter base file name (no extension): " 
set basename = $<

set curdir = `pwd`


#-|---------------------------------------------------------------
#-| Select grader template.
#-|---------------------------------------------------------------
set myGrader = "gradeMy_${basename}.crun"
set myGraderSRC = "gradeMy_${basename}.cpp"

echo "---------------------------------"
echo " 1) My_grader_template_LOCALbin" 
echo " 2) teacher_grader_template_LOCALbin" 
echo " 3) My_grader_template_GLOBALbin/)" 
echo " 4) teacher_grader_template_GLOBALbin" 
echo "---------------------------------"
echo -n "Enter choice: "
set c = $<

switch ( $c )
  case 1: 
         set binDIR = ~/workspace/bin
         set gradingDIR = ~/workspace/grading
         cd $binDIR

         rm -f $myGraderSRC
         sed "s/xbasenamex/$basename/" gradeMy_xbasenamex_template_LOCALbin.cpp \
              >  $myGraderSRC
         g++ $myGraderSRC -o $myGrader
         cp $myGrader ~/workspace/

         set tF = My_grader_template_LOCALbin.txt
         set graderF = gradeMy_$basename.csh
         breaksw

  case 2: 
         set binDIR = ~/workspace/bin
         set gradingDIR = ~/workspace/grading
         cd $binDIR
              
         set tF = teacher_grader_template_LOCALbin.txt
         set graderF = grade${assign}_$basename.csh
         breaksw

  case 3: 
         set gradingDIR = ~/grading
         set binDIR = ~/bin
         cd $binDIR

         rm -f $myGraderSRC
         sed "s/xbasenamex/$basename/" gradeMy_xbasenamex_template_GLOBALbin.cpp \
              >  $myGraderSRC
         g++ $myGraderSRC -o $myGrader
         cp $myGrader ~/workspace/

         set tF = My_grader_template_GLOBALbin.txt
         set graderF = gradeMy_$basename.csh
         breaksw
  case 4: 
         set binDIR = ~/bin
         set gradingDIR = ~/grading
         cd $binDIR

         set tF = teacher_grader_template_GLOBALbin.txt
         set graderF = grade${assign}_$basename.csh
         breaksw
endsw

#-|-------------------------------------------------------------
#-| Return to invocation directory and copy template there..
#-|-------------------------------------------------------------
cd $curdir
cp $binDIR/$tF .

#-|---------------------------------------------------------------
#-| Build grader profile summarizing grading parameters.
#-|---------------------------------------------------------------
set profileF = grade${assign}_${basename}_PROFILE
rm -f $profileF
echo $profileF > $profileF
echo curYEAR = $curyear >> $profileF
echo ASSIGNID = $assign >> $profileF
echo basename = $basename >> $profileF


#-|---------------------------------------------------------------
#-| Generate grader via series of edits inserting parameters.
#-|---------------------------------------------------------------
rm -f OUT1 OUT2
sed "s/xASSIGNx/$assign/g" $tF > OUT1 
sed "s/xcurYEARx/$curyear/g" OUT1 > OUT2
rm -f OUT1
sed "s/xbasenamex/$basename/g" OUT2 > OUT1
rm -f OUT2
echo -n "Enter family name (e.g., add3): " 
set familyname = $<
sed "s/xfamilynamex/$familyname/g" OUT1 > OUT2
echo familyname = $familyname >> $profileF
rm -f OUT1

echo -n "Enter INPUT SOURCES (e.g. cin mydata.txt) : " 
set SOURCES = ( $< )
set TEMP = ( )
foreach s ( $SOURCES )
   set t = `echo $s | sed 's/^/in:/'`
	set TEMP = ( $TEMP $t )
end
set SOURCES = ( $TEMP )
sed "s/xSOURCESx/$SOURCES/g" OUT2 > OUT1
echo SOURCES = $SOURCES >> $profileF

rm -f OUT2
echo -n "Enter OUTPUT SINKS (e.g. cout my.rpt) : " 
set SINKS = (  $< )
set TEMP = ( )
foreach s ( $SINKS )
   set t = `echo $s | sed 's/^/out:/'`
	set TEMP = ( $TEMP $t )
end
set SINKS = ( $TEMP )
sed "s/xSINKSx/$SINKS/g" OUT1 > OUT2
echo SINKS = $SINKS >> $profileF

rm -f OUT1
echo -n "Enter ADDITIONAL COMPILATION FILES (e.g., useme.o  stuff.cpp ) : " 
set COMPILEF = ( $< )
sed "s/xcompileFx/$COMPILEF/g" OUT2 > OUT1
echo CompileF = $COMPILEF >> $profileF

rm -f OUT2
echo -n "Enter INCLUDE FILES (e.g. mystuff.h yostuff.h) : " 
set INCLUDEF = ( $< )
sed "s/xincludeFx/$INCLUDEF/g" OUT1 > OUT2
echo includeF = $INCLUDEF >> $profileF


rm -f OUT1
echo -n "Enter List of TEST CASES (e.g., 1 2 3 4): " 
set TESTCASES = (  $<  )
sed "s/xTESTCASESx/$TESTCASES/g" OUT2 > OUT1
echo testCases = $TESTCASES >> $profileF

rm -f OUT2
echo -n "Enter MAX SCORE: " 
set maxSCORE =  $< 
sed "s/xmaxSCOREx/$maxSCORE/g"  OUT1 > OUT2
echo maxSCORE = $maxSCORE >> $profileF

rm -f OUT1
echo -n "Enter SUBMISSION points: " 
set submitPTS =  $< 
sed "s/xsubmitPTSx/$submitPTS/g"  OUT2 > OUT1
echo submitPTS = $submitPTS >> $profileF

rm -f OUT2
echo -n "Enter COMPILATION points: " 
set compilePTS = $< 
sed "s/xcompilePTSx/$compilePTS/g" OUT1 > OUT2
echo compilePTS = $compilePTS >> $profileF

rm -f OUT1
echo -n "Enter DOCUMENTATION points: " 
set docnPTS  =  $< 
sed "s/xdocnPTSx/$docnPTS/g" OUT2 > OUT1
echo docnPTS = $docnPTS >> $profileF

rm -f OUT2
echo -n "Enter EXECUTION points: " 
set executionPTS  =  $< 
sed "s/xexecutionPTSx/$executionPTS/g" OUT1 > OUT2
echo executionPTS = $executionPTS >> $profileF

cp OUT2 $graderF 
chmod 755 $graderF 
cp $graderF $binDIR/
