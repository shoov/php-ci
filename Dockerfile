FROM ubuntu:14.04
MAINTAINER Gizra <gizra.com>

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update list of packages and install packages
RUN apt-get update
RUN apt-get install -y curl git jq php5-cli php5-curl

# Install NodeJS and NPM
RUN curl -sSL https://deb.nodesource.com/setup  | bash -
RUN apt-get install -y nodejs

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

# Add hub config template
ADD _hub .config/hub

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
ADD build_info.js build_info.js
ADD get_hub.js get_hub.js
ADD main.sh main.sh
ADD parse.js parse.js
ADD export-vars.js export-vars.js

# Fix permissions
RUN chown -R shoov:shoov /home/shoov

USER shoov

ENV HOME /home/shoov
ENV PATH $PATH:/home/shoov

CMD ["/home/shoov/main.sh"]
