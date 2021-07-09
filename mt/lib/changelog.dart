import 'dart:io';
import 'package:version/version.dart';

class ChangeEntry {
  var version;
  var lines;

  ChangeEntry(String version, List<String> lines) {
    this.version = version.length > 0 ? Version.parse(version) : '';
    this.lines = lines;
  }
  String toString() {
    return 'ChangeEntry $version';
  }
}

class Changelog {
  late final _path;
  var _lines;
  final _prelude = [];
  final _changes = [];

  Changelog(String path) {
    _path = path;

    var lines;
    File file = File('$path/CHANGELOG.md');
    if (!file.existsSync()) {
      var d = DateTime.now();
      lines = [
        '## 0.0.0 - ${d.month}/${d.day}/${d.year}',
        'Initial version',
      ];
    } else {
      lines = file.readAsLinesSync();
    }

    // break up lines into array of ChangeEntry instances.
    int index = 0;

    if (!lines[0].startsWith('##')) {
      while (index < lines.length) {
        final line = lines[index];
        if (line.startsWith('## ')) {
          break;
        }
        _prelude.add(line);
        index++;
      }
    }

    List<String> change = [];
    String version = '';
    while (index < lines.length) {
      final line = lines[index];
      if (line.startsWith('## ')) {
        if (change.length > 0) {
          _changes.add(ChangeEntry(version, change));
        }
        change = [line];
        final parts = line.split(new RegExp('\\s+'));
        version = parts[1];
      } else if (change.length > 0) {
        change.add(line);
      } else {
        change = [line];
        version = '';
      }
      index++;
    }

    // maybe add last change
    if (change.length > 0) {
      change.add('');
      _changes.add(ChangeEntry(version, change));
    }

    // sort _changes
    _changes.sort((a, b) => b.version.compareTo(a.version));
    lines = [];
    for (var c in _changes) {
      lines += c.lines;
    }
    _lines = lines;
  }

  void addVersion(String version, String comment) {
    if (comment == '') {
      comment = 'Bump version';
    }
    _lines.insert(0, '\n## $version\n$comment\n\n');
  }

  void dump() {
    print('================================================================');
    print('==== $_path/CHANGELOG.md');
    print('================================================================');
    print(_prelude.join('\n'));
    print(_lines.join('\n'));
    print(
        '    ================================================================');
  }

  void write(String filename) {
    if (false) {
      print('================================================================');
      print('==== $_path/CHANGELOG.md');
      print('================================================================');
      print(_prelude.join('\n'));
      print(_lines.join('\n'));
      print(
          '    ================================================================');
    }
  }
}
