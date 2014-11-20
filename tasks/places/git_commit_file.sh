script_dir=`pwd`

new_filename="$1"
commit_msg="$2"

new_dirname=`dirname "$new_filename"`
new_basename=`basename "$new_filename"`

# Assign a default message if there is none
if [ -z "$commit_msg" ]; then
  commit_msg="Updating $new_basename"
fi


#assign an ssh key
eval $(ssh-agent) > /dev/null
ssh-add /home/npmap/.ssh/npmap-bot/id_rsa

# Put these all after a "&&" to make sure they only run if there is no error
# If you want to avoid doing a merge somewhere, do a "git reset --hard origin" before adding your new/updated files
cd $new_dirname
git add "$new_basename" && git commit -m "$commit_msg" && git pull --ff-only && git push

cd $script_dir
