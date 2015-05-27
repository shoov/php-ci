#!/usr/bin/env node

var Promise = require("bluebird");
var yaml = require('js-yaml');
var fs = Promise.promisifyAll(require("fs"));

var crypto = require('crypto');
var algorithm = 'aes-256-ctr';
var password = 'd6F3Efeq';

function encrypt(text){
  var cipher = crypto.createCipher(algorithm,password)
  var crypted = cipher.update(text,'utf8','hex')
  crypted += cipher.final('hex');
  return crypted;
}

function decrypt(text){
  var decipher = crypto.createDecipher(algorithm,password)
  var dec = decipher.update(text,'hex','utf8')
  dec += decipher.final('utf8');
  return dec;
}

fs.readFileAsync('/home/shoov/build/.shoov.yml')
  .then(function (data) {
    return yaml.safeLoad(data);
  })
  .then(function (data) {
    var variables = [];

    data.env.forEach(function(row) {
      var keyName = Object.keys(row)[0];
      var variableValue;

      if (keyName == 'secure') {
        var decryptArr = decrypt(row[keyName]).split(':');

        if (decryptArr.length != 2) {
          throw new Error('Wrong secure key.');
        }

        keyName = decryptArr[0];
        variableValue = decryptArr[1];
      }
      else {
        var variableValue = row[keyName];
      }

      // Export value as a bash variable.
      variables.push('export ' + keyName + '=' + variableValue);
    });

    return variables.join('\n');
  })
  .then(function(data) {
    return fs.writeFileAsync('/home/shoov/build/export.sh', data);
  })
  .catch(function(err) {
    console.log(err);
  });
