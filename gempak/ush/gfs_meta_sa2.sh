#! /usr/bin/env bash
#
# Metafile Script : gfs_meta_sa2.sh
#
# Creates several South American gfs charts, including 500mb and psml
# comparisons to the ecmwf and ukmet
#

source "${HOMEgfs}/ush/preamble.sh"

mkdir SA2
cd SA2 || exit 1


cp "${HOMEgfs}/gempak/fix/datatype.tbl" datatype.tbl

#
# Link data into DATA to sidestep gempak path limits
# TODO: Replace this
#
export HPCGFS="${RUN}.${PDY}${cyc}"
if [[ ! -L ${HPCGFS} ]]; then
    ${NLN} "${COM_ATMOS_GEMPAK_1p00}" "${HPCGFS}"
fi

mdl=gfs
MDL=GFS

metatype="sa2"
metaname="${mdl}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"

grid1="F-GFSHPC | ${PDY:2}/${cyc}00"

# DEFINE YESTERDAY
PDYm1="$(date --utc +%Y%m%d -d "${PDY} ${cyc} - 24 hours")"

HPCECMWF="ecmwf.${PDYm1}"
HPCUKMET="ukmet.${PDY}"
if [[ ! -L "${HPCECMWF}" ]]; then
    ${NLN} "${COMINecmwf}/ecmwf.${PDYm1}/gempak" "${HPCECMWF}"
fi
if [[ ! -L "${HPCUKMET}" ]]; then
    ${NLN} "${COMINukmet}/ukmet.${PDY}/gempak" "${HPCUKMET}"
fi

"${GEMEXE}/gdplot2_nc" << EOF
\$MAPFIL= mepowo.gsf
GDFILE	= ${grid1}
GDATTIM	= F000-F144-12
DEVICE	= ${device}
PANEL	= 0
TEXT	= 1/21//hw
CONTUR	= 1
MAP	= 1/1/1/yes
CLEAR	= yes
CLRBAR  = 1

PROJ    = mer//3;3;0;1
GAREA   = -66;-127;14.5;-19
LATLON	= 1//1/1/10

GLEVEL  = 500:1000!500:1000!0
GVCORD  = pres!pres    !none
SKIP    = 0/3;3
SCALE   = -1      !-1                  ! 0
GDPFUN  = (sub(hght@500,hght@1000))!(sub(hght@500,hght@1000))!sm5s(pmsl)
TYPE    = c
CINT    = 3/400/540     !3/543      ! 4
LINE    = 6/3/2         !2/3/2/2! 20//3
FINT    =
FLINE   =
HILO    = !!26;2/H#;L#/1020-1070;900-1012//30;30/y
HLSYM   = 1.3;1.3//21//hw
CLRBAR  = 1
WIND    = !                         !
REFVEC  =
TITLE	= 1/-2/~ ? ${MDL} MSLP, 1000-500mb THICK|~MSLP, 1000-500 THKN!
l
ru

GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  !0       !0                  !0        !0
SCALE   = 5                  !5       !5                  !5        !-1
GDPFUN  = (avor(wnd))//v     !v       !mul(v,-1)          !mul(v,-1)!sm5s(hght)
TYPE    = c/f                !c       !c/f                !c        !c
CINT    = 2/10/99            !2/6/8   !2/10/99            !2/4/8    !6
LINE    = 7/5/1/2            !29/5/1/2!7/5/1/2            !29/5/1/2 !20/1/2/1
FINT    = 16;20;24;28;32;36;40;44
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!        !2;6/X;N/10-99;10-99!         !
HLSYM   =
CLRBAR  = 1
WIND    = 0
REFVEC  =
TITLE   = 1/-2/~ ? ${MDL} @ HEIGHTS AND VORTICITY|~@ HGT AND VORTICITY!0
ru

GDATTIM  = f036
GLEVEL   = 500
GVCORD   = pres
PANEL    = 0
SKIP     = 0
SCALE    = -1!0!0!-1
GDPFUN   = sm5s(hght)!(sub(hght^f36,hght^f12))!(sub(hght^f36,hght^f12))!sm5s(hght)
TYPE     = c    !c/f     !c/f         !c
CONTUR   = 1
CINT     = 6    !20/20   !20/-500/-20 !6
LINE     = 5/1/3!32/1/1/1!1/10/2/1    !5/1/3
FINT     = 0!20;40;80;120;160;200;240!-240;-200;-160;-120;-80;-40;-20
FLINE    = 0!0;23;24;25;30;29;28;27  !11;12;2;10;15;14;13;0
HILO     = 0!0!0!5/H#;L#
HLSYM    = 0!!1.0//21//hw!1.5
CLRBAR   = 0!0!1!0
WIND     =
REFVEC   =
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 24-HR HGT FALLS!0
TEXT     = 1/21////hw
CLEAR    = YES
l
run

