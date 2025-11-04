# Docker Acquia CI

[![docker pull apax/acquia-ci](https://img.shields.io/badge/dockerhub-image-blue.svg?logo=Docker)](https://hub.docker.com/r/apax/acquia-ci/tags)

This is the source Dockerfile for the [apax/acquia-ci](https://hub.docker.com/r/apax/acquia-ci/tags) docker image.

## Image Contents

- [CircleCI PHP, Node, Headless browser Docker base image](https://hub.docker.com/r/circleci/php)
- [Acquia CLI](https://docs.acquia.com/acquia-cli)
- Test tools
  - headless chrome
  - phpunit
  - bats
  - behat
  - php_codesniffer
  - hub
  - lab
- Test scripts

### Building the image

From project root:

```
# PHPVERSION could be 7.4, 8.1, 8.2 or 8.3.
PHPVERSION=7.4
docker build --build-arg PHPVERSION=$PHPVERSION -t apax/acquia-ci:php${PHPVERSION} .
```

### Using the image

#### Image name and tag

- apax/acquia-ci:php7.4
- apax/acquia-ci:php8.1
- apax/acquia-ci:php8.2
- apax/acquia-ci:php8.3