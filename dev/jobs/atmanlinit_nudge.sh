#! /usr/bin/env bash

set -x

###############################################################
# Source UFSDA workflow modules
source "${HOMEgfs}/dev/ush/load_ufsda_modules.sh"
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi

export job="atmanlinit"
export jobid="${job}.$$"

# shellcheck disable=SC2153
IFS=', ' read -r -a fhr_list <<< "${FHR_LIST}"
export fhr3=$(printf '%03s' "${fhr_list[0]}")

source ${EXPDIR}/config.base

TDATE=$(date --utc -d "${PDY} ${cyc} + ${fhr_list} hours" +%Y%m%d%H)
export tPDY=${TDATE:0:8}
export tcyc=${TDATE:8:2}
TGDATE=$(date --utc -d "${tPDY} ${tcyc} - ${assim_freq} hours" +%Y%m%d%H)
tgPDY=${TGDATE:0:8}
tgcyc=${TGDATE:8:2}

# link background
COMIN_ATMOS_MODEL_HISTORY="${ROTDIR}/${RUN}.${PDY}/${cyc}/model/${COMPONENT}/history"
ln -fs ${COMIN_ATMOS_MODEL_HISTORY}/gfs.t${cyc}z.cubed_sphere_grid_atmf${fhr3}.nc ${COMIN_ATMOS_MODEL_HISTORY}/gdas.t${tgcyc}z.cubed_sphere_grid_atmf006.nc
ln -fs ${COMIN_ATMOS_MODEL_HISTORY}/gfs.t${cyc}z.cubed_sphere_grid_sfcf${fhr3}.nc ${COMIN_ATMOS_MODEL_HISTORY}/gdas.t${tgcyc}z.cubed_sphere_grid_sfcf006.nc

# link observation
COMIN_OBS="${ROTDIR}/${RUN}.${PDY}/${cyc}/obs"
ln -fs ${COMIN_OBS}/${RUN}.${tPDY}.t${tcyc}z.conventional_ps.tm00.nc ${COMIN_OBS}/${RUN}.t${tcyc}z.conventional_ps.tm00.nc

###############################################################
# Execute the JJOB
##"${HOMEgfs}/jobs/JGLOBAL_ATM_ANALYSIS_INITIALIZE"
"${HOMEgfs}/jobs/JGLOBAL_ATM_ANALYSIS_INITIALIZE_NUDGE"
status=$?

COMOUT_ATMOS_ANALYSIS="${ROTDIR}/${RUN}.${PDY}/${cyc}/analysis/${COMPONENT}"
mkdir -m 775 -p "${COMOUT_ATMOS_ANALYSIS}"
echo "f${fhr3} atmanlinit done" > ${COMOUT_ATMOS_ANALYSIS}/${RUN}.t${cyc}z.atmanlinit.f${fhr3}.txt

exit "${status}"
