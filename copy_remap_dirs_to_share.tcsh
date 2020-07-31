#!/bin/tcsh -f
# Script from Matt Thompson, modified by Rob Lucchesi
#
# NOTE: If the script complains aobut duplicate directories,
# the following sequence of BASH command lines can be used in
# source directory to compare with the files at the target 
# directory in $SHARE/gmao_ops.
#
#  find . -type f  | while read file; do if [ -e /discover/nobackup/projects/gmao/share/gmao_ops/$file ]; then ls -l  /discover/nobackup/projects/gmao/share/gmao_ops/$file; fi; done
#  find . -type f  | while read file; do if [ -e /discover/nobackup/projects/gmao/share/gmao_ops/$file ]; then cmp $file  /discover/nobackup/projects/gmao/share/gmao_ops/$file; fi; done
#
#
#

# ------------------------------
# Process command line arguments
# ------------------------------

if ($#argv != 4) then
   goto usage
endif

while ($#argv)

   if ( ( "$1" != "-levs" ) && ( "$1" != "-indir") ) then
      goto usage
   endif

   if ("$1" == "-levs") then
      shift; if (! $#argv) goto usage
      set numlevs = $1
   endif

   if ("$1" == "-indir") then
      shift; if (! $#argv) goto usage
      set indir = "$1"
   endif

   shift
end

set SHAREDIR = "/discover/nobackup/projects/gmao/share/gmao_ops"
set LEVDIR = "L$numlevs"
set WORKDIR = $indir

echo "Copying $LEVDIR files from $WORKDIR to $SHAREDIR"

# -------
# fvInput
# -------

set FVINPUT_TYPES = ( AeroCom CMIP MERRA2 NR )

foreach TYPE ( `echo $FVINPUT_TYPES` )

   echo "Working on $TYPE..."

   if ( -d $SHAREDIR/fvInput/$TYPE/$LEVDIR ) then
      echo "WARNING! $SHAREDIR/fvInput/$TYPE/$LEVDIR exists!"
      echo -n "\n Make sure you are not overwriting files. Do you wish to continue? [y/n] "
      set reply = $<
      if ( "$reply" != "y" ) then
          exit 1
      endif
   endif
   cp -rv $WORKDIR/fvInput/$TYPE/$LEVDIR $SHAREDIR/fvInput/$TYPE
end

# -----------
# fvInput_nc3
# -----------

if ( -d $SHAREDIR/fvInput_nc3/g5chem/$LEVDIR ) then
   echo "WARNING! $SHAREDIR/fvInput_nc3/g5chem/$LEVDIR exists!"
   echo -n "\n Make sure you are not overwriting files. Do you wish to continue? [y/n] "
   set reply = $<
   if ( "$reply" != "y" ) then
       exit 1
   endif
endif
cp -rv $WORKDIR/fvInput_nc3/g5chem/$LEVDIR $SHAREDIR/fvInput_nc3/g5chem/

if ( -d $SHAREDIR/fvInput_nc3/g5gcm/moist/$LEVDIR ) then
   echo "WARNING! $SHAREDIR/fvInput_nc3/g5gcm/moist/$LEVDIR exists!"
   echo -n "\n Make sure you are not overwriting files. Do you wish to continue? [y/n] "
   set reply = $<
   if ( "$reply" != "y" ) then
       exit 1
   endif
endif
cp -rv $WORKDIR/fvInput_nc3/g5gcm/moist/$LEVDIR $SHAREDIR/fvInput_nc3/g5gcm/moist/

usage:
cat <<EOF

usage: $0:t -levs numlevels -indir INDIR

EOF

