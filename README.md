# Docker Acquia CI

[![docker pull apax/acquia-ci](https://img.shields.io/badge/dockerhub-image-blue.svg?logo=Docker)](https://hub.docker.com/repository/docker/apax/acquia-ci)

This is the source Dockerfile for the [apax/acquia-ci](https://hub.docker.com/repository/docker/apax/acquia-ci) docker image.

## Image Contents

- [CircleCI PHP 7.4, Node, Headless browser Docker base image](https://hub.docker.com/r/circleci/php)
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
