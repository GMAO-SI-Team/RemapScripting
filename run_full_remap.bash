#!/bin/bash

# -----
# Usage
# -----

usage ()
{
   echo "Usage: $0 "
}

die () {
   echo >&2 "$@"
   exit 1
}

if [[ $# != 2 ]]
then
   die "2 arguments required (outdir, numlevels), $# provided"
fi

SHAREDIR=/discover/nobackup/projects/gmao/share/gmao_ops

OUTDIR=$1

NUMLEVELS=$2

LEVDIR=L${NUMLEVELS}

CURRDIR=$(pwd)

# Copy directory structure
# ------------------------

echo "Creating directory structure in $OUTDIR"

cp -r $CURRDIR/fvInput     $OUTDIR
cp -r $CURRDIR/fvInput_nc3 $OUTDIR

find $OUTDIR -type d -name 'scripts' -exec rename scripts $LEVDIR {} +

# AEROCOMDIR
# ----------

CURRAEROCOMDIR=$CURRDIR/fvInput/AeroCom/
AEROCOMDIR=$OUTDIR/fvInput/AeroCom/

echo "Running $CMIPDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $CMIPDIR/$LEVDIR/"
$CMIPDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $CMIPDIR/$LEVDIR/  > $CMIPDIR/$LEVDIR/doremap.log

# CMIPDIR
# -------

CURRCMIPDIR=$CURRDIR/fvInput/CMIP/
CMIPDIR=$OUTDIR/fvInput/CMIP/

echo "Running $CMIPDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $CMIPDIR/$LEVDIR/"
$CMIPDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $CMIPDIR/$LEVDIR/  > $CMIPDIR/$LEVDIR/doremap.log

# MERRA2DIR
# ---------

CURRMERRA2DIR=$CURRDIR/fvInput/MERRA2/
MERRA2DIR=$OUTDIR/fvInput/MERRA2/

echo "Running $MERRA2DIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $MERRA2DIR/$LEVDIR/"
$MERRA2DIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $MERRA2DIR/$LEVDIR/  > $MERRA2DIR/$LEVDIR/doremap.log


# NRDIR
# -----

CURRNRDIR=$CURRDIR/fvInput/NR/
NRDIR=$OUTDIR/fvInput/NR/

echo "Running $NRDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $NRDIR/$LEVDIR/"
$NRDIR/$LEVDIR/doremap -levs ${NUMLEVELS} -outdir $NRDIR/$LEVDIR/  > $NRDIR/$LEVDIR/doremap.log

# CHEMDIR
# -------
CURRCHEMDIR=$CURRDIR/fvInput_nc3/g5chem/
CHEMDIR=$OUTDIR/fvInput_nc3/g5chem/

echo "Running $CHEMDIR/$LEVDIR/remap -levs ${NUMLEVELS} -outdir $CHEMDIR/$LEVDIR/"
$CHEMDIR/$LEVDIR/remap -levs ${NUMLEVELS} -outdir $CHEMDIR/$LEVDIR/  > $CHEMDIR/$LEVDIR/remap.log

echo "Running $CHEMDIR/$LEVDIR/remap_gfed -levs ${NUMLEVELS} -outdir $CHEMDIR/$LEVDIR/"
$CHEMDIR/$LEVDIR/remap_gfed -levs ${NUMLEVELS} -outdir $CHEMDIR/$LEVDIR/  > $CHEMDIR/$LEVDIR/remap_gfed.log

# PIESA
# -----

cd $OUTDIR/fvInput
ln -sv AeroCom PIESA
cd $CURRDIR

