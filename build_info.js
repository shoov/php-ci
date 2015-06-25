var Promise = require('bluebird');
var rp = require('request-promise');

var arguments = process.argv.slice(2);


if (!arguments[0]) {
  throw new Error('Build ID not passed.');
}
else if (!arguments[1]) {
  throw new Error('Access token not passed.');
}

var accessToken = arguments[1];

/**
 * Get Build data.
 *
 * @param buildId
 *   The build ID.
 *
 * @returns {*}
 */
var getBuild = function(buildId) {
  var backendUrl = process.env.BACKEND_URL;
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
  var backendUrl = process.env.BACKEND_URL;
  var options = {
    url: backendUrl + '/api/repositories/' + repoId,
    qs: {
      access_token: accessToken,
      fields: 'id,label'
    }
  };

  return rp.get(options);
};

var output = {};

getBuild(arguments[0])
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
