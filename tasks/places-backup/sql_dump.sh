this_pg_dump=/usr/lib/postgresql/9.4/bin/pg_dump
output_dir="/home/npmap/dev/backups/"
api_filename="api_bk_`date "+%Y%m%d"`.tar"
pgs_filename="poi_bk_`date "+%Y%m%d"`.tar"

# TODO: These are just tar files, it'd be nice to use an order/uncompressed dump and compress only the deltas
# We can also keep a single current one and put it on a server somewhere
$this_pg_dump -Fc -U postgres -h 10.147.153.193 places_api > $output_dir$api_filename
$this_pg_dump -Fc -U postgres -h 10.147.153.193 places_pgs > $output_dir$pgs_filename
