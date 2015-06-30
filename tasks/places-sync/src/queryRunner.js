var config = require('../config'),
  datawrap = require('datawrap');

var cartodb = datawrap(config.database.cartodb, config.database.defaults),
  postgresql = datawrap(config.database.poi_pgs, config.database.defaults);

module.exports = {
  database: function(file, params) {
    return new datawrap.Bluebird(function(resolve, reject) {
      postgresql.runQuery('file:///' + datawrap.fandlebars(file, params), params, function(e, r) {
        if (e) {
          reject(e);
        } else {
          resolve(r);
        }
      });
    });
  },
  server: function(sql, params) {
    return new datawrap.Bluebird(function(resolve, reject) {
      cartodb.runQuery(sql, params, function(e, r) {
        if (e) {
          reject(e);
        } else {
          resolve(r);
        }
      });
    });
  }
};
