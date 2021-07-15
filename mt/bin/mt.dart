/*import 'dart:io';*/
import 'package:args/command_runner.dart';
/*import 'package:yaml/yaml.dart';*/
/*import 'package:mt/mt_yaml.dart';*/
import '../commands/bump.dart';
import '../commands/install.dart';
import '../commands/get.dart';

main(List<String> args) {
/*  final mt_yaml = loadYaml(File('mt.yaml').readAsStringSync());*/
/*  final mt_yaml = ProjectOptions();*/
/*  print('mt_yaml $mt_yaml');*/
/*  // print('doc $doc');*/

  print("\nmt by Modus Create");
  print("==================\n");

  CommandRunner('mt', 'A tool to manage Dart monorepos')
    ..addCommand(BumpCommand())
    ..addCommand(InstallCommand())
    ..addCommand(UninstallCommand())
    ..addCommand(GetCommand())
    ..argParser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug')
    ..argParser.addFlag('verbose',
        abbr: 'v', defaultsTo: false, help: 'Print verbose logging')
    ..argParser.addFlag('dry-run',
        abbr: 'd', defaultsTo: false, help: 'Do not update files')
    ..run(args);
}
