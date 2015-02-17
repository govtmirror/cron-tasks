script_dir=`pwd`

# Generate the sit
data_directory=/home/npmap/dev/data/places_mobile
git_commit_script=git_commit_changes.sh
site_generation_directory=/home/npmap/dev/website/tools/places/mobile/aggregate/aggregation/
site_generation_script=generate_sites.sh
cd $site_generation_directory
/bin/bash $site_generation_script $1 > /dev/null

# Commit the changes to github
bash $git_commit_script $data_directory

cd $script_dir
