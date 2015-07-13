# PHP-CI

> Behat tests on the live site

## Install

```shell
docker pull shoov/php-ci:0.0.2
```

## Usage

When working locally the backend URL should be your IP, as docker doesn't know what "localhost" is.

<<<<<<< HEAD
```shell
docker run -e BACKEND_URL=http://10.0.0.1 -it shoov/php-ci /home/shoov/main.sh <build-id> <access-token>
```
=======
    $ docker run -e "BACKEND_URL=http://10.0.0.1/" \
      -it shoov/php-ci:0.0.2 /home/shoov/main.sh <build-id> <access-token>

### Selenium support

To work with selenium support first run the selenium server.

```shell
docker run --name=selenium \
  -e SCREEN_WIDTH=1920 -e SCREEN_HEIGHT=1080 \
  -e VNC_PASSWORD=hola -e WITH_GUACAMOLE=false \
  elgalu/selenium:v2.45.0-oracle1
```

For other configuration options check [full documentation to selenium container](https://registry.hub.docker.com/u/elgalu/docker-selenium/)

Then run php-ci linked to the selenium server.

```shell
docker run --link selenium:selenium \
  -e "BACKEND_URL=http://10.0.0.1/" \
  shoov/php-ci:0.0.2 /home/shoov/main.sh <build-id> <access-token>
```  

Direct your tests to run against `http://selenium:4444/wd/hub`

`http://selenium` is the alias for the selenium server IP.

## Build

If you need adapt the project to your needs, clone, modify the `Dockerfile` and from the source directory, run:

```shell
docker build -t shoov/php-ci .
```
