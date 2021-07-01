import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

class BumpCommand extends Command {
  final name = 'bump';
  final description = 'bump version numbers';

  BumpCommand() {
    argParser.addFlag('recurse', abbr: 'r');
  }

  recurse(String path) {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is File) {
        print('File(${f.path})');
      } else {
        recurse(f.path);
      }
    }
  }

  @override
  Future<void> run() async {
    final rest = argResults?.rest ?? [];
    // print('verbose: ${globalResults?["verbose"]}');
    // print('mode: ${globalResults?["mode"]}');
    // print('recurse: ${argResults?["recurse"]}');
    if (rest.length < 1) {
      printUsage();
      return;
    }
    recurse(rest[0]);
  }
}
