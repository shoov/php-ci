FROM ubuntu:14.04
MAINTAINER Gizra

# Update and install packages
RUN apt-get update
RUN apt-get install -y curl zsh git vim
RUN apt-get install -y -q php5-cli php5-curl
RUN apt-get install -y wget

RUN curl -sL https://deb.nodesource.com/setup  | sudo bash -
RUN apt-get install -y nodejs

# Install phantomJS and casperJS
RUN npm install -g casperjs
RUN \
  cd /usr/local/share && \
  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 && \
  ls -al && \
  tar xjf phantomjs-1.9.7-linux-x86_64.tar.bz2 && \
  ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs && \
  ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
  ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/bin/phantomjs && \
  phantomjs -v

# Install jq
RUN cd /usr/local/bin && curl -O http://stedolan.github.io/jq/download/linux64/jq && chmod +x jq

# Install hub
RUN cd /usr/local/bin && curl -L https://github.com/github/hub/releases/download/v2.2.0/hub-linux-amd64-2.2.0.tar.gz | tar zx && cp hub-linux-amd64-2.2.0/hub .

# Install composer globally
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# Create "shoov" user with password crypted "shoov"
RUN useradd -d /home/shoov -m -s /bin/zsh shoov
RUN echo "shoov:shoov" | chpasswd

# Add hub config template
ADD _hub /home/shoov/.config/hub

# Create a new zsh configuration from the provided template
ADD .zshrc /home/shoov/.zshrc

# Fix permissions
RUN chown -R shoov:shoov /home/shoov

# Add "shoov" to "sudoers"
RUN echo "shoov ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /home/shoov/.oh-my-zsh/

# Enable ssh-agent
RUN eval `ssh-agent -s`

RUN mkdir /home/shoov/build && chmod 777 /home/shoov/build

# Create known_hosts
RUN mkdir /home/shoov/.ssh
RUN touch /home/shoov/.ssh/known_hosts

# Add Github key
RUN ssh-keyscan -H github.com > /home/shoov/.ssh/known_hosts

# Add scripts in a temp folder, so Docker will cache it
RUN mkdir /temp-build
ADD package.json /temp-build/package.json
RUN cd /temp-build && npm install --verbose
RUN cp -R /temp-build/node_modules /home/shoov

# Add scripts
ADD build_info.js /home/shoov/build_info.js
ADD get_hub.js /home/shoov/get_hub.js
ADD main.sh /home/shoov/main.sh
ADD parse.js /home/shoov/parse.js
ADD export-vars.js /home/shoov/export-vars.js

USER shoov
WORKDIR /home/shoov
ENV HOME /home/shoov
ENV PATH $PATH:/home/shoov

CMD /home/shoov/main.sh
