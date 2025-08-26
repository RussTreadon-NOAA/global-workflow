#! /usr/bin/env bash

set -x

###############################################################
# Source UFSDA workflow modules
source "${HOMEgfs}/dev/ush/load_ufsda_modules.sh"
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi

export job="atmanlfinal"
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

# link increment
RUNDIR=$DATAROOT/${RUN}atmanl_${cyc}/anl
if [[ ${tcyc} -ne ${cyc} ]]; then
   for n in $(seq 1 "${ntiles}"); do
      ln -fs $RUNDIR/gfs.t${tcyc}z.cubed_sphere_grid_atminc.tile${n}.nc $RUNDIR/gfs.t${cyc}z.cubed_sphere_grid_atminc.tile${n}.nc
   done
fi

###############################################################
# Execute the JJOB
"${HOMEgfs}/jobs/JGLOBAL_ATM_ANALYSIS_FINALIZE"
status=$?

# shellcheck disable=SC2153
##IFS=', ' read -r -a fhr_list <<< "${FHR_LIST}"
##for FORECAST_HOUR in "${fhr_list[@]}"; do
##        export fhr3=$(printf '%03s' "${FORECAST_HOUR}")
##done

source ${EXPDIR}/config.base
COMOUT_ATMOS_ANALYSIS="${ROTDIR}/${RUN}.${PDY}/${cyc}/analysis/${COMPONENT}"

# Save increments with unique filenames
for n in $(seq 1 "${ntiles}"); do
   mv ${COMOUT_ATMOS_ANALYSIS}/${RUN}.t${cyc}z.cubed_sphere_grid_atminc.tile${n}.nc ${COMOUT_ATMOS_ANALYSIS}/${RUN}.${tPDY}.t${tcyc}z.cubed_sphere_grid_atminc.tile${n}.nc
done

# Remove links
COMIN_ATMOS_MODEL_HISTORY="${ROTDIR}/${RUN}.${PDY}/${cyc}/model/${COMPONENT}/history"
rm -f ${COMIN_ATMOS_MODEL_HISTORY}/gdas.t${tgcyc}z.cubed_sphere_grid_atmf006.nc
rm -f ${COMIN_ATMOS_MODEL_HISTORY}/gdas.t${tgcyc}z.cubed_sphere_grid_sfcf006.nc

COMIN_OBS="${ROTDIR}/${RUN}.${PDY}/${cyc}/obs"
rm -f ${COMIN_OBS}/${RUN}.t${tcyc}z.conventional_ps.tm00.nc

echo "f${fhr3} atmanlfinal done" > ${COMOUT_ATMOS_ANALYSIS}/${RUN}.t${cyc}z.atmanlfinal.f${fhr3}.txt

exit "${status}"
