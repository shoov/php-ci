var Promise = require('bluebird');
var rp = require('request-promise');

var backendUrl = process.env.BACKEND_URL;

if (!backendUrl) {
  throw new Error('Backend url not passed.');
}

var args = process.argv.slice(2);
var buildId = args[0];
var accessToken = args[1];

if (!buildId) {
  throw new Error('Build ID not passed.');
}

if (!accessToken) {
  throw new Error('Access token not passed.');
}

/**
 * Get Build data.
 *
 * @param buildId
 *   The build ID.
 *
 * @returns {*}
 */
var getBuild = function(buildId) {
  var options = {
    url: backendUrl + '/api/ci-builds/' + buildId,
    qs: {
      access_token: accessToken,
      fields: 'id,git_branch,repository,private_key'
    }
  };

  return rp.get(options);
};

/**
 * Get Repository data.
 *
 * @param repoId
 *   The repository ID.
 *
 * @returns {*}
 */
var getRepository = function(repoId) {
  var options = {
    url: backendUrl + '/api/repositories/' + repoId,
    qs: {
      access_token: accessToken,
      fields: 'id,label',
      ssh_key: true
    }
  };

  return rp.get(options);
};

var output = {};

getBuild(buildId)
  .then(function(response) {
    // Build data.
    var data = JSON.parse(response).data[0];
    var repoId = data.repository;

    output.branch = data.git_branch;
    output.private_key = data.private_key;

    return getRepository(repoId);
  })
  .then(function(response) {
    // Repository data.
    var data = JSON.parse(response).data[0];

    var repoInfo = data.label.split('/');

    output.owner = repoInfo[0];
    output.repo = repoInfo[1];

    process.stdout.write(JSON.stringify(output));
  })
  .catch(function(err) {
    console.log(err);
  });
