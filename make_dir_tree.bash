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

WORKDIR=$(pwd)

# AEROCOMDIR
# ----------

AEROCOMDIR=$WORKDIR/fvInput/AeroCom/L${NUMLEVELS}
mkdir -v -p $AEROCOMDIR
mkdir -v -p $AEROCOMDIR/aero_clm

# CMIPDIR
# -------

CMIPDIR=$WORKDIR/fvInput/CMIP/L${NUMLEVELS}
mkdir -v -p $CMIPDIR

# MERRA2DIR
# ---------

MERRA2DIR=$WORKDIR/fvInput/MERRA2/L${NUMLEVELS}
mkdir -v -p $MERRA2DIR

# NRDIR
# -----

NRDIR=$WORKDIR/fvInput/NR/L${NUMLEVELS}
mkdir -v -p $NRDIR

# CHEMDIR
# -------
CHEMDIR=$WORKDIR/fvInput_nc3/g5chem/L${NUMLEVELS}
mkdir -v -p $CHEMDIR
mkdir -v -p $CHEMDIR/aero_clm
cp -v $SHAREDIR/fvInput_nc3/g5chem/L137/aero_clm/d5_merra.PS.clim.ALL.DC0576xPC0361.nc4 $CHEMDIR/aero_clm
