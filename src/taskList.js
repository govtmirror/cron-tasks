var Handlebars = require('handlebars');
module.exports = function(params) {

  var handlebars = function(str) {
    return typeof str === 'string' ? Handlebars.compile(str)(params) : str;
  };

  return [{
    'enabled': false,
    'interval': '* * * * * *',
    'name': 'Test DB task',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/test/db_test.sh'),
    }
  }, {
    'enabled': true,
    'interval': '0 30 1 * * *', // 1:30 am
    'name': 'Places_SQL_Dump',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places/sql_dump.sh'),
    }
  }, {
    'enabled': true,
    'interval': '0 15 * * * *', // On the 15 of every hour
    'name': 'Places_POI_update',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places/update_geojson.sh'),
    }
  }, {
    'enabled': true,
    'interval': '0 30 * * * *', // On the 30 of every hour
    'name': 'Places_Mobile_Data_Only',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh'),
    }
  }, {
    'enabled': true,
    'interval': '0 45 */12 * * *', // Every 12 hours on the 45
    'name': 'Places_Mobile_Images',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places-mobile/compile_locations.sh true'),
    }
  }];
};
