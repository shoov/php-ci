FROM ubuntu:14.04
MAINTAINER Gizra <info@gizra.com>

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update list of packages and install packages
RUN apt-get update
RUN apt-get install -y curl git graphicsmagick jq php5-cli php5-curl

# Install NodeJS and NPM
RUN curl -sSL https://deb.nodesource.com/setup  | bash -
RUN apt-get install -y nodejs

# Install mocha
RUN npm install -g mocha

# Change working directory to install software manually
WORKDIR /usr/local/bin

# Install hub
RUN curl -sSL https://github.com/github/hub/releases/download/v2.2.0/hub-linux-amd64-2.2.0.tar.gz | tar zx && ln -s hub-linux-amd64-2.2.0/hub

# Install composer globally
RUN curl -sSL https://getcomposer.org/installer | php && mv composer.phar composer

# Create "shoov" user with crypted password "shoov"
RUN useradd -d /home/shoov -m -s /bin/bash shoov
RUN echo "shoov:shoov" | chpasswd

# Add "shoov" to "sudoers"
RUN echo "shoov ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Change working directory to home directory of shoov user
WORKDIR /home/shoov

# Enable ssh-agent
RUN eval `ssh-agent -s`

RUN mkdir build && chmod 777 build

# Create known_hosts
RUN mkdir .ssh && touch .ssh/known_hosts

# Add Github key
RUN ssh-keyscan -H github.com > .ssh/known_hosts

# Add scripts in a temp folder, so Docker will cache it
RUN mkdir /temp-node-modules
ADD package.json /temp-node-modules/package.json
RUN cd /temp-node-modules && npm install --verbose
RUN cp -R /temp-node-modules/node_modules /home/shoov

# Add scripts
ADD ansi2html.sh /home/shoov/ansi2html.sh
ADD build_info.js /home/shoov/build_info.js
ADD export-vars.js /home/shoov/export-vars.js
ADD main.sh /home/shoov/main.sh
ADD parse.js /home/shoov/parse.js

# Fix permissions
RUN chown -R shoov:shoov /home/shoov

USER shoov

ENV HOME /home/shoov
ENV PATH $PATH:/home/shoov

CMD ["/home/shoov/main.sh"]
