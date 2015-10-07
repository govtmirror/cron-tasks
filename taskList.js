var Handlebars = require('handlebars');
module.exports = function(params) {

  var handlebars = function(str) {
    return typeof str === 'string' ? Handlebars.compile(str)(params) : str;
  };

  return [{
    'description': 'Test task to make sure everything is working, usually disabled',
    'enabled': false,
    'interval': '* * * * * *',
    'name': 'Test DB task',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/test/db_test.sh'),
    }
  }, {
    'description': 'Nightly backup of the Places database',
    'enabled': true,
    'interval': '0 30 1 * * *', // 1:30 am
    'name': 'Places_SQL_Dump',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-backup/sql_dump.sh'),
    }
  }, {
    'description': 'Updates the GeoJSON file on github',
    'enabled': false,
    'interval': '0 20 * * * *', // On the 20 of every hour
    'name': 'Places_POI_update',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-backup/update_geojson.sh'),
    }
  }, {
    'description': 'Compile json files without images for Places Mobile',
    'comment': 'This runs much quicker than the version with images',
    'enabled': false,
    'interval': '0 */25 * * * *', // Every 25 minutes
    'name': 'Places_Mobile_Without_Images',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh 0'),
    }
  }, {
    'description': 'Compile json files and images for Places Mobile',
    'comment': 'This requires going out to mapbox and checking off the the map thumbnails, so it takes longer',
    'enabled': false,
    'interval': '0 45 */3 * * *', // Every 3 hours on the 45
    'name': 'Places_Mobile_Images',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh map_thumbnail'),
    }
  }, {
    'description': 'Syncs the places points, polygons, and lines with CartoDB',
    'enabled': true,
    'interval': '0 */5 * * * *', // Every 5 minutes
    'name': 'CartoDB_Render',
    'task': {
      'type': 'script',
      'path': handlebars('/usr/bin/node /home/npmap/dev/cron-tasks/tasks/places-sync/index.js'),
    }
  }, {
    'description': 'Syncs the places points with Mapbox (nps.places_poi)',
    'enabled': false,
    'interval': '0 15 * * * *', // Every 1 hour on the 15
    'name': 'POI Tile Sync POI',
    'task': {
      'type': 'script',
      'path': '/bin/bash /home/npmap/dev/cron-tasks/tasks/mbtiles-sync/run-mbstudio.sh nps_park_pois',
    }
  }, {
    'description': 'Syncs all of the places data with Mapbox (nps.nps-places-data)',
    'enabled': false,
    'interval': '0 45 * * * *', // Every 1 hour on the 45
    'name': 'POI Tile Sync Data',
    'task': {
      'type': 'script',
      'path': '/bin/bash /home/npmap/dev/cron-tasks/tasks/mbtiles-sync/run-mbstudio.sh nps_places_data',
    }
  }];
};
