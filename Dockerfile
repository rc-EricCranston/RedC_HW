# Use an image with Ruby pre-installed
FROM ruby:3.1

# Set the working directory in the Docker image
WORKDIR /app

# Copy your project's files into the Docker image
COPY . /app

# Install bundler and your project's gems
RUN gem install bundler && bundle install

# Set the default command for the Docker image
CMD ["bundle", "exec", "rake", "run_mac[linux_activity.txt]"]