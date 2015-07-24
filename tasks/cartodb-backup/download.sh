#!/bin/bash
# CartoDB Download Tool

function downloadTables ()
{
  source "./settings.sh"
  local api_key=$(cat $CartoDB_api_key_file)
  local destination=$CartoDB_destination
  local account=$CartoDB_account
  local file_type=$CartoDB_file_type
  local tables=$(cat $CartoDB_table_list_file)
  local downloadUrl=$CartoDB_downloadUrl


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
    curl -L -o "$destination/$file_name" "$newUrl"
  }

  # mkdir -p $destination
  for table_name in $tables; do
    file_name=$table_name"."$file_type
    downloadTable
  done
  echo "Completed"
}
downloadTables
