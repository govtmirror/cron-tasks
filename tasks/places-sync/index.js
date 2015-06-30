var runList = require('datawrap').runList,
  taskList = [{
    'name': 'CartoDB Tasks',
    'task': require('./src/runCartodb.js'),
    'params': [
      ['point', 'polygon', 'line']
    ]
  }];

runList(taskList, 'index.js')
  .then(function(r) {
    console.log('DONE', JSON.stringify(r, null, 1));
  })
  .catch(function(e) {
    throw e;
  });
