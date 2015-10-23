var Handlebars = require('handlebars');
module.exports = function (params) {
  var handlebars = function (str) {
    return typeof str === 'string' ? Handlebars.compile(str)(params) : str;
  };

  return [{
    'description': 'Test task to make sure everything is working, usually disabled',
    'enabled': false,
    'interval': '* * * * * *',
    'name': 'Test DB task',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/test/db_test.sh')
    }
  }, {
    'description': 'Nightly backup of the Places database',
    'enabled': true,
    'interval': '0 30 1 * * *', // 1:30 am
    'name': 'Places_SQL_Dump',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-backup/sql_dump.sh')
    }
  }, {
    'description': 'Updates the GeoJSON file on github',
    'enabled': false,
    'interval': '0 20 * * * *', // On the 20 of every hour
    'name': 'Places_POI_update',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-backup/update_geojson.sh')
    }
  }, {
    'description': 'Syncs the places points, polygons, and lines with CartoDB',
    'enabled': true,
    'interval': '0 * * * * *', // Every minute
    'name': 'CartoDB_Render',
    'task': {
      'type': 'script',
      'path': handlebars('/usr/bin/node {{tasksDir}}/places-sync/index.js')
    }
  }];
};
