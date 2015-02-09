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
      'path': handlebars('/bin/bash {{tasksDir}}/places/sql_dump.sh'),
    }
  }, {
    'description': 'Updates the GeoJSON file on github',
    'enabled': true,
    'interval': '0 20 * * * *', // On the 20 of every hour
    'name': 'Places_POI_update',
    'task': {
      'type': 'script',
      'path': handlebars('eval "$(ssh-agent -s)" && ssh-add /home/npmap/.ssh/npmap-bot/id_rsa && /bin/bash {{tasksDir}}/places/update_geojson.sh'),
    }
  }, {
    'description': 'Compile json files without images for Places Mobile',
    'comment': 'This runs much quicker than the version with images',
    'enabled': true,
    'interval': '0 */25 * * * *', // Every 25 minutes
    'name': 'Places_Mobile_Without_Images',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh false'),
    }
  }, {
    'description': 'Compile json files and images for Places Mobile',
    'comment': 'This requires going out to mapbox and checking off the the map thumbnails, so it takes longer',
    'enabled': true,
    'interval': '0 45 */4 * * *', // Every 2 hours on the 45
    'name': 'Places_Mobile_Images',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh true'),
    }
  }, {
    'description': 'Syncs the places points, polygons, and lines with CartoDB',
    'enabled': true,
    'interval': '0 */15 * * * *', // Every 15 minutes
    'name': 'CartoDB_Render',
    'task': {
      'type': 'script',
      'path': handlebars('/usr/bin/node /home/npmap/dev/cron-tasks/tasks/places_sync/index.js'),
    }
  }];
};
