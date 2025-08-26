#! /usr/bin/env bash

set -x

###############################################################
# Source FV3GFS workflow modules
source "${HOMEgfs}/dev/ush/load_fv3gfs_modules.sh"
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi

export job="prep"
export jobid="${job}.$$"
source "${HOMEgfs}/ush/jjob_header.sh" -e "prep" -c "base prep"

# Strip 'enkf' from RUN for pulling data
RUN_local="${RUN/enkf}"

###############################################################
# Set script and dependency variables
# Ignore possible spelling error (nothing is misspelled)
# shellcheck disable=SC2153
ADATE=$(date --utc -d "${PDY} ${cyc} + ${assim_freq} hours" +%Y%m%d%H)
GDATE=$(date --utc -d "${PDY} ${cyc} - ${assim_freq} hours" +%Y%m%d%H)
# shellcheck disable=
gPDY=${GDATE:0:8}
gcyc=${GDATE:8:2}
GDUMP="gdas"

IFS=', ' read -r -a fhr_list <<< "${FHR_LIST}"
TDATE=$(date --utc -d "${PDY} ${cyc} + ${fhr_list} hours" +%Y%m%d%H)
export tPDY=${TDATE:0:8}
export tcyc=${TDATE:8:2}
TGDATE=$(date --utc -d "${tPDY} ${tcyc} - ${assim_freq} hours" +%Y%m%d%H)
tgPDY=${TGDATE:0:8}
tgcyc=${TGDATE:8:2}

export OPREFIX="${RUN}.t${cyc}z."

# Set paths to ouptut directories
RUN=${RUN_local} YMD=${PDY} HH=${cyc} declare_from_tmpl -rx \
   COMOUT_OBS:COM_OBS_TMPL

RUN=${GDUMP} YMD=${gPDY} HH=${gcyc} declare_from_tmpl -rx \
    COMOUT_OBS_PREV:COM_OBS_TMPL \

# Set paths to input directories
RUN=${RUN_local} YMD=${tPDY} HH=${tcyc} declare_from_tmpl -rx \
    COMIN_OBS:COM_OBS_TMPL \
    COMINobsproc:COM_OBSPROC_TMPL \
    COMIN_TCVITAL:COM_TCVITAL_TMPL

RUN=${GDUMP} YMD=${tgPDY} HH=${tgcyc} declare_from_tmpl -rx \
    COMINobsproc_PREV:COM_OBSPROC_TMPL

mkdir -p "${COMOUT_OBS}"

###############################################################
# Copy dump files to ROTDIR
"${HOMEgfs}/ush/getdump.sh" "${tPDY}" "${tcyc}" "${RUN_local}" "${COMINobsproc}" "${COMOUT_OBS}"
status=$?
if [[ ${status} -ne 0 ]]; then
    exit "${status}"
fi


# Source UFSDA  workflow modules
source "${HOMEgfs}/dev/ush/load_ufsda_modules.sh"

export fhr3=$(printf '%03s' "${fhr_list[0]}")
jobid="${job}_f${fhr3}.$$"
###############################################################
# Execute the JJOB
###############################################################
##"${HOMEgfs}/jobs/JGLOBAL_ATM_PREP_IODA_OBS"
"${HOMEgfs}/jobs/JGLOBAL_ATM_PREP_IODA_OBS_NUDGE"
status=$?
[[ ${status} -ne 0 ]] && exit "${status}"

# Save conventional_ps files with unique filenames
mv ${COMOUT_OBS}/${RUN}.t${tcyc}z.conventional_ps.tm00.nc ${COMOUT_OBS}/${RUN}.${tPDY}.t${tcyc}z.conventional_ps.tm00.nc

echo "f${fhr3} done" > ${COMOUT_OBS}/${OPREFIX}nudge.status.f${fhr3}.txt

################################################################################
# Exit out cleanly

exit 0
