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
    'interval': '0 */5 * * * *',
    'name': 'Places_SQL_Dump',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places/sql_dump.sh'),
    }
  }];
};
