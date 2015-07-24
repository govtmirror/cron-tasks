#!/bin/bash
CartoDB_file_type="csv"
CartoDB_account="nps"
CartoDB_api_key_file="./secrets/cartodb_api_key.txt"
CartoDB_table_list_file="./tables.txt"
CartoDB_destination="./backup"

# everything in {{ }} brackets MUST have an associated variable in the download.sh
CartoDB_downloadUrl="https://{{account}}.cartodb.com/api/v2/sql?filename={{file_name}}&q=SELECT+*+FROM+(select+*+from+{{table_name}})+as+subq+&format={{file_type}}&api_key={{api_key}}"
