var Bluebird = require('bluebird'),
  config = require('../config'),
  fs = require('fs'),
  runScript = require('./queryRunner'),
  sqlFiles = require('../sqlScripts');

module.exports = function(type) {
  var params = {
    'taskName': type + '_' + config.taskName,
    'npsTaskType': type
  };

  return new Bluebird(function(resolve, reject) {
    runScript.database(sqlFiles.writeStartTime, params).then(function() {
      runScript.database(sqlFiles.cartodb.getChangeList, params).then(function(result) {
        var resultIds;
        if (result && result[0] && result[0].result && result[0].result.rows && result[0].result.rows[0] && result[0].result.rows[0].ids) {
          resultIds = result[0].result.rows[0].ids;
          console.log('Updating ' + type + '!');
          console.log('New ID', resultIds);
          params.changes = '{' + resultIds.join(',') + '}';
          params.cartoDbChanges = 'ARRAY[' + resultIds.join(',') + ']';
          runScript.database(sqlFiles.cartodb.getNewData, params).then(function(listOfUpdates) {
            var cartoDbDeletes = [],
              i,
              numberOfDeletes = 500,
              paramParts = [];
            params.newData = listOfUpdates[0].result.rows;
            // CartoDB doesn't like a long delete list, so we split up the list
            for (i = 0; i < resultIds.length; i += numberOfDeletes) {
              console.log('Change #', i, '-', i + numberOfDeletes);
              paramParts[i] = {
                'cartoDbChanges': 'ARRAY[' + resultIds.slice(i, i + (numberOfDeletes - 1)) + ']',
                'npsTaskType': type
              };
              cartoDbDeletes[i] = runScript.server('file://' + sqlFiles.cartodb.remove, paramParts[i]);
            }
            Bluebird.all(cartoDbDeletes).then(function() {
              var insertList = [];
              params.newData.map(function(row) {
                row.npsTaskType = type;
                insertList.push(
                  runScript.server('file://' + sqlFiles.cartodb.insert, row)
                );
              });
              Bluebird.all(insertList).then(function() {
                // Post Sync Transactions
                var postSyncTasks = fs.readdirSync(__dirname + '/../sql/cartodb/' + type).indexOf('views') > -1,
                  viewList = [];
                if (postSyncTasks) {
                  fs.readdirSync(__dirname + '/../sql/cartodb/' + type + '/views/').map(function(fileName) {
                    viewList.push(runScript.server('file:///cartodb/' + type + '/views/' + fileName, {}));
                  });
                }
                if (viewList.length > 0) {
                  Bluebird.all(viewList)
                    .then(function() {
                      resolve('Done with ' + type + 's and its ' + viewList.length + ' materialized view' + (viewList.length > 1 ? 's!' : '!'));
                    }).catch(function(e) {
                      reject(e);
                    });
                } else {
                  resolve('Done with ' + type + 's!');
                }
              }).catch(function(e) {
                reject(e);
              });
            }).catch(function(e) {
              reject(e);
            });
          }).catch(function(e) {
            reject(e);
          });
        } else {
          resolve('No ' + type + ' updates!');
        }
      }).catch(function(e) {
        reject(e);
      });
    }).catch(function(e) {
      reject(e);
    });
  });
};
