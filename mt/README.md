# mt - tool for working with monorepos.

The biggest reason to use monorepos for Dart projects is to share (common) custom packages between the programs also in the monorepo.

There is an obvious need for a command line tool (or tools in the IDE) to work with monorepos. The mt tool is meant to make managing monorepos easy. For example, mt can (recursively) run pub get on any package directory containing a pubspec.yaml file.

Doing recursive pub get is only one pain point of working with monorepos and Dart.

mt is designed to work on the whole monorepo or any subdirectory/subtree of it, or individual files.

While mt features a rich set of commands and options/flags for those commands, you can create a mt.yaml file within each project/package directory of your monorepo to provide additional hints or directives to be honored by mt when it runs.

## Recursive pub get

In a Dart program(s) monorepo, we may have a packages/ folder with some number of individual package directories. Each of those package directories will have its own pubspec.yaml, and we need to run pub get within.

## Bump version number

To bump a package's version number, you need to edit CHANGELOG.md and add text for the new version, you need to edit the pubspec.yaml file to have the proper version number in it.

You also may need to update several other pubspec.yaml files within the monorepo to reference the package's new version number.

You can bump the pacakge's version number: major, minor, and or point values.

## Shared packages

While working on/developing packages that you ultimately want to publish to pub.dev (pub publish), the pubspec.yaml files in your project and package directories might contain relative links to dependencies in your monorepo. But when published, you need to edit all those pubspec.yaml files and convert the relative path entries to version numbers.

The mt tool can recursively edit your pubspec.yaml files to convert to, or create, relative links or convert those links to package versions to be fetched from pub.dev.

### Published packages

When you bump a package's version number, you may want to pub publish it, too. And you then may need to update all the pubspec.yaml files that refer to it.

## Maintaining docker-compose.yml

Your monorepo might contain a number of programs to be built as Docker containers and run via docker-compose.  The mt tool can automatically maintain your docker-compose.yml file by adding or removing service definitions.

As well, you can use mt to run any or all of the containers in production or development mode.

## Create new package or program directory

The mt command can be used to generate the directory structure for a new program or package within the monorepo.

The package directory needs to have a README.md, a CHANGELOG.md, a lib/ directory, a pubspec.yaml file, a mt.yaml file, a lib/package-name.dart file, etc.

Additionally, the files need to be added to git.

## Package coverage

You can use mt to generate relative and/or pub.dev specific dependencies within all the pubspec.yaml files in the repo or subtree.

You can have mt automatically generate local dependencies by examining the import statements in the .dart files in your package/program directories.

At some point, you will want to prune any packages not used.

See https://pub.dev/documentation/pub_api_client/latest/


