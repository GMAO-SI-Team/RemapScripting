#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
CURRDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# -----------------
# Detect usual bits
# -----------------

ARCH=$(uname -s)
MACH=$(uname -m)
NODE=$(uname -n)

# ------------------------------
# Define an in-place sed command
# Because Mac sed is stupid old,
# use gsed if found.
# ------------------------------

if [[ $ARCH == Darwin ]]
then
   if [[ $(command -v gsed) ]]
   then
      echo "Found gsed on macOS. You are smart!"
      SED="$(command -v gsed) "
      ISED="$SED -i "
   else
      echo "It is recommended to use GNU sed since macOS default"
      echo "sed is a useless BSD variant. Consider installing"
      echo "GNU sed from a packager like Homebrew."
      SED="$(command -v sed) "
      ISED="$SED -i.macbak "
   fi 
else
   SED="$(command -v sed) "
   ISED="$SED -i "
fi

if [ -z $ESMADIR ] 
then
   echo "ERROR: you need to set environment variable ESMADIR"
   echo "Please source g5_modules"
   exit
fi

if [ -z $BASEDIR ] 
then
   echo "ERROR: you need to set environment variable BASEDIR"
   echo "Please source g5_modules"
   exit
fi

SRCNAME=rsf91

BASEBIN=${BASEDIR}/Linux/bin

NETCDF_INCLUDES=$(${BASEBIN}/nf-config --includedir)/netcdf
NETCDF_LIBS=$(${BASEBIN}/nf-config --flibs)

MPIFC=mpiifort

${MPIFC} -convert big_endian -fPIC -O0 -o ${SRCNAME}.x ${SRCNAME}.F90 interp.F \
   -I${NETCDF_INCLUDES} ${NETCDF_LIBS}

./${SRCNAME}.x
