# PHP-CI

> Behat tests on the live site

## Install

``docker pull amitaibu/php-ci``

## Usage

docker run -e "BACKEND_URL=https://example/com" -it amitaibu/php-ci /home/shoov/main.sh <build-id> <access-token>


## Build

If you need adapt the project to your needs, clone, modify the `Dockerfile` and from the source directory, run:

docker build -t amitaibu/php-ci .
