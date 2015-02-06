var run = require('./src/runType');

run('point').then(function(pointMsg) {
  console.log(pointMsg);
  run('polygon').then(function(polygonMsg) {
    console.log(polygonMsg);
    run('line').then(function(lineMsg) {
      console.log(lineMsg);
      process.exit();
    }).catch(function(e) {
      throw new Error(e);
    });
  }).catch(function(e) {
    throw new Error(e);
  });
}).catch(function(e) {
  throw new Error(e);
});