GDATTIM  = f060
GDPFUN   = sm5s(hght)!(sub(hght^f60,hght^f36))!(sub(hght^f60,hght^f36))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 24-HR HGT FALLS!0
l
run

GDATTIM  = f084
GDPFUN   = sm5s(hght)!(sub(hght^f84,hght^f60))!(sub(hght^f84,hght^f60))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 24-HR HGT FALLS!0
l
run

GDATTIM  = f108
GDPFUN   = sm5s(hght)!(sub(hght^f108,hght^f84))!(sub(hght^f108,hght^f84))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 24-HR HGT FALLS!0
l
run

GDATTIM  = f132
GDPFUN   = sm5s(hght)!(sub(hght^f132,hght^f108))!(sub(hght^f132,hght^f108))!sm5s(hght)
TITLE    = 1/-1/~ ? ${MDL} @ MB HGT|~500 HGT CHG!1/-2/~ ${MDL} @ MB 24-HR HGT FALLS!0
l
run

GAREA   = -66;-127;14.5;-19
LATLON  = 1//1/1/10

GDATTIM = F024-F144-12
GLEVEL  = 0
GVCORD  = none
SKIP    = 0
SCALE   = 0
GDPFUN  = p24m
TYPE    = c/f
CINT    = 0
LINE    = 0
FINT    = 1;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80;85
FLINE   = 0;21-30;14-20;5
HILO    = 31;0/x#/10-500///y
HLSYM   = 1.5
CLRBAR  = 1/V/LL
WIND    =
REFVEC  =
TITLE   = 1/-2/~ ${MDL} 24-HR TOTAL PCPN|~24-HR TOTAL PCPN!0
r

GLEVEL  = 250
GDATTIM = F000-F144-12
GVCORD  = PRES
SKIP    = 0
SCALE   = 0                        !-1         !5/0
GDPFUN  = knts(mag(wnd))//wnd      !sm5s(hght) !div(wnd)!kntv(wnd)
TYPE    = c/f                      !c          !c/f     !b
CINT    = 20/70//                  !12         !2/8
LINE    = 32/1/2/1                 !1/1/2/1    !5/2/1
FINT    = 70;90;110;130;150;170;190!           !1;2;3;4;5;6;7
FLINE   = 0;25;24;29;7;15;20;14    !           !0;23;22;21;17;16;2;1
HILO    = 0
HLSYM   = 0
CLRBAR  = 1/v/ll/.001;.001         !0          !0
WIND    = bk0                      !bk0        !am16/0.3//211/0.4!Bk9/0.75/2
REFVEC  = 10
TITLE   = 1/-2/~ ${MDL} @ WIND AND DIVERGENCE|~@ WIND AND DIV!0
MAP     = 31/1/1/yes
LATLON  = 31/1/1/1/10
ru

ex
EOF

for fhr in $(seq -s ' ' 6 24 126); do
    gfsfhr="F$(printf "%03g" "${fhr}")"
    if (( fhr < 100 )); then
        offset=6
    else
        offset=18
    fi
    ecmwffhr="F$(printf "%03g" $((fhr + offset)))"
    grid2="${HPCECMWF}/ecmwf_glob_${PDYm1}12"

    "${GEMEXE}/gdplot2_nc" << EOF10
\$MAPFIL = mepowo.gsf
GDFILE	= ${grid1} !${grid2}
GDATTIM	= ${gfsfhr}!${ecmwffhr}
DEVICE	= ${device}
PANEL	= 0
TEXT	= 1/21//hw
CONTUR	= 2
MAP	= 6/1/1/yes
CLEAR   = yes
CLRBAR  = 1
PROJ    = mer//3;3;0;1
GAREA   = -71;-135;20;-20
LATLON	= 18//1/1/10

GLEVEL  = 500
GVCORD  = PRES
PANEL   = 0
SKIP    = 0
SCALE   = -1
GDPFUN  = sm5s(hght)!sm5s(hght)
TYPE    = c
CONTUR  = 1
CINT    = 6
FINT    =
FLINE   =
HLSYM   =
WIND    =
REFVEC  =
LINE    = 31//2!2//2
HILO    = 31/H#;L#//5/5;5/y!2/H#;L#//5/5;5/y
TITLE   = 31/-1/~ ? ${MDL} @ HGHT (WHITE)|~EC VS ${MDL} 500!2/-2/~ ? ECMWF 500 HGHT (RED)
l
r

