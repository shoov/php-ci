FROM debian:8.1
MAINTAINER Gizra

# Update and install packages
RUN apt-get update
RUN apt-get install -y curl git
RUN apt-get install -y -q php5 php5-cli php5-curl

# Install Node.JS
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# Install jq - commandline JSON processor
RUN cd /usr/local/bin && curl -O http://stedolan.github.io/jq/download/linux64/jq && chmod +x jq

# Install hub - Git + Hub
RUN cd /usr/local/bin && curl -L https://github.com/github/hub/releases/download/v2.2.0/hub-linux-amd64-2.2.0.tar.gz | tar zx && cp hub-linux-amd64-2.2.0/hub .

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# Add root catalog for shoov environment
RUN mkdir /usr/local/shoov
RUN mkdir /usr/local/shoov/.config
RUN mkdir /usr/local/shoov/build

# Add hub config template
ADD _hub /usr/local/shoov/.config/hub

# Add scripts in a temp folder, so Docker will cache it
RUN mkdir /temp-build
ADD package.json /temp-build/package.json
RUN cd /temp-build && npm install --verbose
RUN cp -R /temp-build/node_modules /usr/local/shoov

# Add scripts
ADD build_info.js /usr/local/shoov/build_info.js
ADD get_hub.js /usr/local/shoov/get_hub.js
ADD main.sh /usr/local/shoov/main.sh
ADD parse.js /usr/local/shoov/parse.js
ADD export-vars.js /usr/local/shoov/export-vars.js

WORKDIR /usr/local/shoov
ENV HOME /usr/local/shoov
ENV PATH $PATH:/usr/local/shoov

CMD /usr/local/shoov/main.sh
