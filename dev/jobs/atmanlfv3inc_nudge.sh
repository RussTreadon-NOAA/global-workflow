#! /usr/bin/env bash

set -x

###############################################################
# Source UFSDA workflow modules
source "${HOMEgfs}/dev/ush/load_ufsda_modules.sh"
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi

export job="atmanlfv3inc"
export jobid="${job}.$$"

# shellcheck disable=SC2153
IFS=', ' read -r -a fhr_list <<< "${FHR_LIST}"
export fhr3=$(printf '%03s' "${fhr_list[0]}")

###############################################################
# Execute the JJOB
"${HOMEgfs}/jobs/JGLOBAL_ATM_ANALYSIS_FV3_INCREMENT"
status=$?

# shellcheck disable=SC2153
##IFS=', ' read -r -a fhr_list <<< "${FHR_LIST}"
##for FORECAST_HOUR in "${fhr_list[@]}"; do
##        export fhr3=$(printf '%03s' "${FORECAST_HOUR}")
##done

source ${EXPDIR}/config.base
COMOUT_ATMOS_ANALYSIS="${ROTDIR}/${RUN}.${PDY}/${cyc}/analysis/${COMPONENT}"
echo "f${fhr3} atmanlfv3inc done" > ${COMOUT_ATMOS_ANALYSIS}/${RUN}.t${cyc}z.atmanlfv3inc.f${fhr3}.txt

exit "${status}"
