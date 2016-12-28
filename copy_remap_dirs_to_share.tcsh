#!/bin/tcsh -f

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
      echo "ERROR! $SHAREDIR/fvInput/$TYPE/$LEVDIR exists!"
      exit 1
   else
      cp -rv $WORKDIR/fvInput/$TYPE/$LEVDIR $SHAREDIR/fvInput/$TYPE
   endif
end

# -----------
# fvInput_nc3
# -----------

if ( -d $SHAREDIR/fvInput_nc3/g5chem/$LEVDIR ) then
   echo "ERROR! $SHAREDIR/fvInput_nc3/g5chem/$LEVDIR exists!"
   exit 1
else
   cp -rv $WORKDIR/fvInput_nc3/g5chem/$LEVDIR $SHAREDIR/fvInput_nc3/g5chem/
end

if ( -d $SHAREDIR/fvInput_nc3/g5gcm/moist/$LEVDIR ) then
   echo "ERROR! $SHAREDIR/fvInput_nc3/g5gcm/moist/$LEVDIR exists!"
   exit 1
else
   cp -rv $WORKDIR/fvInput_nc3/g5gcm/moist/$LEVDIR $SHAREDIR/fvInput_nc3/g5gcm/moist/
endif

usage:
cat <<EOF

usage: $0:t -levs numlevels -indir INDIR

EOF

