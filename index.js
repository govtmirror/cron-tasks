var CronJob = require('cron').CronJob;
var taskList = require('./taskList');
var mkdirp = require('mkdirp');

var exec = require('child_process').exec;
var taskTree = {
  'script': function(path, callback) {
    exec(path, callback);
  },
  'node': function(func, callback) {
    func(callback);
  }
};


var params = {
  'tasksDir': __dirname + '/tasks'
};
var appendLog = function(entry, callback) {
  var filename = __dirname + '/logs/' + entry.job.name + '/log.json'; //TODO: better file name!
  mkdirp(__dirname + '/logs/' + entry.job.name, function() {
    console.log('/bin/echo ' + JSON.stringify(entry) + ' >> "' + filename + '"');
    exec('/bin/echo ' + JSON.stringify(entry) + ' >> "' + filename + '"', callback);
  });
};


var taskReporter = function(task, startTime, callback) {
  return function(error, stdout, stderr) {
    var report = {
      'elapsedTime': process.hrtime(startTime)[0] + (process.hrtime(startTime)[1] / 1000000000),
      'error': error,
      'stdout': stdout,
      'stderr': stderr
    };
    callback(report);
  };
};

var addTasks = function(task) {
  var job;
  try {
    job = new CronJob({
      cronTime: task.interval,
      onTick: function(onComplete) {
        var startTime = process.hrtime();
        console.log('Running task:', task.name);
        if (taskTree[task.task.type]) {
          taskTree[task.task.type](task.task.path, taskReporter(task, startTime, onComplete));
        } else {
          console.log('Invalid Type');
        }
      },
      onComplete: function(report) {
        console.log('Task complete:', task.name, 'after:', report.elapsedTime, 'seconds');
        var log = {
          'job': {
            name: task.name,
            interval: task.interval
          },
          'output': report.stdout,
          'error': report.stderr || report.error,
          'elapsedTime': report.elapsedTime,
          'startTime': new Date(new Date() - report.elapsedTime).toUTCString(),
          'endTime': new Date().toUTCString()
        };
        appendLog(log, function(e, so, se) {
          console.log(e, so, se);
        });
      },
      start: false,
      timeZome: 'America/Denver'
    });
  } catch (ex) {
    job = null;
  }
  return job;
};

var tasks = taskList(params);
var taskReport = '' + new Date() + '\n--------------------------------------------\n';
for (var i in tasks) {
  tasks[i].job = addTasks(tasks[i]);
  if (tasks[i].enabled) {
    if (tasks[i].job) {
      console.log('starting job', tasks[i].name, tasks[i].interval);
      taskReport += 'Starting job: ' + tasks[i].name + ' (' + tasks[i].interval + ')\n';
      tasks[i].job.start();
    } else {
      console.log('invalid job', tasks[i].name);
    }
  }
}
exec('/bin/echo "' + taskReport + '" >> "' + __dirname + '/logs/service.log' + '"', function(){return null;});
