# Use an official Python runtime as a parent image
FROM circleci/php:7.4-node-browsers

# Switch to root user
USER root

# Install necessary packages for PHP extensions
RUN apt-get --allow-releaseinfo-change update && \
     apt-get install -y \
        dnsutils \
        libmagickwand-dev \
        libzip-dev \
        libsodium-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libicu-dev \
        g++

# Add necessary PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

RUN pecl config-set php_ini /usr/local/etc/php/php.ini && \
    pear config-set php_ini /usr/local/etc/php/php.ini && \
    pecl channel-update pecl.php.net


RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure sodium
RUN docker-php-ext-install sodium
RUN pecl install libsodium-2.0.21

RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN docker-php-ext-install bcmath

# Set the memory limit to unlimited for expensive Composer interactions
RUN echo "memory_limit=-1" > /usr/local/etc/php/conf.d/memory.ini

###########################
# Install acquia ci things
###########################

# Set the working directory to /acquia-ci
WORKDIR /acquia-ci

# Copy the current directory contents into the container at /acquia-ci
ADD . /acquia-ci

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby jq curl rsync
RUN gem install circle-cli

# Make sure we are on the latest version of Composer
RUN composer selfupdate

# Create an unpriviliged test user
RUN groupadd -g 999 tester && \
    useradd -r -m -u 999 -g tester tester && \
    chown -R tester /usr/local && \
    chown -R tester /acquia-ci
USER tester

# Install Acquia CLI
RUN curl -OL https://github.com/acquia/cli/releases/latest/download/acli.phar && chmod +x acli.phar && ln -s /acquia-ci/acli.phar /usr/local/bin/acli

# Install CLU
RUN mkdir -p /usr/local/share/clu
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/clu require danielbachhuber/composer-lock-updater:^0.8.2

# Install Drush
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^10"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Add hub in case anyone wants to automate GitHub PR creation, etc.
RUN curl -LO https://github.com/github/hub/releases/download/v2.11.2/hub-linux-amd64-2.11.2.tgz && tar xzvf hub-linux-amd64-2.11.2.tgz && ln -s /acquia-ci/hub-linux-amd64-2.11.2/bin/hub /usr/local/bin/hub

# Add lab in case anyone wants to automate GitLab MR creation, etc.
# RUN curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | bash

# Add phpcs for use in checking code style
RUN mkdir ~/phpcs && cd ~/phpcs && COMPOSER_BIN_DIR=/usr/local/bin composer require squizlabs/php_codesniffer:^2.7

# Add phpunit for unit testing
RUN mkdir ~/phpunit && cd ~/phpunit && COMPOSER_BIN_DIR=/usr/local/bin composer require phpunit/phpunit:^6

# Add bats for functional testing
RUN git clone https://github.com/sstephenson/bats.git; bats/install.sh /usr/local

# Add Behat for more functional testing
RUN mkdir ~/behat && \
    cd ~/behat && \
    COMPOSER_BIN_DIR=/usr/local/bin \
    composer require \
        "behat/behat:^3.5" \
        "behat/mink:*" \
        "behat/mink-extension:^2.2" \
        "behat/mink-goutte-driver:^1.2" \
        "drupal/drupal-extension:*"
