import 'dart:io';
import 'package:mt/mtcommand.dart';

class InstallCommand extends MTCommand {
  final name = 'install';
  final description = 'Install project as program';

  @override
  Future<int> run() async {
    final command = 'pub';
    if (mt_yaml.type != 'tool') {
      print('*** "type"" is not "tool" in mt.yaml');
      exit(1);
    }
    final process = await Process.start(
        '$command', //
        ['global', 'activate', '--source', 'path', '.'], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }
}

class UninstallCommand extends MTCommand {
  final name = 'uninstall';
  final description = 'Uninstall project as program';

  @override
  Future<int> run() async {
    final command = 'pub';
    if (mt_yaml.type != 'tool') {
      print('*** "type"" is not "tool" in mt.yaml');

    }

    final process = await Process.start(
        '$command', //
        ['global', 'deactivate', mt_yaml.package], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }
}
