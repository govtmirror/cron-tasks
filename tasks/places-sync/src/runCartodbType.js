var btoa = require('btoa'),
  config = require('../config'),
  datawrap = require('datawrap'),
  fs = require('fs'),
  runScript = require('./queryRunner'),
  slack = new require('node-slack-web-api')(config.slack),
  sqlFiles = require('../sqlScripts');

module.exports = function(type) {
  var params = {
    'taskName': type + '_' + config.taskName,
    'npsTaskType': type
  };

  return new datawrap.Bluebird(function(mainResolve, mainReject) {
    var reject = function(e) {
      if (params.renderId) {
        runScript.database(sqlFiles.revertTask, params)
          .then(function(){mainReject(e);})
          .catch(function(newE){mainReject(newE);});
      } else {
        mainReject(e);
      }
    };
    var resolve = function(message) {
      if (params.renderId) {
        runScript.database(sqlFiles.completeTask, params)
          .then(function(){mainResolve(message);})
          .catch(function(e){reject(e);});
      } else {
        reject('No renderId Found');
      }
    };
    runScript.database(sqlFiles.checkTask, params)
      .then(function(canRun) {
    runScript.database(sqlFiles.writeStartTime, params)
      .then(function(taskInfo) {
        if (taskInfo[0] && taskInfo[0].rows[0]) {
          params.renderId = taskInfo[0].rows[0].render_id;
          params.runTime = taskInfo[0].rows[0].run_time;
        }
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
                  datawrap.runList(cartoDbDeletes, 'runCartodbType Deletes')
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
                      datawrap.runList(insertList, 'runCartodbType Inserts')
                        .then(function() {
                          // Post Sync Transactions
                          var postSyncTasks = fs.readdirSync(__dirname + '/../sql/cartodb/' + type).indexOf('views') > -1,
                            viewList = [];
                          if (postSyncTasks) {
                            fs.readdirSync(__dirname + '/../sql/cartodb/' + type + '/views/').map(function(fileName) {
                              //console.log('********************************************************');
                              //console.log(fileName);
                              //console.log('********************************************************');
                              viewList.push({
                                'name': 'View: ' + fileName,
                                'task': runScript.server,
                                'params': ['file:///cartodb/' + type + '/views/' + fileName, {}]
                              });
                            });
                          }
                          if (insertList.length > 0) {
                            var linkUrl = 'https://' + config.database.cartodb.account;
                            linkUrl += '.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20';
                            linkUrl += type === 'point' ? 'points_of_interest' : type === 'line' ? 'places_lines' : 'places_polygons';
                            linkUrl += '%20where%20cartodb_id%20=%20ANY%20(';
                            linkUrl += params.cartoDbChanges;
                            linkUrl += ');&api_key=' + config.database.cartodb.apiKey;
                            linkUrl += '&format=geojson';
                            slack('Places: Updated ' + insertList.length + ' ' + type + (insertList.length > 1 ? 's' : '') + ' in CartoDB <http://www.nps.gov/maps/full.html?mapId=daafb8e5-280a-4914-b3f5-7d160a453f9a&url=' + btoa(linkUrl) + '|View GeoJSON>');
                          }
                          if (viewList.length > 0) {
                            datawrap.runList(viewList, 'runCartodbType Views')
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
      }).catch(function(e) {
        reject(e);
      });
  });
};
