var Bluebird = require('bluebird'),
  config = require('../config'),
  cartodb = require('datawrap')(config.database.cartodb, config.database.defaults),
  fandlebars = require('fandlebars'),
  postgresql = require('datawrap')(config.database.poi_pgs, config.database.defaults);

module.exports = {
  database: function(file, params) {
    return new Bluebird(function(resolve, reject) {
      postgresql.runQuery('file:///' + fandlebars(file, params), params, function(e, r) {
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
