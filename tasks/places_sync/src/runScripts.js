var Bluebird = require('bluebird'),
  config = require('../config'),
  database = require('datawrap')(config.database.poi_pgs, config.database.defaults),
  fandlebars = require('fandlebars'),
  fs = require('fs'),
  request = Bluebird.promisify(require('request'));

module.exports = {
  database: function(file, params) {
    return new Bluebird(function(resolve, reject) {
      database.runQuery('file:///' + file, params, function(e, r) {
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
          queryText = fs.readFileSync(__dirname + '/../sql' + query.substr(7), 'utf8');
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
            requestPath = 'https://' + config.cartodb.account + '.cartodb.com/api/v2/sql?q=';
          requestPath += encodeURIComponent(cleanedSql);
          requestPath += '&api_key=' + config.cartodb.apiKey;
          if (cleanedSql.length > 5) {
            request(requestPath).then(function(r) {
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

      /*Bluebird.all(queries.map(runQuery)).then(function(r) {
        resolve(r);
      }).catch(function(e) {
        reject(new Error(e));
      });*/

      var runOrderedList = function(list) {
        return new Bluebird(function(listResolve, listReject) {
          var exec = function(subList, callback) {
            var nextList = [];
            runQuery(subList[0]).then(function() {
              nextList = subList.slice(1);
              if (nextList.length > 0) {
                exec(nextList, callback);
              } else {
                callback();
              }
            }).catch(function(e) {
              callback(e);
            });
          };
          exec(list, function(e) {
            if (e) {
              listReject(e);
            } else {
              listResolve();
            }
          });
        });
      };

      runOrderedList(queries)
        .then(function() {
          console.log('DONE');
          resolve();
        })
        .catch(reject);
    });
  }
};
