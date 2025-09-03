#! /usr/bin/env bash

set -x

cd $ROTDIR

HTAR="/apps/hpss/htar -T 4"

# Extract gfs sfcanl tiles
$HTAR -xvf /NCEPDEV/${HPSS_PROJECT}/1year/${USER}/${machine}/scratch/gsi_test/${PDY}${cyc}/gfs_restarta.tar
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi


# Extract gfs atminc
$HTAR -xvf /NCEPDEV/${HPSS_PROJECT}/1year/${USER}/${machine}/scratch/gsi_test/${PDY}${cyc}/gfs_netcdfa.tar
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi


# Extract ioda format conventional ps dump
$HTAR -xvf /NCEPDEV/${HPSS_PROJECT}/1year/${USER}/${machine}/scratch/gsi_test/${PDY}${cyc}/gdas.tar gdas.${PDY}/${cyc}/obs/gdas.t{$cyc}z.conventional_ps.tm00.nc


# Extract gdas restart from previous cycle
GDATE=$(date --utc -d "${PDY} ${cyc} - ${assim_freq} hours" +%Y%m%d%H)
# shellcheck disable=
gPDY=${GDATE:0:8}
gcyc=${GDATE:8:2}
$HTAR -xvf /NCEPDEV/${HPSS_PROJECT}/1year/${USER}/${machine}/scratch/gsi_test/${gPDY}${gcyc}/gdas_restartb.tar
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi

# Create log file
echo "stage_ic_nudge done for ${PDY}${cyc}" > $ROTDIR/gfs.${PDY}/${cyc}/analysis/atmos/gfs.t${cyc}z.atmanlfinal.f000.txt

################################################################################
# Exit out cleanly

exit 0
