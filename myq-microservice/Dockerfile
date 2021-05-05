FROM google/dart-runtime-base

WORKDIR /project/app

# Add the pubspec.yaml files for each local package.
ADD pkg /project/pkg
#ADD pkg/debug/pubspec.yaml /project/pkg/debug/
#ADD pkg/HostBase/pubspec.yaml /project/pkg/HostBase/
#ADD pkg/JSON/pubspec.yaml /project/pkg/JSON/
#ADD pkg/mqtt/pubspec.yaml /project/pkg/mqtt/
#ADD pkg/StatefulEmitter/pubspec.yaml /project/pkg/StatefulEmitter/

# Template for adding the application and local packages.
ADD MyQ/pubspec.* /project/app/
RUN pub get
ADD MyQ /project/app
RUN pub get --offline
