FROM ruby:3.2.0-alpine

# Install dependencies
RUN apk add --no-cache\
    build-base\
    postgresql-dev\
    git\
    nodejs\
    yarn\
    tzdata\
    libpq

WORKDIR /app

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

EXPOSE 8080

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]