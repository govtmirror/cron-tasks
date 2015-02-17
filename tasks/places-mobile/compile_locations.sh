script_dir=`pwd`

# Generate the sites
site_generation_directory=/home/npmap/dev/website/tools/places/mobile/aggregate/aggregation/
site_generation_script=generate_sites.sh
git_commit_script=git_commit_changes.sh
cd $site_generation_directory
/bin/bash $site_generation_script $1 > /dev/null

# Commit the changes to github
bash $git_commit_script

cd $script_dir 
