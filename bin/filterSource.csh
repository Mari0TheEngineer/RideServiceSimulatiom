#!/bin/csh
# -----------------------------------------------------------------------
# File name:  filterSource.csh
# Purpose:    Filter source file by removing lines containing filter
#             patterns in public repository file prog:srcFilter.
#             
# Invocation: filterSource.csh srcfile srcFilter 
#
# Example:    filterSource.csh mytest.cpp mytest:srcFilter
#             
# -----------------------------------------------------------------------

if ($#argv != 2) then
   echo "USAGE:   filterSource.csh sourcefile srcFilter"
   echo " "
   echo "Example: filterSource.csh myprog.cpp myprog:srcFilter"
   exit 1
else
   set src = $1
   set filter = $2
endif

if (-e $filter) then

   ENCODE.csh $src filtered.cpp
   #echo "ENCODED: ---------------"
   #cat filtered.cpp
   #echo -n "ENTER "; set go = $<

   foreach BUMP (`cat $filter`)
      rm -f SFtempSF
      set pat = "`echo $BUMP | sed 's#+#.*#g'`"
      #echo "grep -v $pat filtered.cpp > SFtempSF "
      #echo -n "ENTER "; set go = $<

      grep -v "$pat" filtered.cpp > SFtempSF 
      #echo "FILTER STEP: ---------------"
      #cat SFtempSF
      #echo -n "ENTER "; set go = $<
      cp SFtempSF filtered.cpp
   end 

   DECODE.csh filtered.cpp filtered_$src 
   #echo "FINAL FILTERED CODE - encoded: ==============="
   #cat filtered.cpp
   #echo -n "ENTER "; set go = $<

   echo "START FILTERED CODE  ==============="
   cat filtered_$src
   echo "END FILTERED CODE ==============="

   cp filtered_$src $src
endif


