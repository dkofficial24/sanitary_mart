# Use an official Node.js runtime as the base image
FROM node:latest

# Install necessary tools and dependencies
# Add a custom package repository
RUN echo "deb http://archive.ubuntu.com/ubuntu bionic main universe" > /etc/apt/sources.list

# Update package lists and install OpenJDK 11
RUN sudo apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    npm install -g firebase-tools


# Set the working directory in the container
WORKDIR /app

# Copy the project files to the container
COPY . .

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH="/app/flutter/bin:${PATH}"

# Install Android dependencies
RUN yes | sdkmanager --licenses
RUN flutter doctor -v

# Install Android Gems
RUN gem install bundler
RUN bundle install

# Run Flutter commands
RUN flutter pub get
RUN flutter build apk

# Create Firebase Service Credentials file
RUN echo "$FIREBASE_CREDENTIALS" > firebase_credentials.json.b64 && \
    base64 -d -i firebase_credentials.json.b64 > "/app/android/firebase_credentials.json"

# Set up key.properties
RUN echo "keyPassword=${{ secrets.SIGNING_STORE_PASSWORD }}" > /app/android/key.properties && \
    echo "storePassword=${{ secrets.SIGNING_KEY_PASSWORD }}" >> /app/android/key.properties && \
    echo "keyAlias=${{ secrets.SIGNING_KEY_ALIAS }}" >> /app/android/key.properties

# Distribute Android Beta App
RUN bundle exec fastlane android deploy_to_firebase
