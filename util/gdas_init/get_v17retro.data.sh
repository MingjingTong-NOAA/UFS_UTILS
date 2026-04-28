#!/bin/bash

#----------------------------------------------------------------------
# Retrieve gfs v17 retrospective parallel data from hpss.
#----------------------------------------------------------------------

bundle=$1

set -x

cd $EXTRACT_DIR

workdir=$EXTRACT_DIR/logs/$yy$mm$dd$hh/$bundle

if [ ! -d $workdir ]; then
  mkdir -p $workdir
fi

date10_m6=`$NDATE -6 $yy$mm$dd$hh`

echo $date10_m6
yy_m6=$(echo $date10_m6 | cut -c1-4)
mm_m6=$(echo $date10_m6 | cut -c5-6)
dd_m6=$(echo $date10_m6 | cut -c7-8)
hh_m6=$(echo $date10_m6 | cut -c9-10)

#----------------------------------------------------------------------
# Get the atm and sfc 'anl' netcdf files from the gfs or gdas
# tarball.
#----------------------------------------------------------------------

if [ "$bundle" = "gdas" ] || [ "$bundle" = "gfs" ]; then

  if [ ${yy}${mm}${dd}${hh} -lt 2022081512 ]; then
    set +x
    echo NO DATA FOR ${yy}${mm}${dd}${hh}
    exit 2
  elif [ ${yy}${mm}${dd}${hh} -le 2022101518 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream1a/${yy}${mm}${dd}${hh}
  elif [ ${yy}${mm}${dd}${hh} -ge 2024021512 ] && [ ${yy}${mm}${dd}${hh} -lt 2024051512 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream1b/${yy}${mm}${dd}${hh}
  elif [ ${yy}${mm}${dd}${hh} -ge 2024051512 ] && [ ${yy}${mm}${dd}${hh} -le 2024120100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_stream2/${yy}${mm}${dd}${hh}
  elif [ ${yy}${mm}${dd}${hh} -le 2025053118 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_stream3/${yy}${mm}${dd}${hh}
  elif [ ${yy}${mm}${dd}${hh} -le 2025120100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream4/${yy}${mm}${dd}${hh}
  elif [ ${yy}${mm}${dd}${hh} -lt 2026101100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_realtime/${yy}${mm}${dd}${hh}
  else
    set +x
    echo NO DATA FOR ${yy}${mm}${dd}${hh}
    exit 3
  fi

  if [ "$bundle" = "gdas" ] ; then
    file=gdas.tar
  else
    file=gfs_netcdfa.tar
  fi

  rm -f $workdir/list.hires*
  touch $workdir/list.hires3
  htar -tvf  $directory/$file > $workdir/list.hires1
  grep "z.analysis.atm.a006" $workdir/list.hires1 >  $workdir/list.hires2
  grep "z.analysis.sfc.a006" $workdir/list.hires1 >> $workdir/list.hires2
  while read -r line
  do 
    echo ${line##*' '} >> $workdir/list.hires3
  done < "$workdir/list.hires2"

  htar -xvf $directory/$file -L $workdir/list.hires3
  rc=$?
  [ $rc != 0 ] && exit $rc

  rm -f $workdir/list.hires*

#----------------------------------------------------------------------
# Get the 'abias' and radstat files when processing 'gdas'.
#----------------------------------------------------------------------

    file=gdas.tar

    htar -xvf $directory/$file gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.abias.txt
    rc=$?
    [ $rc != 0 ] && exit $rc
    htar -xvf $directory/$file gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.abias_air.txt
    rc=$?
    [ $rc != 0 ] && exit $rc
    htar -xvf $directory/$file gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.abias_int.txt
    rc=$?
    [ $rc != 0 ] && exit $rc
    htar -xvf $directory/$file gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.abias_pc.txt
    rc=$?
    [ $rc != 0 ] && exit $rc
    htar -xvf $directory/$file gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.radstat.tar
    rc=$?
    [ $rc != 0 ] && exit $rc
    chgrp rstprod gdas.${yy}${mm}${dd}/${hh}/analysis/atmos/gdas.t${hh}z.radstat
    rc=$?
    [ $rc != 0 ] && exit $rc

  fi

#----------------------------------------------------------------------
# Get the enkf netcdf history files.  They are not saved for the
# current cycle.  So get the 6-hr forecast files from the
# previous cycle.
#----------------------------------------------------------------------

else

  group=$bundle

  if [ $date10_m6 -lt 2022081512 ]; then
    set +x
    echo NO DATA FOR ${yy}${mm}${dd}${hh}
    exit 2
  elif [ $date10_m6 -le 2022101518 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream1a/${date10_m6}
  elif [ $date10_m6 -ge 2024021512 ] && [ $date10_m6 -lt 2024051512 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream1b/${date10_m6}
  elif [ $date10_m6 -ge 2024051512 ] && [ $date10_m6 -le 2024120100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_stream2/${date10_m6}
  elif [ $date10_m6 -le 2025053118 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_stream3/${date10_m6}
  elif [ $date10_m6 -le 2025120100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/GAEAC6/GFSv17/retrov17_01_stream4/${date10_m6}
  elif [ $date10_m6 -lt 2026101100 ]; then
    directory=/5year/NCEPDEV/emc-global/emc.glopara/WCOSS2/GFSv17/retrov17_01_realtime/${date10_m6}
  else
    set +x
    echo NO DATA FOR ${date10_m6}
    exit 3
  fi

  file=enkfgdas_${group}.tar

  rm -f $workdir/list*.${group}
  htar -tvf  $directory/$file > $workdir/list1.${group}
  grep "f006.nc" $workdir/list1.${group} > $workdir/list2.${group}
  while read -r line
  do 
    echo ${line##*' '} >> $workdir/list3.${group}
  done < "$workdir/list2.${group}"
  htar -xvf $directory/$file  -L $workdir/list3.${group}
  rc=$?
  [ $rc != 0 ] && exit $rc
  rm -f $workdir/list*.${group}

fi

rm -rf $workdir

set +x
echo DATA PULL FOR $bundle DONE

exit 0
