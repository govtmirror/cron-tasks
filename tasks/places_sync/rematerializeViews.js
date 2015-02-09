var fs = require('fs');
var Bluebird = require('bluebird');
var runScript = require('./src/runScripts');

var rematerialize = function(type, idx) {
  return new Bluebird(function(resolve, reject) {
    // Post Sync Transactions
    var postSyncTasks = fs.readdirSync(__dirname + '/sql/views').indexOf(type) > -1,
      viewList = [],
      viewParams = {
        'transactionIndex': idx
      };
    if (postSyncTasks) {
      fs.readdirSync(__dirname + '/sql/views/' + type).map(function(fileName) {
        viewList.push(runScript.server('file:///views/' + type + '/' + fileName, viewParams));
      });
    }
    if (viewList.length > 0) {
      Bluebird.all(viewList).then(function() {
        resolve('Done with ' + type + 's and its ' + viewList.length + ' materialized view' + (viewList.length > 1 ? 's!' : '!'));
      }).catch(function(e) {
        reject(new Error(e));
      });
    } else {
      resolve('Done with ' + type + 's!');
    }
  });
};

var runAll = function() {
  var types = ['point', 'polygon', 'line'];
  Bluebird.all(types.map(function(t) {
    return rematerialize(t, 0);
  })).then(function() {
    Bluebird.all(types.map(function(t) {
      return rematerialize(t, 1);
    })).then(function() {
      process.exit(1);
    });
  });
};

runAll();
