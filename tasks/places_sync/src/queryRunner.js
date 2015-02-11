var Bluebird = require('bluebird'),
  config = require('../config'),
  database = require('datawrap')(config.database.poi_pgs, config.database.defaults),
  fandlebars = require('fandlebars'),
  fs = require('fs'),
  requestPost = Bluebird.promisify(require('request').post),
  runList = require('./runList');

module.exports = {
  database: function(file, params) {
    return new Bluebird(function(resolve, reject) {
      database.runQuery('file:///' + fandlebars(file, params), params, function(e, r) {
        if (e) {
          reject(e);
        } else {
          resolve(r);
        }
      });
    });
  },
  server: function(sql, params) {
    return new Bluebird(function(resolve, reject) {
      var queries = [];

      if (!Array.isArray(sql)) {
        sql = [sql];
      }
      sql.map(function(query) {
        var queryText;
        console.log('Running CartoDB Query:', query);
        if (query.substr(0, 7) === 'file://') {
          queryText = fs.readFileSync(__dirname + '/../sql' + fandlebars(query.substr(7), params), 'utf8');
          queryText.split(';').map(function(q) {
            if (q.length > 2) {
              queries.push(q + ';');
            }
          });
        } else {
          queries.push(query);
        }
      });

      var runQuery = function(query) {
        return new Bluebird(function(queryResolve, queryReject) {
          var cleanedSql = fandlebars(query, params).replace(/\'null\'/g, 'null'),
            requestPath = 'https://' + config.cartodb.account + '.cartodb.com/api/v2/sql';
          if (cleanedSql.length > 5) {
            console.log('Requesting', requestPath, '(' + cleanedSql + ')');
            requestPost({
              'url': requestPath,
              'form': {
                'q': cleanedSql,
                'api_key': config.cartodb.apiKey
              }
            }).then(function(r) {
              console.log('CartoDB Command Complete', cleanedSql);
              queryResolve(r);
            }).catch(function(e) {
              queryReject(e);
            });
          } else {
            queryReject('Query Too Short');
          }
        });
      };

      var taskList = [];
      queries.map(function(query) {
        taskList.push({
          'task': runQuery,
          'params': query
        });

        runList(taskList)
          .then(function(r) {
            resolve(r);
          })
          .catch(reject);
      });
    });
  }
};
