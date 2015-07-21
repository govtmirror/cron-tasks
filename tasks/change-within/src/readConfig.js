var configFile = require('../config'),
  datawrap = require('datawrap'),
  fs = require('fs'),
  rep = {
    env: process.env,
    secrets: function(input) {
      return JSON.parse(fs.readFileSync(process.env.PWD + '/secrets/' + input[0] + '.json', 'utf8'));
    }
  };

module.exports = function(config) {
  config = config || configFile;
  return datawrap.fandlebars.obj(configFile, rep);
};
