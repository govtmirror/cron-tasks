script_dir=`pwd`

new_filename="$1"
commit_msg="$2"
new_dirname=`dirname "$new_filename"`
new_basename=`basename "$new_filename"`

if [ -z "$commit_msg" ]; then
  commit_msg="Updating $new_basename"
fi

cd $new_dirname
git add "$new_basename" && git commit -m "$commit_msg" && git pull --ff-only && git push

cd `pwd`
