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
          if (params.singleTransaction) {
            queries.push(queryText);
          } else {
            queryText.split(';').map(function(q) {
              queries.push(q + ';');
            });
          }
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
          request(requestPath).then(function(r) {
            console.log('CartoDB Command Complete', cleanedSql);
            queryResolve(r);
          }).catch(function(e) {
            queryReject(new Error(e));
          });
        });
      };

      Bluebird.all(queries.map(runQuery)).then(function(r) {
        resolve(r);
      }).catch(function(e) {
        reject(new Error(e));
      });

    });
  }
};
