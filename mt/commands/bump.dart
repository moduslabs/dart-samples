import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'package:version/version.dart';
import 'package:mt/MTCommand.dart';
import 'package:mt/pubspec.dart';
import 'package:mt/changelog.dart';
import 'package:mt/packages.dart';
import 'package:mt/editor.dart';

class BumpCommand extends Command {
  final name = 'bump';
  final description = 'bump version numbers';
  late final _mt_yaml;
  final _spaces = '                                  ';
  late final pubspec;

  BumpCommand(mt_yaml) {
    _mt_yaml = mt_yaml;
    argParser.addFlag('recurse', abbr: 'r');
    argParser.addOption('type',
        abbr: 't',
        allowed: ['major', 'minor', 'point', 'suffix'],
        defaultsTo: 'point');
    argParser.addOption(
      'message',
      abbr: 'm',
    );
    argParser.addOption('fix', abbr: 'f');
    pubspec = Pubspec('pubspec.yaml');
  }

  _dumpYaml(YamlMap yaml, indent) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';
    for (final key in yaml.keys) {
      final value = yaml[key];
      if (value is String) {
        print('$spaces$key: $value');
      } else {
        print('$spaces$key:');
        _dumpYaml(value, indent + 1);
      }
    }
  }

  Future<String> _bumpVersion(String type) async {
    final packages = Packages();
    Changelog changelog = Changelog('CHANGELOG.md');
    var newVersion = Version.parse(pubspec.version);
    switch (type) {
      case 'major':
        newVersion = newVersion.incrementMajor();
        break;
      case 'minor':
        newVersion = newVersion.incrementMinor();
        break;
      case 'patch':
        newVersion = newVersion.incrementPatch();
        break;
      case 'prerelease':
        newVersion = newVersion.incrementPreRelease();
        break;
    }
    pubspec.version = newVersion.toString();

    pubspec.write('foo');
    changelog.write('foo2');
    return pubspec.version;

    // File file = File(pubspec);
    // if (file.existsSync()) {
    //   print('found $pubspec');
    //   final lines = await file.readAsLines();
    //   print('lines ${lines.runtimeType}');
    //   for (final line in lines) {
    //     print('line ($line)');
    //   }
    //   print('${lines.join("\n")}');
    //   final doc = loadYaml(lines.join('\n'));
    //   final versionString = doc['version'];
    //   if (versionString == null) {
    //     return '';
    //   }

    //   var ver = Version.parse(versionString);
    //   print('ver $type $ver');
    //   switch (type) {
    //     case 'major':
    //       ver = ver.incrementMajor();
    //       break;
    //     case 'minor':
    //       ver = ver.incrementMinor();
    //       break;
    //     case 'point':
    //       ver = ver.incrementPatch();
    //       break;
    //     case 'suffix':
    //       ver = ver.incrementPreRelease();
    //       break;
    //   }
    //   print('ver $ver');
    //   return ver.toString();

    // } else {
    //   return '';
    // }
  }

  /*
  recurse(String path) {
    // print('recurse(${path})');
    _updatePubspec(path);

    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is File) {
        // print('File(${f.path})');
      } else {
        recurse(f.path);
      }
    }
  }
*/

  @override
  Future<void> run() async {
    final type = argResults?['type'] ?? 'patch';
    var message = argResults?['message'] ?? [];
    if (message.length<1) {
      message = await Editor().edit();
    }
    print('message($message)');
    final oldVersion = pubspec.version;
    final newVersion = await _bumpVersion(type);
    print('Updated $type version from $oldVersion to $newVersion');
    // recurse(rest[0]);
  }
}
