script_dir=`pwd`

# Generate the sites
site_generation_directory=/home/npmap/dev/website/places-mobile/aggregation/
site_generation_script=generate_sites.sh
git_commit_script=git_commit_changes.sh
cd $site_generation_directory
bash $site_generation_script

# Commit the changes to github
bash $git_commit_script

cd $script_dir 
