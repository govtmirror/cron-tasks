var args = process.argv.slice(2),
  config = require('./config'),
  fandlebars = require('datawrap').fandlebars,
  slack = require('node-slack-web-api')(config.slack),
  tools = require('./src/tools');


var tasks = [
  // Create the list of tiles that need to be updated
  'getTiles',
  // Download the latest version of the tiles from the server
  'downloadMbtiles',
  // Read the mapbox-studio project to get the min/max Zooms, buffer size, and other params
  'readStudioFile',
  // Remove the tiles that have been updated from the mbtiles file (if we don't delete them there are sometimes errors with tileliveCopy)
  'removeTiles',
  // Generate (only) the new tiles into the mbtiles file using tileliveCopy
  'generateTiles',
  // Upload the tiles to mapbox
  'uploadMBtiles',
  // Complete task
  'completeTask'
];

var runNextTask = function(taskList, results, callback) {
  console.log('taskList', taskList);
  results = results ? results : {
    'config': fandlebars.obj(config, global.process),
    'settings': {
      'type': args[0] || 'places_points'
    }
  };
  if (taskList.length) {
    console.log('Running Task', taskList[0]);
    tools[taskList[0]](results)
      .then(function(res) {
        results[taskList[0]] = res;
        if (res && res.stop) {
          if (callback) callback(res.errors, results);
        } else {
          runNextTask(taskList.slice(1), results, callback);
        }
      })
      .catch(function(err) {
        console.log('******************* ERROR *******************');
        console.log(JSON.stringify(err, null, 2));
        if (callback) callback(err, results);
      });
  } else {
    if (callback) callback(results.errors, results);
  }
};

var finish = function(e, r) {
  var slackMessage = 'poi mbtiles-sync: ';
  if (e) {
    slackMessage += JSON.stringify(e);
  } else {
    if (r.getTiles && r.getTiles.error) {
      slackMessage += r.getTiles.error;
    } else if (r.getTiles && r.getTiles.result && r.getTiles.result.rows) {
      slackMessage += r.getTiles.result.rows.length + ' geometr' + (r.getTiles.result.rows.length === 1 ? 'y' : 'ies') + ' updated';
    } else {
      slackMessage += 'Unexpected Result';
    }
  }
  console.log(e, r);
  slack(slackMessage)
    .then(function() {
      process.exit(e ? 1 : 0);
    });
};

runNextTask(tasks, null, function(e, r) {
  if (e && !r.clearErrors) {
    tools.clearErrors(r)
      .then(function(ceR) {
        r.clearErrors = ceR;
        finish(e, r);
      })
      .catch(function(ceE) {
        r.clearErrors = ceE;
        finish(e, r);
      });
  } else {
    finish(e, r);
  }
});
