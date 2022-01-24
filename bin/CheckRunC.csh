#!/bin/csh
# -------------------------------------------------------------------------
# File name:  CheckRunC.csh
# Version:    13 June 2015. Implemented pts per test case [optional].
#
# Purpose:    CODIO: Run executable against each test case and match against
#             expected results.
#
# Invocation: CheckRunC.csh prog stud execPts grept [taggedFileList]
#
# Example:    CheckRunC.csh add01 ejones 7 MIPS1_gradingreport-ejones
#             CheckRunC.csh add01 ejones 7 GR in:cin in:mydata.dat out:cout out:myrept.out
#
# Arguments:
#            (1) prog - name of program.
#            (2) stud - Unix login of student.
#            (3) execPts - max points for execution output.
#            (4) grept - grading report file.
#            [5] Data source/sink file list.
#            [6] Sleep interval -- time to check INFINITE looping.
#
# Returns:   #points awarded.
#
#
# REVISIONS:  2014-May-27: Adopted COP3330 tagging of raw outputs.
#             Pending: Filtering of output to reduce grading report file size.
#                      Detection of infinite loops by file size growth.
# -------------------------------------------------------------------------

goto CHECKARGS
echo "CHECKRUN invocation: $argv[1-]"
#echo -n "Hit ENTER to continue: "; set go = $<
#set go = $<

CHECKARGS:

if ($#argv < 4) then
   repeat 2 echo ""
   echo "ERROR: Wrong number of arguments ..."
   echo ""
   echo "USAGE: "
   echo "      CheckRunC.csh prog stud execPts gradingreport [DEBUG] [taggedFileList] [SLEEP:seconds]"
   echo " Ex:  CheckRunC.csh add2 ejones 7 HW3:add2_gradingreport-ejones in:cin in:infile out:cout"
   echo " Ex:  CheckRunC.csh add2 ejones 7 GR in:cin DEBUG in:infile out:cout"
   echo " Ex:  CheckRunC.csh add2 ejones 7 GR SLEEP:3 "
   repeat 2 echo ""
   exit 1
endif

set prog = $1
set stud = $2
@ execPts = $3
set g = $4
@ sleepTime = 1

@ totRight = 0
@ totChecks = 0 

@ totOutputBytes = 0
@ right = 0
@ totalpts = 1

#----------------------------------------------------------------------------
#- NEW (from OOP 2015jun): output filtering, e.g., repeated display of menu.
#----------------------------------------------------------------------------
@ filtering = 0
set filter = `echo $prog | sed 's/^x//'`
set filter = ${filter}:resultFilter
if (-e $filter) then
   @ filtering = 1
endif

if ($filtering > 0) then
   echo "FILTERING via file $filter"
else
   echo "NO FILTERING"
endif


#====NEW
#-| ----------------------------------------------------------------
#-| Write empty file for test data, to be inserted into grading report.
#-| ----------------------------------------------------------------
set testDataF = MISSINGtestdata
rm -f MISSINGtestdata
echo " " > MISSINGtestdata

 
set DEBUG = 0

#-| ----------------------------------------------------------------------
#-| Extract names of input data sources and output data sinks.
#-| ----------------------------------------------------------------------
set SOURCES = ( )
set SINKS = ( )

@ k = 5
while ($k <= $#argv)
   set SLEEP = `echo $argv[$k] | grep -c 'SLEEP:'`
   if ($SLEEP > 0) set sleepTime = `echo $argv[$k] | sed 's/SLEEP://'`
   set IN = `echo $argv[$k] | grep -c 'in:'`
   if ($IN) set SOURCES = ( $SOURCES `echo $argv[$k] | sed 's/in://'`)
   set OUT = `echo $argv[$k] | grep -c 'out:'`
   if ($OUT) set SINKS = ( $SINKS `echo $argv[$k] | sed 's/out://'`)
   if ($IN == 0 && $OUT == 0) then
      if ($argv[$k] == DEBUG) set DEBUG = 1
   endif 
   @ k++
end


#-| ---------------------------------------------------------------------------
#-| Initialize variables needed to process multiple test cases.
#-| ---------------------------------------------------------------------------
@ right = 0 
@ totRight = 0 
@ totChecks = 0
@ totExDed = 0


     # -----------------------------------------------------
P4:  #-| Check: EXECUTION output correctness and formatting.
     # -----------------------------------------------------
     
echo "-------------------------------------------------------------" >> $g
echo "EXEC_check  -- Execution Correctness (${execPts})" >> $g
echo "-------------------------------------------------------------" >> $g
echo "EXEC_check  -- Execution Correctness (${execPts})" 
echo 

set PROG = `echo $prog | sed 's/^x//'`
set TCFlist = (` ls -1 ${PROG}:tcf*` )
set EXPFlist = (` ls -1 ${PROG}:expf*` )
echo "TCFlist $TCFlist   ... EXPFlist $EXPFlist"
#echo -n "ENTER to continue: "; set go = $<

@ testcasenum = 1
REPEAT: # ====================================================== #
while ( $testcasenum <= $#TCFlist )

   set tcf = $TCFlist[$testcasenum]
   set expf = $EXPFlist[$testcasenum]

   #-| ----------------------------------------------------
   #-| Populate input sources from tagged $testcase file. 
   #-| ----------------------------------------------------
   foreach s ( $SOURCES )
      rm -f $s
      set srctag = "${s}::"
      grep "$srctag" $tcf | sed "s/$srctag//"  > $s

      echo "CIN: `cat $s`"
   end
  
   #-| ----------------------------------------------------
   #-| Clear all output sinks and _resF filesprior to execution.
   #-| ----------------------------------------------------
   foreach s ( $SINKS )
      rm -f $s
   end
   rm -f *_resF        #=== TEMP  11/16/20  kill results from previous test case 
   
   #******** NEW ******************
   #-| ----------------------------------------------------
   #-| Run any pre-execution Unix commands to set up test case.
   #-| ----------------------------------------------------
   echo " "
   set setup = `grep -c 'cmd::' $tcf`
   if ($setup > 0) then
      rm -f prerun_SetUp.csh
      echo "#\!/bin/csh" > prerun_SetUp.csh
      grep 'cmd::' $tcf | grep -v 'bin/csh' | sed 's/cmd:://' >> prerun_SetUp.csh
      csh prerun_SetUp.csh
   endif
   
   #-| -----------------------------------------------------------------
   #-| Write test case data to grading report.
   #-| -----------------------------------------------------------------
   repeat 2 echo " " >> $g
   echo "==> TestCase $testcasenum " >> $g
   repeat 1 echo " " >> $g
   
   echo "  INPUT DATA BEGIN =====> " >> $g
   repeat 1 echo " " >> $g
   sed "s/^/      /" $tcf >> $g
   repeat 1 echo " " >> $g
   echo "  INPUT DATA END <===== " >> $g
   
      
   #-| ------------------------------------------------------------------------
   #-| Run program assuming std input and output. Monitor process to avoid looping.
   #-| ------------------------------------------------------------------------
   @ totOutputBytes = 0
   set PIDs = ()
   set Pnames = ()
   #set procNAME = `echo $prog-$stud.run | ~cop3014cjoe/bin/Truncate8.run`
   set procNAME = `echo $prog-$stud.crun | ~/workspace/bin/Truncate8.crun`
   
   rm -f cout
   ./$prog-$stud.crun < cin > cout &
   sleep $sleepTime
  
   cp cout cout$testcasenum
 
   set PIDs = ( `ps |  grep $procNAME | awk '{print $1}' ` )
   set Pnames = ( `ps |  grep $procNAME | awk '{print $4}' ` )
   
   #-| ------------------------------------------------------------------------
   #-| If infinite loop detected, terminate with 0 score.
   #-| ------------------------------------------------------------------------
   if ($#PIDs) then
      echo "INFINITE LOOP: $prog-$stud.run "
      echo "        ... ======> INFINITE LOOP | STALLED PROGRAM"  >> $g
      foreach p ($PIDs)
         #echo "KILLING process $p - $Pnames[1]"
         kill $p
         shift Pnames
      end
      @ right = 0
      goto SHOW_RESULTS
   endif
   
   
   #-| ------------------------------------------------------------------------
   #-| RE-ESTABLISHED NEW 4-13-2020 SKIP DEFAULT MENU FILTERING.
   #-| NEW 11-26-2016 DEFAULT MENU FILTERING.
   #-| ------------------------------------------------------------------------
   if ($filtering <= 0) goto SKIP_DEFAULT_FILTERING
   
   cp cout COUT
   rm -f coutTEMP
   grep -v '^$' COUT > coutTEMP
   #wc COUT coutTEMP
   cp coutTEMP COUT
   rm -f coutTEMP
   
   #echo -n "ENTER to continue: "; set go = $<
   
   grep -v '|' COUT | grep -v '+' > coutTEMP
   cp coutTEMP COUT
   cp coutTEMP cout
   #wc COUT coutTEMP  cout
   #echo -n "ENTER to continue: "; set go = $<

   if ($#SINKS) sleep 1

SKIP_DEFAULT_FILTERING:

   NEW_SPLIT_SINKS:
   #-| ----------------------------------------------------
   #-| Tag output sinks.
   #-| ----------------------------------------------------
   rm -f RawTaggedResults
   echo -n "" > RawTaggedResults
   foreach s ( $SINKS )
      set tag = "${s}::"
      cat $s | sed "s/^/$tag/" >> RawTaggedResults
   end

   echo ""
   echo "" >> $g
   echo "  OUTPUT DATA BEGIN =====> " >> $g
   echo ""
   cat RawTaggedResults | sed 's/^/     /' >> $g 
   echo ""
   echo "  OUTPUT DATA END <===== " >> $g
   echo "" >> $g

   echo "=========== CHECKING RESULTS ============"
   echo ""
   echo "  =========== CHECKING RESULTS ============" >> $g
   #echo "" >> $g
   echo ""
   
   #-| ----------------------------------------------------
   #-| NEW: 2018-5-28
   #-| Extract check patterns per sink (sink:check).
   #-| ----------------------------------------------------
      #echo "SINKS = $SINKS "; echo -n "ENTER to continue: "; set go = $<
   foreach s ( $SINKS )
      set tag = "${s}::"

      set chkF = ${s}_expF
      rm -f $chkF
      grep $s $expf | sed "s/$tag//" > $chkF

     #-| ----------------------------------------------------
     #-| NEW: 2021-jul-12
     #-|     Skip grading output since when NOT REQUIRED.
     #-|     expf file contains line: _NOTREQUIRED_ 
     #-| ----------------------------------------------------
      set required = `grep -c _NOTREQUIRED_ $chkF`
      if ( $required > 0) then
        echo "NO EXPECTED RESULTS for $s ... "

      else
         echo "EXPECTED RESULTS for $s ... "
         cat $chkF 
   
         set resF = ${s}_resF 
         rm -f $resF
 
         echo "=========== CHECKING $s $chkF $resF =========="
         echo "" >> $g
         echo "        =========== CHECKING OUTPUT to $s  ==========" >> $g
         ~/workspace/bin/match.crun $chkF $s $resF
         cat $resF | sed 's/^/     /' >> $g
   
         #-|----------------------------------------
         #-| Update cumulative points. 
         #-|----------------------------------------
         set PTS = ( 0 0 1 0 )
         if ( -e $resF ) then
            set PTS = ( `tail -1 $resF`  $PTS )
         endif
         @ totRight += $PTS[1]
         @ totChecks += $PTS[3]

      endif # process sink
   end #foreach

   echo "" >> $g
   echo "  =========== END CHECKING RESULTS ============" >> $g
   echo "" >> $g
 

  #echo "=========== CHECKING $s $chkF $resF =========="

   @ testcasenum++
end
        # ====================================================== #
        # == testcases ========================================= #
        # ====================================================== #
#-| -------------------------------------------------------------------------
#-| ALL testcases have been executed. Compute/return overall score.
#-| -------------------------------------------------------------------------


SHOW_RESULTS:

echo "        $totRight / $totChecks CORRECT EXECUTION output"
echo "        " >> $g
echo "$totRight / $totChecks CORRECT EXECUTION output" >> $g
echo "        " >> $g

NOMORE_TESTCASES:

@ roundoff = $totChecks / 2
@ roundoff++
@ pts = $totRight * $execPts
@ pts = $roundoff + $pts
@ pts = $pts / $totChecks 
@ score = $pts

WRITESCORE:

#-| Print final score.
if ($score < 0) then
   echo "*** NO EXECUTION POINTS EARNED ***"
   echo "*** NO EXECUTION POINTS EARNED ***" >> $g
   @ score = 0
endif

echo "            Execution Points = $score / $execPts " 
echo " " >> $g
echo "Execution Points = $score / $execPts " >> $g
echo " " >> $g

exit $score

