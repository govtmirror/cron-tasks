var runList = require('./src/runList'),
  taskList = [{
    'name': 'CartoDB Tasks',
    'task': require('./src/runCartodb.js'),
    'params': [['point', 'polygon', 'line']]
  }];

runList(taskList)
  .then(function(r) {
    console.log('DONNNE', r);
  })
  .catch(function(e) {
    throw e;
  });

