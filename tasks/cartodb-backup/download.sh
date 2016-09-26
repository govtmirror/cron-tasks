#!/bin/bash
# CartoDB Download Tool
scriptDir="/home/npmap/dev/cron-tasks/tasks/cartodb-backup"
function downloadTables ()
{
  source $scriptDir"/settings.sh"
  local destination=$CartoDB_destination"_"$(date +'%Y%m%d')
  local file_type=$CartoDB_file_type
  # local tables=$(cat $CartoDB_table_list_file)
  local downloadUrl=$CartoDB_downloadUrl
  local api_key=""
  local account=""
  local file_name=""
  local table_name=""
  local CartoDB_api_key_file=$scriptDir$CartoDB_api_key_file


  function  downloadTable()
  {
    local newUrl=$downloadUrl
    local replaceable_fields=$(echo $newUrl | perl -pe "s/.+?\{\{(.+?)\}\}/\1 /g")
    local fieldVal=""
    for field in $replaceable_fields; do
      # Get the value of that variable using an indirect reference and urlencode it using perl
      fieldVal=$(perl -MURI::Escape -e "print uri_escape(\"${!field}\");")
      newUrl=${newUrl/\{\{$field\}\}/$fieldVal}
    done
    echo "Downloading Table: $table_name to $destination/$file_name"
    # echo $newUrl
    curl -L -o "$destination/$file_name" "$newUrl"
  }

  mkdir -p $destination
  while read line; do
    account=$(echo $line | perl -pe "s/^(.+?),\s{0,}(.+?)$/\1/g")
    table_name=$(echo $line | perl -pe "s/^(.+?),\s{0,}(.+?)$/\2/g")
    api_key=$(grep -r "^$account," "$CartoDB_api_key_file" | perl -pe "s/^(.+?),\s{0,}(.+?)$/\2/g")
    file_name=$account"."$table_name"."$file_type
    downloadTable
  done < "$scriptDir""$CartoDB_table_list_file"
  zip -r $destination".zip" $destination && rm -r $destination
  echo "Completed"
}
downloadTables