GLEVEL  = 0
GVCORD  = none
PANEL   = 0
SKIP    = 0
SCALE   = 0
GDPFUN  = (pmsl)!(pmsl)
TYPE    = c
CONTUR  = 7
CINT    = 4
FINT    =
FLINE   =
HLSYM   = 1.5;1.5//21//hw
CLRBAR  = 1
WIND    =
REFVEC  =
TEXT    = 1/21//hw
CLEAR   = yes
GDFILE  = ${grid1}!${grid2}
GDATTIM = ${gfsfhr}!${ecmwffhr}
LINE    = 31//2!2//2
HILO    = 31/H#;L#/1020-1060;900-1010/5/10;10!2/H#;L#/1020-1060;900-1010/5/10;10
TITLE   = 31/-1/~ ? ${MDL} PMSL (WHITE)|~EC VS ${MDL} PMSL!2/-2/~ ? ECMWF PMSL (RED)
l
r

ex
EOF10
done

for fhr in $(seq -s ' ' 6 12 138); do
    gfsfhr="F$(printf "%03g" "${fhr}")"
    ukmetfhr="F$(printf "%03g" $((fhr + 6)))"
    grid3="${HPCUKMET}/ukmet_${PDY}00f${ukmetfhr}"

    "${GEMEXE}/gdplot2_nc" << EOF25
\$MAPFIL = mepowo.gsf
DEVICE  = ${device}
PANEL   = 0
TEXT    = 1/21//hw
CONTUR  = 2
MAP     = 6/1/1/yes
CLEAR   = yes
CLRBAR  =
GLEVEL  = 500
GVCORD  = PRES
PANEL   = 0
SKIP    = 0
SCALE   = -1
GDPFUN  = sm5s(hght)!sm5s(hght)
TYPE    = c
CONTUR  = 1
CINT    = 6
FINT    =
FLINE   =
HLSYM   =
GVECT   =
WIND    =
REFVEC  =
clear   = yes
GDFILE  = ${grid1}!${grid3}
GDATTIM = ${gfsfhr}!F${ukmetfhr}
LINE    = 31//2!2//2
HILO    = 31/H#;L#//5/7;7/y!2/H#;L#//5/5;5/y
TITLE   = 31/-1/~ ? ${MDL} @ HGHT (WHITE)|~UK VS ${MDL} 500!2/-2/~ ? UKMET 500 HGHT (RED)
l
r

GLEVEL  = 0
GVCORD  = none
PANEL   = 0
SKIP    = 0
SCALE   = 0
GDPFUN  = sm5s(pmsl)!sm5s(pmsl)
TYPE    = c
CONTUR  = 2
CINT    = 4
FINT    =
FLINE   =
HLSYM   = 1.5;1.5//21//hw
CLRBAR  =
WIND    =
REFVEC  =
TEXT    = 1/21//hw
CLEAR   = yes
GDFILE  = ${grid1}!${grid3}
GDATTIM = ${gfsfhr}!F${ukmetfhr}
LINE    = 31//2!2//2
HILO    = 31/H#;L#/1020-1060;900-1010/5/10;10!2/H#;L#/1020-1060;900-1010/5/10;10
TITLE   = 31/-1/~ ? ${MDL} PMSL (WHITE)|~UK VS ${MDL} PMSL!2/-2/~ ? UKMET PMSL (RED)
l
r

ex
EOF25
done
export err=$?;err_chk

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
if (( err != 0 )) || [[ ! -s "${metaname}" ]] &> /dev/null; then
    echo "FATAL ERROR: Failed to create gempak meta file ${metaname}"
    exit $(( err + 100 ))
fi

mv "${metaname}" "${COM_ATMOS_GEMPAK_META}/${mdl}_${PDY}_${cyc}_${metatype}"
if [[ "${SENDDBN}" == "YES" ]] ; then
    "${DBNROOT}/bin/dbn_alert" MODEL "${DBN_ALERT_TYPE}" "${job}" \
        "${COM_ATMOS_GEMPAK_META}/${mdl}_${PDY}_${cyc}_${metatype}"
    if [[ ${DBN_ALERT_TYPE} == "GFS_METAFILE_LAST" ]] ; then
    DBN_ALERT_TYPE=GFS_METAFILE
    "${DBNROOT}/bin/dbn_alert" MODEL "${DBN_ALERT_TYPE}" "${job}" \
        "${COM_ATMOS_GEMPAK_META}/${mdl}_${PDY}_${cyc}_${metatype}"
    fi
fi

exit
