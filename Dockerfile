FROM ruby:2.6-alpine

RUN gem install awesome_print elasticsearch optimist
COPY src/spacemon.rb /usr/local/bin/spacemon.rb
COPY src/docker_entrypoint.sh /docker_entrypoint.sh
RUN chmod a+x /docker_entrypoint.sh
ENTRYPOINT /docker_entrypoint.sh
