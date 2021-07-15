import 'dart:io';
/*import 'dart:io' show Platform;*/
import 'package:path/path.dart' as p;
import 'package:mt/mtcommand.dart';

class GetCommand extends MTCommand {
  final name = 'get';
  final description = 'Run pub get on directory or directories';
  bool verbose = false;
  bool dryRun = false;
  bool recurse = false;

  cd(path) {
/*    print('cd $path');*/
    Directory.current = path;
  }

  GetCommand() {
    argParser.addOption('message',
        abbr: 'm', help: 'Message to add to CHANGELOG and for git commit');
    argParser.addFlag('recurse',
        abbr: 'r',
        defaultsTo: false,
        help:
            'Perform pub get recursively from directory down. Defaults to current directory.');
  }

  Future<int> pubGet(String path) async {
/*    print('pub get in ($path)');*/
    final f = File('./pubspec.yaml');
    if (f.existsSync()) {
      print('\n${p.current}');
      final process = await Process.start(
          'pub', //
          ['get'], //
          mode: ProcessStartMode.inheritStdio, //
          runInShell: true //
          );

      final result = await process.exitCode;

      return result;
    } else {
      if (verbose) {
        print('---> skipping $path - no pubspec.yaml ($f)');
      }
      return 0;
    }
  }

  Future<int> recurseGet(String path) async {
    final dir = Directory(path);
    final dirList = dir.listSync();
    final base = p.basename(path);
    final ignore = mt_yaml.ignore;

    // ignore directories in the mt.yaml ignore list
    if (ignore.indexOf(base) > -1) {
      if (verbose) {
        print('---> ignoring $path');
      }
      return 0;
    }
    for (FileSystemEntity f in dirList) {
      if (f is File) {
        continue;
      } else {
        var result = await recurseGet(f.path);
        if (result != 0) {
          return result;
        }
        final cwd = Directory.current;
        cd(f.path);
        result = await pubGet(path);
        cd(cwd);
        if (result != 0) {
          return result;
        }
      }
    }
    return 0;
  }

  Future<int> run() async {
    dryRun = globalResults?['dry-run'] ?? false;
    verbose = globalResults?['verbose'] ?? false;
    recurse = argResults?['recurse'] ?? false;

    final rest = argResults?.rest as List<String>;
    final dir = rest.length > 0 ? rest[0] : '.';

    if (verbose) {
      if (dryRun) {
        print("*** Dry Run - no files will be changed\n");
        mt_yaml.dump();
        print('');
      }
    }
    if (recurse) {
      print('Performing pub get recursively, start in $dir');
      return await recurseGet(dir);
    }
      print('Performing pub get in $dir');
    return await pubGet(dir);
  }
}
