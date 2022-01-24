#!/bin/csh
#----------------------------------------------------------
# Filename:  compileall.csh
# Purpose:   Compile all files in directory, produce .crun files.
# Usage:     compileall.csh [basefilename]
# Example:   compileall.csh
#            compileall.csh calculator
# Outputs:   filename.crun
#----------------------------------------------------------

foreach n ( *$1*.cpp)
   set runF = `echo $n | sed 's/\.cpp/.crun/'`
   set objF = `echo $n | sed 's/\.cpp/.o/'`
   set logF = `echo $n | sed 's/\.cpp/.ERRlog/'`
   rm -f $runF $logF
   g++ -c $n 
   if ( $status == 0) then
      g++ $n -o $runF
   else
      g++ $n >& $logF
   endif
   rm -f $objF 
end
