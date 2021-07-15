import 'dart:io';
/*import 'package:path/path.dart' as p;*/
import 'package:yaml/yaml.dart';

class ProjectOptions {
  late final _yaml;
  final _spaces = '                                  ';

  ProjectOptions([path = '.']) {
    final f = File('$path/mt.yaml');
    if (f.existsSync()) {
      _yaml = loadYaml(f.readAsStringSync());
    } else {
      _yaml = {};
    }
  }

  bool get type {
    return _yaml['type'];
  }

  String get package {
    return _yaml['package'];
  }

  List<String> get ignore {
    final list = _yaml['ignore'].value ?? [];
    final List<String> ret = [];
    for (final dir in list) {
      ret.add(dir);
    }
    return ret;
/*    return ret as List<String>;*/
  }

  _dump(dynamic yaml, indent) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';
    for (final key in yaml.keys) {
      final value = yaml[key];
      if (value is String) {
        print('$spaces$key: $value');
      } else if (value is YamlList || value is YamlScalar) {
        print('$spaces$key: $value');
      } else {
        print('$spaces$key:');
        _dump(value, indent + 1);
      }
    }
  }

  dump({dynamic yaml = false, indent = 1}) {
    if (yaml == false) {
      yaml = _yaml;
    }
    print('================================================================');
    print('==== mt.yaml');
    print('================================================================');
    _dump(yaml, indent);
    print('');
  }
}
