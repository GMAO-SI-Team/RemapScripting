#!/bin/bash

SHAREDIR=/discover/nobackup/projects/gmao/share/gmao_ops

die () {
   echo >&2 "$@"
   exit 1
}

if [[ $# != 2 ]]
then
   die "2 arguments required (outdir, numlevels), $# provided"
fi

OUTDIR=$1

NUMLEVELS=$2

LEVDIR=L${NUMLEVELS}

CURRDIR=$(pwd)

# AEROCOMDIR
# ----------

CURRAEROCOMDIR=$CURRDIR/fvInput/AeroCom/
AEROCOMDIR=$OUTDIR/fvInput/AeroCom/

mkdir -v -p $AEROCOMDIR/$LEVDIR
cp -v $CURRAEROCOMDIR/scripts/doremap $AEROCOMDIR/$LEVDIR/

mkdir -v -p $AEROCOMDIR/$LEVDIR/aero_clm
cp -v $CURRAEROCOMDIR/scripts/aero_clm/doremap $AEROCOMDIR/$LEVDIR/aero_clm

cd $OUTDIR/fvInput
ln -sv AeroCom PIESA
cd $CURRDIR

# CMIPDIR
# -------

CURRCMIPDIR=$CURRDIR/fvInput/CMIP/
CMIPDIR=$OUTDIR/fvInput/CMIP/

mkdir -v -p $CMIPDIR/$LEVDIR
cp -v $CURRCMIPDIR/scripts/doremap $CMIPDIR/$LEVDIR/

# MERRA2DIR
# ---------

CURRMERRA2DIR=$CURRDIR/fvInput/MERRA2/
MERRA2DIR=$OUTDIR/fvInput/MERRA2/

mkdir -v -p $MERRA2DIR/$LEVDIR
cp -v $CURRMERRA2DIR/scripts/doremap $MERRA2DIR/$LEVDIR/

# NRDIR
# -----

CURRNRDIR=$CURRDIR/fvInput/NR/
NRDIR=$OUTDIR/fvInput/NR/

mkdir -v -p $NRDIR/$LEVDIR
cp -v $CURRNRDIR/scripts/doremap $NRDIR/$LEVDIR/

# CHEMDIR
# -------
CURRCHEMDIR=$CURRDIR/fvInput_nc3/g5chem/
CHEMDIR=$OUTDIR/fvInput_nc3/g5chem/

mkdir -v -p $CHEMDIR/$LEVDIR
mkdir -v -p $CHEMDIR/$LEVDIR/aero_clm

cp -v $CURRCHEMDIR/scripts/aero_clm/README $CHEMDIR/$LEVDIR/aero_clm/
cp -v $CURRCHEMDIR/scripts/aero_clm/remap $CHEMDIR/$LEVDIR/aero_clm/
cp -v $CURRCHEMDIR/scripts/aero_clm/remap_gfed $CHEMDIR/$LEVDIR/aero_clm/
