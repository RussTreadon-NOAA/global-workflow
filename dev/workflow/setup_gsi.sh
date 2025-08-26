#!/bin/bash

set -x

# Set path to working copy of g-w clone
HOMEgfs=/scratch3/NCEPDEV/da/Russ.Treadon/git/global-workflow/nudging_rt


# Set variables for parallel
export HPC_ACCOUNT="da-cpu"
export PSLOT=gsi
export IDATE=2025022000
export EDATE=2025030100
export COMROOT=/scratch3/NCEPDEV/stmp/Russ.Treadon/COMROOT
export EXPDIR=/scratch3/NCEPDEV/stmp/Russ.Treadon/EXPDIR
export ICSDIR=/scratch3/NCEPDEV/da/Russ.Treadon/ICSDIR/gdas.init.2025022000/output


# Remove COMROOT/ and EXPDIR PSLOT if they exist
if [ -d "${COMROOT}/${PSLOT}" ]; then
    rm -rf ${COMROOT}/${PSLOT}
fi
if [ -d "${EXPDIR}/${PSLOT}" ]; then
    rm -rf ${EXPDIR}/${PSLOT}
fi


# Load required modules
set +x
source $HOMEgfs/dev/ush/gw_setup.sh
set -x
module list

# Create EXPDIR and COMROOT
$HOMEgfs/dev/workflow/setup_expt.py gfs cycled --app ATM --pslot $PSLOT --idate $IDATE --edate $EDATE --comroot $COMROOT --expdir $EXPDIR --resdetatmos 192 --resensatmos 96 --nens 0 --interval 24 --icsdir $ICSDIR


