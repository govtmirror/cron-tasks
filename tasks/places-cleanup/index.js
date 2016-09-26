var Databases = require('places-sync-databases');
var config = require('./config');
var db = new Databases({
  'type': 'postgresql',
  'connection': config.connection
});
var fs = require('fs');
var files = {
  elements: 'fix_missing_elements.sql',
  versions: 'fix_missing_versions.sql',
  tags: 'update_tags.sql'
};
var promises = [];

for (var file in files) {
  files[file] = fs.readFileSync('./sql/' + files[file], 'utf8');
  promises.push(db.query(files[file]));
}

Promise.all(promises).then(function(resp) {
  console.log('resp', resp);
}).catch(function(e) {
  throw e;
});
