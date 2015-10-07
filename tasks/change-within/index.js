var config = require('./src/readConfig')();

console.log(config);

// Read the email addresses file
var file = require('./emailList');
var readAddresses = function (addresses) {
  var addressList = addresses.map(function (address) {
    var returnValue = {};
    if (address.email) {
      returnValue.email = address.email;
      if (address.parks) {
        returnValue.parks = address.parks;
      } else {
        returnValue.parks = [];
      }
      if (address.park) {
        returnValue.parks.push(address.park);
      }
    }
    return returnValue;
  });
  return addressList;
};

console.log(readAddresses(file));
