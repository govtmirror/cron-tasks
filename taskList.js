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
    'description': 'Nightly backup of the CartoDB Tables',
    'enabled': true,
    'interval': '0 05 2 * * *', // 2:05 am
    'name': 'CartoDB_Backup_Dump',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/cartodb-backup/download.sh')
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
  }, {
    'description': 'Nightly Cleanup of the places tables',
    'enabled': true,
    'interval': '0 10 0 * * *', // 12:10 am
    'name': 'Nightly Cleanup',
    'task': {
      'type': 'script',
      'path': handlebars('/usr/bin/node {{tasksDir}}/places-cleanup/index.js')
    }
  }];
};
