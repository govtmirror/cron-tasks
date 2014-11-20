#!/bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.
thisdir=`pwd`
format=
output=
sql_file=

while getopts ":f:o:s:" opt; do
  case "$opt" in
    f)  format=$OPTARG;;
    o)  output=$OPTARG;;
    s)  sql_file=$OPTARG;;
  esac
done;

if [ -z $format ]; then
  echo    "╔════════════════════════════════════════════════════════════════════════════╗"
  echo    " File Format"
  read -p "  What do your file to be exported as? (ex. FileGDB, geojson): " format
fi
if [ -z $output ]; then
  echo    "╔════════════════════════════════════════════════════════════════════════════╗"
  echo    " File Location"
  read -p "  Where do your file to be exported? (ex. $pwd/exports/file.ext): " output
fi
if [ -z $sql_file ]; then
  echo    "╔════════════════════════════════════════════════════════════════════════════╗"
  echo    " SQL File"
  read -p "  What is the name of the file that contains your SQL query? (Should be a file in $thisdir/sql/): " sql_file
fi

if [ -z "$format" -o -z "$output" -o -z "$sql_file" ]
then
  echo    "╔════════════════════════════════════════════════════════════════════════════╗"
  echo    " There was a problem with one or more of your parameters"
  echo    " format: \"$format\""
  echo    " output: \"$output\""
  echo    " sql_file: \"$sql_file\""
  exit 1
fi
sql_file=$thisdir/sql/$sql_file
if [ ! -f $sql_file ]; then
  echo    "╔════════════════════════════════════════════════════════════════════════════╗"
  echo    " File not found:"
  echo    " $sql_file"
  exit 1
fi

ogrexec=`which ogr2ogr`
pg_host=inpniscvplaces1
pg_dbname=poi_pgs
pg_user=osm
pg_connection="host=$pg_host dbname=$pg_dbname user=$pg_user"
pg_sql=`cat $sql_file | perl -pe 's/\n/ /g' | perl -pe 's/\s{1,}/ /g'`
ogr_options="-overwrite -nlt POINT -s_srs EPSG:4326 -t_srs EPSG:4326"

# Do a git fetch for the repo where we're writing
cd dirname $output
git reset --hard origin
cd $thisdir

$ogrexec -f "$format" "$output" PG:"$pg_connection" -sql "$pg_sql" $ogr_options

