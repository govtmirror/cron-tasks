var Bluebird = require('bluebird'),
  config = require('../config'),
  fs = require('fs'),
  runScript = require('./queryRunner'),
  runList = require('../node_modules/datawrap/src/runList'),
  slack = new require('node-slack-web-api')(config.slack),
  sqlFiles = require('../sqlScripts');

module.exports = function(type) {
  var params = {
    'taskName': type + '_' + config.taskName,
    'npsTaskType': type
  };

  return new Bluebird(function(resolve, reject) {
    runScript.database(sqlFiles.writeStartTime, params)
      .then(function() {
        runScript.database(sqlFiles.cartodb.getChangeList, params)
          .then(function(result) {
            var resultIds;
            if (result && result[1] && result[1].rows && result[1].rows[0] && result[1].rows[0].ids) {
              resultIds = result[1].rows[0].ids;
              // console.log('Updating ' + type + '!');
              // console.log('New ID', resultIds);
              params.changes = '{' + resultIds.join(',') + '}';
              params.cartoDbChanges = 'ARRAY[' + resultIds.join(',') + ']';
              runScript.database(sqlFiles.cartodb.getNewData, params)
                .then(function(listOfUpdates) {
                  var cartoDbDelete = {},
                    cartoDbDeletes = [],
                    i,
                    numberOfDeletes = 500,
                    paramPart = {};
                  params.newData = listOfUpdates[0].rows;
                  // CartoDB doesn't like a long delete list, so we split up the list
                  for (i = 0; i < resultIds.length; i += numberOfDeletes) {
                    // console.log('Change #', i, '-', i + numberOfDeletes);
                    paramPart = {
                      'cartoDbChanges': 'ARRAY[' + resultIds.slice(i, i + (numberOfDeletes)) + ']',
                      'npsTaskType': type
                    };
                    cartoDbDelete = {
                      'name': 'remove_' + i,
                      'task': runScript.server,
                      'params': ['file://' + sqlFiles.cartodb.remove, paramPart]
                    };
                    cartoDbDeletes.push(cartoDbDelete);
                  }
                  runList(cartoDbDeletes, 'runCartodbType Deletes')
                    .then(function() {
                      var insertList = [];
                      params.newData.map(function(row) {
                        row.npsTaskType = type;
                        insertList.push({
                          'name': 'insert_' + insertList.length,
                          'task': runScript.server,
                          'params': ['file://' + sqlFiles.cartodb.insert, row]
                        });
                      });
                      runList(insertList, 'runCartodbType Inserts')
                        .then(function() {
                          // Post Sync Transactions
                          var postSyncTasks = fs.readdirSync(__dirname + '/../sql/cartodb/' + type).indexOf('views') > -1,
                            viewList = [];
                          if (postSyncTasks) {
                            fs.readdirSync(__dirname + '/../sql/cartodb/' + type + '/views/').map(function(fileName) {
                              // console.log('********************************************************');
                              // console.log(fileName);
                              // console.log('********************************************************');
                              viewList.push({
                                'name': 'View: ' + fileName,
                                'task': runScript.server,
                                'params': ['file:///cartodb/' + type + '/views/' + fileName, {}]
                              });
                            });
                          }
                          if (insertList.length > 0) {
                            slack('Places: Updated ' + insertList.length + ' ' + type + (insertList.length > 1 ? 's' : '') + ' in CartoDB');
                          }
                          if (viewList.length > 0) {
                            runList(viewList, 'runCartodbType Views')
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
