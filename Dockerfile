FROM ruby:3.4.1-slim

ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    LANG=C.UTF-8

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
      build-essential libpq-dev postgresql-client git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN gem install bundler --conservative \
 && bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint bin/rails bin/setup

ENTRYPOINT ["bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]