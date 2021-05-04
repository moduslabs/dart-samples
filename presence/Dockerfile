FROM google/dart-runtime-base

WORKDIR /project/app
ADD pkg /project/pkg

# Template for adding the application and local packages.
ADD presence/pubspec.* /project/app/
RUN pub get
ADD presence /project/app
RUN pub get --offline
