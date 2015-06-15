# PHP-CI

> Behat tests on the live site

## Install

    $ docker pull amitaibu/php-ci

## Usage

When working locally the backend URL should be your IP, as docker doesn't know what "localhost" is.

    $ docker run -e "BACKEND_URL=http://10.0.0.1/" \
      -it amitaibu/php-ci /home/shoov/main.sh <build-id> <access-token>
    
### Silenium support    
    
To work with silenium support first run the silenium server.

    $ docker run --name=silenium elgalu/selenium:v2.45.0-oracle1
    
For other configuration options check [full documentation to silenium container](https://registry.hub.docker.com/u/elgalu/docker-selenium/) 
    
Then run php-ci linked to the silenium server.

    $ docker run --link silenium:silenium \
      -e "BACKEND_URL=http://10.0.0.1/" \
      amitaibu/php-ci /home/shoov/main.sh <build-id> <access-token>
      
Be sure that `wd-host` property configured correctly in `behat.local.yml.example` file. It's should be:
    
    http://silenium:4444/wd/hub
    
Because `silenium` it's alias for the silenium server ip.

## Build

If you need adapt the project to your needs, clone, modify the `Dockerfile` and from the source directory, run:

    $ docker build -t amitaibu/php-ci .
