var Bluebird = require('bluebird');

module.exports = function(list) {
  var messages = {};
  return new Bluebird(function(listResolve, listReject) {
    var exec = function(sublist, callback) {
      console.log('running', sublist[0].name);
      var nextList = [];
      sublist[0].task.apply(sublist[0].context, Array.isArray(sublist[0].params) ? sublist[0].params : [sublist[0].params])
        .then(function(msg) {
          messages[sublist[0].name] = msg;
          nextList = sublist.slice(1);
          if (nextList.length > 0) {
            exec(nextList, callback);
          } else {
            callback(null, messages);
          }
        })
        .catch(function(e) {
          callback(e);
        });
    };

    exec(list, function(e, r) {
      if (e) {
        listReject(e);
      } else {
        listResolve(r);
      }
    });
  });
};
