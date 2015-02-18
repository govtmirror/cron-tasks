#!/bin/bash
rootdir=`pwd`
todays_date=`date "+%Y%m%d%H%M%S"`
format="geojson"
output="/home/npmap/dev/data/places/points_of_interest.geojson"
output_temp="/home/npmap/dev/data/places/points_of_interest_"$todays_date".geojson"
sqlFile="get_nodes.sql"
commitMessage="Updating the points_of_interest.geojson for $todays_date"
git_rsa_key=/home/npmap/.ssh/npmap-bot/id_rsa

eval $(ssh-agent) > /dev/null && ssh-add $git_rsa_key
# Do a git fetch for the repo where we're writing
cd `dirname $output`
git reset --hard origin && git pull
cd "/home/npmap/dev/cron-tasks/tasks/places-backup"

/bin/bash ./export.sh -f "$format" -o "$output_temp" -s "$sqlFile" && rm $output && mv $output_temp $output && /bin/bash ./git_commit_file.sh "$output" "$commitMessage"

# Remove the file in cases where something crashes
if [ -f $output_temp ]; then
  rm $output_temp
fi

cd $rootdir
