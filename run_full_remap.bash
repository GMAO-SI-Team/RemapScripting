#!/bin/bash

SHAREDIR=/discover/nobackup/projects/gmao/share/gmao_ops

die () {
   echo >&2 "$@"
   exit 1
}

if [[ $# != 1 ]]
then
   die "1 argument required (num levels), $# provided"
fi

NUMLEVELS=$1

LEVDIR=L${NUMLEVELS}

WORKDIR=$(pwd)

# AEROCOMDIR
# ----------

AEROCOMDIR=$WORKDIR/fvInput/AeroCom/
mkdir -v -p $AEROCOMDIR/$LEVDIR
cp -v $AEROCOMDIR/scripts/dore
mkdir -v -p $AEROCOMDIR/$LEVDIR/aero_clm

# CMIPDIR
# -------

CMIPDIR=$WORKDIR/fvInput/CMIP/
mkdir -v -p $CMIPDIR/$LEVDIR

# MERRA2DIR
# ---------

MERRA2DIR=$WORKDIR/fvInput/MERRA2/
mkdir -v -p $MERRA2DIR/$LEVDIR

# NRDIR
# -----

NRDIR=$WORKDIR/fvInput/NR/
mkdir -v -p $NRDIR/$LEVDIR

# CHEMDIR
# -------
CHEMDIR=$WORKDIR/fvInput_nc3/g5chem/
mkdir -v -p $CHEMDIR/$LEVDIR
mkdir -v -p $CHEMDIR/$LEVDIR/aero_clm
