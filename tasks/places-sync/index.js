// Work around for https
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

var runList = require('datawrap').runList,
  taskList = [{
    'name': 'CartoDB Tasks',
    'task': require('./src/runCartodb.js'),
    'params': [
      // ['newPoint']
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
