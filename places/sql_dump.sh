this_pg_dump=`which pg_dump`
output_dir="/home/npmap/dev/backups/"
api_filename="api_bk_`date "+%Y%m%d"`.tar"
pgs_filename="poi_bk_`date "+%Y%m%d"`.tar"

# TODO: These are just tar files, it'd be nice to use an order/uncompressed dump and compress only the deltas
$this_pg_dump -Fc -U osm -h inpniscvplaces1 poi_api > $output_dir$api_filename
$this_pg_dump -Fc -U osm -h inpniscvplaces1 poi_pgs > $output_dir$pgs_filename
