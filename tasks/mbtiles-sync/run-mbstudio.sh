echo $1 # nps_places_poi OR nps_places_data

CURL_URL="http://10.147.153.191:3000/upload?id=tmsource:///home/jmcandrew/dev/park-tiles-internal/park_tiles/park_tiles_data_process/tm2_data_queries/"$1".tm2source"

/usr/bin/curl $CURL_URL


