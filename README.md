# PHP-CI

> Behat tests on the live site

## Install

``docker pull amitaibu/php-ci``

## Usage

When working locally the backend URL should be your IP, as docker doesn't know what "localhost" is.

docker run -e "BACKEND_URL=http://10.0.0.1" -it amitaibu/php-ci /home/shoov/main.sh <build-id> <access-token>


## Build

If you need adapt the project to your needs, clone, modify the `Dockerfile` and from the source directory, run:

docker build -t amitaibu/php-ci .
