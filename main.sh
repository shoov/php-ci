#!/bin/bash

BUILD_ID=$1
ACCESS_TOKEN=$2

BUILD_INFO=$(node ~/build_info.js $BUILD_ID $ACCESS_TOKEN)

# Get the values from the JSON and trim the qoute (") signs.
OWNER=$(echo $BUILD_INFO | jq '.owner' | cut -d '"' -f 2)
REPO=$(echo $BUILD_INFO | jq '.repo' | cut -d '"' -f 2)
BRANCH=$(echo $BUILD_INFO | jq '.branch' | cut -d '"' -f 2)
PRIVATE_KEY=$(echo $BUILD_INFO | jq '.private_key' | cut -d '"' -f 2)

# Setup hub
node ~/get_hub.js $ACCESS_TOKEN

# Clone repo
cd ~/build
git config --global hub.protocol https
hub clone --branch=$BRANCH --depth=1 --quiet $OWNER/$REPO .

# Export variables.
node ~/export-vars.js $PRIVATE_KEY
if [ -e ~/build/export.sh ]; then source ~/build/export.sh; fi

# Parse .shoov.yml file
node ~/parse.js

# Show commands from now on
set -x

# Execute the parsed .shoov.yml file
bash -c ~/shoov.sh
