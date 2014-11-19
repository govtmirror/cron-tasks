#!/bin/bash
rootdir=`pwd`
cd "/home/npmap/dev/cron-tasks/places"
format="geojson"
output="/home/npmap/dev/data/places/points_of_interest.geojson"
sqlFile="get_nodes.sql"
commitMessage="Updating the points_of_interest.geojson for `date "+%Y%m%d"`"

/bin/bash ./export.sh -f "$format" -o "$output" -s "$sqlFile" && /bin/bash git_commit_file "$output"
cd $rootdir
