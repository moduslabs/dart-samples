import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Pubspec {
  late final _lines;
  var _doc;
  var _yaml;

  late final _path;
  late final _name;

  Pubspec(String path) {
    _path = path;
    _name = p.basename(path);

    File file = File('$path/pubspec.yaml');
    if (!file.existsSync()) {
      _lines = [
        'name: $_name',
        'version: 0.0.0',
        'description: >-',
        '  No description',
        '#repository: https://github.com/...',
        '',
        'environment:',
        "  sdk: '>=2.12.0 <3.0.0'",
        '',
        'dependencies:',
        '  path: ^1.7.0',
        '',
      ];
    } else {
      _lines = file.readAsLinesSync();
    }
    _yaml = loadYaml(_lines.join('\n')); //  as Map;
    _doc = Map.from(_yaml);
  }

  void set version(String ver) {
    _doc['version'] = ver;
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].startsWith('version:')) {
        _lines[i] = 'version: $ver';
        return;
      }
    }
    if (_lines.length == 0) {
      _lines.insert(0, 'version: $ver');
    } else {
      _lines.insert(1, 'version: $ver');
    }
  }

  String get version {
    return _doc['version'];
  }

  String get name {
    return _doc['name'];
  }

  String get description {
    return _doc['description'];
  }

  Map get doc {
    return _doc;
  }

  YamlMap get yaml {
    return _yaml;
  }

  void dump() {
    print('================================================================');
    print('==== pubspec.yaml');
    print('================================================================');
    print('  ' + _lines.join('\n  '));
    print('');
  }

  void write(String filename) {
    File file = File(filename);
    file.writeAsString(_lines.join('\n'));
  }

  @override
  String toString() {
    return 'pubspec $_path/pubspec.yaml\n$_lines';
  }
}
