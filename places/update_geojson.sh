#!/bin/bash
rootdir=`pwd`
todays_date=`date "+%Y%m%d"`
cd "/home/npmap/dev/cron-tasks/places"
format="geojson"
output="/home/npmap/dev/data/places/points_of_interest.geojson"
output_temp="/home/npmap/dev/data/places/points_of_interest_"$todays_date".geojson"
sqlFile="get_nodes.sql"
commitMessage="Updating the points_of_interest.geojson for $todays_date"

/bin/bash ./export.sh -f "$format" -o "$output_temp" -s "$sqlFile" && rm $output && mv $output_temp $output && /bin/bash git_commit_file "$output"
cd $rootdir
