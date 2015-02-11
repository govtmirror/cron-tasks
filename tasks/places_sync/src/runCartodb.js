var Bluebird = require('bluebird'),
  run = require('./runCartodbType'),
  runList = require('./runList');

module.exports = function(types) {
  var taskList = [];
  types.map(function(type) {
    taskList.push({
      'name': 'CartoDB ' + type + ' task',
      'task': run,
      'params': type
    });
  });
  return new Bluebird(function(resolve, reject) {
    runList(taskList)
      .then(resolve)
      .catch(reject);
  });
};
