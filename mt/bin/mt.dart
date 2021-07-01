import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

import '../commands/bump.dart';

main(List<String> args) {
  // final doc = loadYaml(File('mt.yaml').readAsStringSync());
  // print('doc $doc');

  final runner = CommandRunner('mt', 'A tool to manage Dart monorepos')
    ..addCommand(BumpCommand())
    ..argParser.addOption('mode', allowed: ['debug', 'release'])
    ..argParser.addFlag('verbose', abbr: 'v', defaultsTo: false, help: 'Print verbose logging')
    ..run(args);
}
