#!/bin/csh
#----------------------------------------------------------------------------
# NEW NEW NEW: Modified to run in CODIO!!  No repository.
# File name: genTestCases_Codio.csh
#
# Purpose:   Generate and format test cases to be used. Test data are stored
#            in *:tcf# files, with the correponding expected results stored
#            in *:expf# files. Generated test cases are written to the
#            ~/workspace/grading directory.
#              
#
# Details:   NO ENCODING.

#            -----------------------------------------------------------------
# NOTE:      If program creates an output file, the console output is ignored.
#            -----------------------------------------------------------------
#            
# Invocation: genTestCases.csh assignID progname key.run firstcase# lastcase# 
#              
#----------------------------------------------------------------------------
set CURDIR = ( `pwd | sed 's#/# #g'` )
set curdir = $CURDIR[$#CURDIR]
if ( $#CURDIR > 0) then
   if ($curdir != grading) then
      echo "MUST BE IN grading/ directory. Retry."
      exit 1
   endif
endif

if ($#argv < 5) then
        echo "***** USAGE ERROR: Wrong number of arguments*****"
        echo "** "
        echo "** USAGE: genTestCases assignID progname key.run firstcase# lastcase# "
        echo "** "
        echo "** Example: genTestCases PROG4 add key-add.run 1 4"
        echo "**          genTestCases PROG4 add key-add.run 1 4 "
        echo "** "
        echo "**-------------------------------------------------"
        echo
        exit 2
endif

set assignid = $1
set progname = $2
set runkey = $3
@ firstcase = $4
@ lastcase = $5
@ numcases = $lastcase - $firstcase
@ numcases++

set cinInput = 0
set coutOutput = 0
set stdIn = ( )
set inFiles = ( )
set outFiles = ( )
set stdOut = ( )
set progPROFILE = ( )
#set profileF = ${assignid}:${progname}_genTestcasesPROFILE 

#-| ------------------------------------------------------------
#-| IF program requires input/output files, read names.
#-| ------------------------------------------------------------
echo 
echo -n "Does program read keyboard input (cin)? (Y/N) [Y]: "; set go = $<
if (x$go == x || $go == y || $go == Y) then
   set cinInput = 1
   set stdIn = ( cin )
endif
echo -n "Does program display console output (cout)? (Y/N) [Y]: "; set go = $<
if (x$go == x || $go == y || $go == Y) then
   set coutOutput = 1
   set stdOut = ( cout )
endif
set progPROFILE = ( $progPROFILE $cinInput $coutOutput )

set inFiles = ( )
echo -n "Enter number of INPUT FILES [0]: "; set go = $<
if (x$go == x ) then
   set progPROFILE = ( $progPROFILE 0 )
else
   set numInFiles = $go
   @ k = 1
   while ($k <= $numInFiles)
        AGAINin:
      echo -n "Enter name of input file #${k}: "; set fn = $<
      if (x$fn == x) goto AGAINin 
      set inFiles = ($inFiles $fn)
      @ k++
   end
   set progPROFILE = ( $progPROFILE $numInFiles )
endif


set outFiles = ( )
echo -n "Enter number of OUTPUT FILES [0]: "; set go = $<
if (x$go == x ) then
   set progPROFILE = ( $progPROFILE 0 )
else
   set numOutFiles = $go
   @ k = 1
   while ($k <= $numOutFiles)
      AGAINout:
      echo -n "Enter name of output file #${k}: "; set fn = $<
      if (x$fn == x) goto AGAINout
      set outFiles = ($outFiles $fn)
      @ k++
   end
   set progPROFILE = ( $progPROFILE $numOutFiles )
endif


echo -n "ENTER name of your preferred editor [default vi]: "
set edit = $<
if (x$edit == x) set edit = vi


#-| ----------------------------------------------------------
#-| cout STANDARD OUTPUT filtering.
#-|   a) View filter in directory. if accepted copy, decode, use.
#-|   x) View filter in repository. if accepted copy, decode, use.
#-| ----------------------------------------------------------
set filterF = ${progname}:resultFilter
set filter = 1
                   #===================================================
set filter = 0     # FILTERING NOT IMPLEMENTED>
goto NOFILTERING   #===================================================

echo ""
echo -n "Filter standard output (cout)? [N] ";
set go = $<
if (x$go == x || x$go == xn || x$go == xN) then
   set filter = 0
   set filterSRC = NONE
   set resultFilter = ( )
   goto NOFILTERING
endif


if (-e $filterF) then
   echo "Result FILTER ================"
   cat $filterF
   echo " "
   echo -n "Use existing results filter? "
   set go = $<
   if (x$go == xy || x$go == xY) then
      set filter = 1
      set resultFilter = (`cat $filterF`)
      goto USE_EXISTING_FILTER
   endif
endif

set resultFilter = ( '|' )
ADDFILTER:
   set filter = 1
   set filterSRC = NEW
   echo "RESULTS FILTER = ( $resultFilter )"
   echo -n "Enter next quoted filter delimiter (e.g., '|' ':' 'xxx' ): "
   set go = $<
   set resultFilter = ( $resultFilter $go )
if (x$go != x) goto ADDFILTER


if ($filterSRC == NEW) then
   rm -f rfTEMPrf $filterF
   echo $resultFilter > rfTEMPrf
   echo "   " >> rfTEMPrf
   ~cop3014cjoe/bin/ENCODE.csh rfTEMPrf $filterF
   ${reposPREFIX}Pclean  $filterF
   ${reposPREFIX}Pcheckin  $filterF
endif

USE_EXISTING_FILTER:
NOFILTERING:


repeat 3 echo ""
echo "-------------------------------------------------------"
echo "Create :dcf file containing program-specific documentation"
echo "to be checked when grading a program."
echo ""
echo "  (0) // as default."
echo "  (1) algorithm steps given in assignment;"
echo "  (2) specific statements that must be used;"
echo "  (3) any other requires source code elements."
echo "-------------------------------------------------------"
echo " "

set dcf = no_DCF #===================================================
goto NO_DCF      # FILTERING NOT IMPLEMENTED>
                 #===================================================


set dcf = ${progname}:dcf
if (-e $dcf) then
   echo "Documentation Check File (DCF)================"
   cat $dcf
   echo " "
   echo -n "Use existing DCF file? "

   set go = $<
   set G = ( $go Y)
   set go = $G[1]
   if (x$go == xy || x$go == xY) then
      set USEdcf = 1
      goto USE_EXISTING_DCF
   else
      set USEdcf = 0
   endif

endif

echo -n "Edit documentation check (dcf) file: [n] "
set go = $<
set G = ( $go N)
set go = $G[1]
if (x$go == xn || x$go == xN) then
   goto USE_EXISTING_DCF
else
   $edit $dcf
endif

echo -n "Hit ENTER to continue: "

USE_EXISTING_DCF:
NO_DCF:

echo " "


#rm -f ${progname}:tcf* ${progname}:expf*

#-| ------------------------------------------------------------
#-| Generate documentation tag assignment ID. 
#-| ------------------------------------------------------------
set tag = "#++${progname}:$assignid++"


#-| ----------------------------------------------------------------------------
#-| MAKE list of input sources and output sinks (destinations). 
#-| ----------------------------------------------------------------------------
set SOURCES = ( $stdIn $inFiles )
set SINKS = ($stdOut $outFiles )


#-| ----------------------------------------------------------------------------
#-| Generate each test case: obtain input from each source, tag and append to
#-|   tcf file. Execute key program and capture each sink, tag and append
#-|   to expf file.
#-| ----------------------------------------------------------------------------
@ tcnum = $firstcase
while ($tcnum <= $lastcase)

  REPEAT:  ## ============================= ##

   set expf = ${progname}:expf$tcnum
   set tcf = ${progname}:tcf$tcnum
   rm -f $tcf; echo -n "" > $tcf

   echo "SOURCES ... $SOURCES"
   #-| ----------------------------------------------------
   #-| Establish input sources: cin, input files.
   #-| ----------------------------------------------------
   foreach src ($SOURCES)
      echo "Creating input data for test case $tcnum ... [up to ${lastcase}] "
      #echo -n "Hit ENTER to create data for ${src}: "
      #set go = $<
      $edit $src 

      set srcTag = "${src}::"
      sed "s/^/$srcTag/" $src  >> $tcf
 
      echo "CUMULATIVE TCF =================== "
      more $tcf
   end
   #echo -n "Hit ENTER to edit $tcf cumulative test data: "
   #set go = $<
   $edit $tcf

   #-| ----------------------------------------------------
   #-| Clear all SINKS. 
   #-| ----------------------------------------------------
   foreach sink ($SINKS)
      rm -f $sink
   end

   #-| ----------------------------------------------------
   #-| Run any pre-execution Unix commands to set up test case.
   #-| ----------------------------------------------------
   echo " "
   echo -n "Using PRE-EXECUTION test case set-up? [N] "; set go = $<
   if ($go == Y || $go == y) then
      rm -f CMD
      $edit CMD
      sed 's/^/cmd::/' CMD >> $tcf

      rm -f SetUp.csh
      echo '#\!/bin/csh ' > SetUp.csh
      cat CMD >> SetUp.csh

      $edit SetUp.csh
      echo "PRE-EXECUTION SET-UP command: -----------------"
      cat SetUp.csh
      echo -n "ENTER to continue: "; set go = $<
      csh SetUp.csh
      echo -n "ENTER to continue: "; set go = $<
   endif

   TESTRUN:

   #-| ---------------------------------------------------------
   #-| Run program using input sources. Capture console output.
   #-| ----------------------------------------------------------
   if (-e cin) then
      echo -n ""
   else
      echo " " > cin
   endif
   rm -f cout
   ./$runkey < cin > cout
    
   echo "Console: ============"
   cat cout
   echo "Console: ============"

   if ($filter == 1) then

      echo "foreach d ( $resultFilter )"
      foreach d ( $resultFilter )
         rm -f coutTEMP
         echo "grep -v $d cout > coutTEMP "
         grep -v $d cout > coutTEMP
         cp coutTEMP cout
      end 
    
      echo "FILTERED Console: ============"
      cat cout
      echo "============ FILTERED Console"

   endif

   #echo -n "ENTER to continue: "; set go = $<


   CAPTURE_OUTPUT:

   #-| ---------------------------------------------------------
   #-| Capture and TAG all output sinks.
   #-| ----------------------------------------------------------
   rm -f $expf; echo -n "" > $expf
   if (! $coutOutput)  set SINKS = ( cout $SINKS )
   foreach outF ( $SINKS )

            #********** NEW 6/28/16
      repeat 2 echo " "
      echo -n "Edit $outF (Y/N) [Y]: "; set go = $<
      if (x$go == x || x$go == xy || x$go == xY) then
         rm -f _OUTF_
         sed 's/^/w#1#/' $outF > _OUTF_
         cp _OUTF_ $outF
         $edit $outF
      endif
            #********** NEW 6/28/16
 
      rm -f taggedSINK
      sed "s/^/::/" $outF | sed "s/^/$outF/" > taggedSINK 
   
      echo "====  tagged SINK $outF ============== " 
      cat taggedSINK
      echo "====  tagged SINK $outF ============== " 

      cat taggedSINK >> $expf

      echo "====  CUMULATIVE EXPF ============== " 
      cat $expf
      echo "====  CUMULATIVE EXPF ============== " 

      echo -n "ENTER to continue: "; set go = $<
   end


   echo -n "Enter 'R' to REPEAT THIS STEP - TestCase $tcnum : "
   set go = $<
   if ($go == R || $go == r) goto REPEAT


   goto NEXT_TC

   NEXT_TC:

   @ tcnum++
end #while

exit
