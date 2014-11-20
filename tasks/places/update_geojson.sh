#!/bin/bash
rootdir=`pwd`
todays_date=`date "+%Y%m%d"`
cd "/home/npmap/dev/cron-tasks/places"
format="geojson"
output="/home/npmap/dev/data/places/points_of_interest.geojson"
output_temp="/home/npmap/dev/data/places/points_of_interest_"$todays_date".geojson"
sqlFile="get_nodes.sql"
commitMessage="Updating the points_of_interest.geojson for $todays_date"

# Do a git fetch for the repo where we're writing
cd `dirname $output`
git reset --hard origin
cd $rootdir

#/bin/bash $rootdir/export.sh -f "$format" -o "$output_temp" -s "$sqlFile" && rm $output && mv $output_temp $output && /bin/bash $rootdir/git_commit_file.sh "$output" "$commitMessage"
cd $rootdir
