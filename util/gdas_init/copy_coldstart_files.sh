#!/bin/bash

# Copy files from the working directory to the
# output directory.

copy_data()
{

  set -x

  MEM=$1

  SAVEDIR_MODEL_DATA=${COMOUT_ATMOS_INPUT:-$SUBDIR}
  [[ ! -d $SAVEDIR_MODEL_DATA ]] && mkdir -p $SAVEDIR_MODEL_DATA
  cp gfs_ctrl.nc $SAVEDIR_MODEL_DATA

  for tile in 'tile1' 'tile2' 'tile3' 'tile4' 'tile5' 'tile6'
  do
    cp out.atm.${tile}.nc ${SAVEDIR_MODEL_DATA}/gfs_data.${tile}.nc
    cp out.sfc.${tile}.nc ${SAVEDIR_MODEL_DATA}/sfc_data.${tile}.nc
  done

  if [[ ${MEM} == 'gdas' ]]; then
    SAVEDIR_ANALYSIS=${COMOUT_ATMOS_ANALYSIS:-$SUBDIR_ANAL}
    if [[ ${COPYABIAS:-"NO"} == "YES" && ! -s ${SAVEDIR_ANALYSIS}/gdas.t${hh}z.abias ]]; then
      [[ ! -d $SAVEDIR_ANALYSIS ]] && mkdir -p $SAVEDIR_ANALYSIS
      cp ./gdas*abias* $SAVEDIR_ANALYSIS/
      [[ ! -d $SAVEDIR_ANALYSIS_CRES ]] && mkdir -p $SAVEDIR_ANALYSIS_CRES
      ln -s $SAVEDIR_ANALYSIS/* $SAVEDIR_ANALYSIS_CRES/
    fi
  fi
}

set -x

MEMBER=$1
OUTDIR=$2
yy=$3
mm=$4
dd=$5
hh=$6
INPUT_DATA_DIR=$7
CRES=$8
COPYABIAS=$9

if [ ${MEMBER} == 'hires' ]; then
  MEMBER='gdas'
fi

set +x
echo 'COPY DATA TO OUTPUT DIRECTORY'
set -x

if [ ${MEMBER} == 'gdas' ] || [ ${MEMBER} == 'gfs' ]; then
  SUBDIR=${OUTDIR}/${CRES}/${MEMBER}.${yy}${mm}${dd}/${hh}/model/atmos/input
  SUBDIR_ANAL=${OUTDIR}/${MEMBER}.${yy}${mm}${dd}/${hh}/analysis/atmos
  SUBDIR_ANAL_CRES=${OUTDIR}/${CRES}/${MEMBER}.${yy}${mm}${dd}/${hh}/analysis/atmos
  copy_data ${MEMBER}
elif [ ${MEMBER} == 'enkf' ]; then  # v16 retro data only.
  MEMBER=1
  while [ $MEMBER -le 80 ]; do
    if [ $MEMBER -lt 10 ]; then
      MEMBER_CH="00${MEMBER}"
    else
      MEMBER_CH="0${MEMBER}"
    fi
    SUBDIR=${OUTDIR}/${CRES}/enkfgdas.${yy}${mm}${dd}/${hh}/mem${MEMBER_CH}/model/atmos/input
    copy_data ${MEMBER}
    MEMBER=$(( $MEMBER + 1 ))
  done
else
  SUBDIR=${OUTDIR}/${CRES}/enkfgdas.${yy}${mm}${dd}/${hh}/mem${MEMBER}/model/atmos/input
  copy_data ${MEMBER}
fi

exit 0
