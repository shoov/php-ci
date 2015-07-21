#!/usr/bin/env bash

BUILD_ID=$1
ACCESS_TOKEN=$2

BUILD_INFO=$(node ~/build_info.js $BUILD_ID $ACCESS_TOKEN)

# Get the values from the JSON and trim the qoute (") signs.
OWNER=$(echo $BUILD_INFO | jq '.owner' | cut -d '"' -f 2)
REPO=$(echo $BUILD_INFO | jq '.repo' | cut -d '"' -f 2)
BRANCH=$(echo $BUILD_INFO | jq '.branch' | cut -d '"' -f 2)
PRIVATE_KEY=$(echo $BUILD_INFO | jq '.private_key' | cut -d '"' -f 2)
GITHUB_ACCESS_TOKEN=$(echo $BUILD_INFO | jq '.github_access_token' | cut -d '"' -f 2)

{
  # Get .shoov.json
  curl -s -o ~/.shoov.json $BACKEND_URL/api/v1.0/config?access_token=$ACCESS_TOKEN

  # Get GitHub access token
  cd ~/build

  # Clone repo
  git clone --branch=$BRANCH --depth=1 --quiet https://$GITHUB_ACCESS_TOKEN@github.com/$OWNER/$REPO.git .

  # Export variables.
  touch ~/build/export.sh
  node ~/export-vars.js $PRIVATE_KEY
  source ~/build/export.sh

  # Parse .shoov.yml file
  node ~/parse.js

  # Execute the parsed .shoov.yml file

# Hide output.
} &> /dev/null

# Pipe content to html
sh -c ~/shoov.sh | ~/ansi2html.sh
