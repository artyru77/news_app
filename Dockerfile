FROM ruby:2.4-slim

ENV APP_HOME /news_app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update -qq
RUN apt-get install -qq -y git curl build-essential libpq-dev apt-transport-https \
    postgresql-client ntp --no-install-recommends --fix-missing
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -qq -y nodejs yarn

ADD package.json ./
ADD yarn.lock ./
RUN yarn install

ENV BUNDLE_PATH /bundle
ADD Gemfile* ./
RUN bundle install

ADD . .

RUN ruby bin/webpack

ENTRYPOINT ["/news_app/docker-entrypoint.sh"]
CMD puma -C config/puma.rb
