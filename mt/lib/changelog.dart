import 'dart:io';
import 'package:version/version.dart';

///
/// private class used by Changelog to represent a version title and message (in markdown)
///
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

///
/// Changelog class
///
/// Represents a CHANGELOG.md file.
///
/// Once loaded, a CHANGELOG can be modified and written to a file.
///
class Changelog {
  late final _path;
  late final _filename;
  var _lines;
  final _prelude = [];
  final _changes = [];

  ///
  /// Constructor
  ///
  /// Open the CHANGELOG.md file and read it in as lines.  Or create the lines if the file doesn't exist.
  ///
  Changelog(String path) {
    _path = path;

    var lines;
    _filename = '$path/CHANGELOG.md';
    File file = File(_filename);
    if (!file.existsSync() || file.lengthSync() < 1) {
      var d = DateTime.now();
      lines = [
        '## 0.0.0 - ${d.month}/${d.day}/${d.year}',
        'Initial version',
      ];
    } else {
      lines = file.readAsLinesSync();
    }

    // Break up lines into "prelude" lines and array of ChangeEntry instances.
    // The prelude lines are just lines that appear in the .md file before any version declarations.
    int index = 0;

    //
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

    // parse the rest of the CHANGELOG into ChangeEntry instances, one per version.
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

    // maybe add last change (that wasn't added in the above loop)
    if (change.length > 0) {
      change.add('');
      _changes.add(ChangeEntry(version, change));
    }

    // sort _changes by version, newest first
    _changes.sort((a, b) => b.version.compareTo(a.version));
    lines = [];
    for (var c in _changes) {
      lines += c.lines;
    }
    _lines = lines;
  }

  void addVersion(String version, String message) {
    var d = DateTime.now();
    if (message == '') {
      message = 'Bump version';
    }
    _lines.insert(0, '');
    _lines.insert(0, '$message');
    _lines.insert(0, '## $version - ${d.month}/${d.day}/${d.year}');
  }

  void write([String filename = '']) {
    final f = File(filename == '' ? _filename : filename);
    if (filename == '' && f.existsSync()) {
      f.copySync('$_filename.bak');
    }
    f.writeAsStringSync(_prelude.join('\n') + _lines.join('\n'));
  }

  void dump() {
    print('================================================================');
    print('==== $_path/CHANGELOG.md');
    print('================================================================');
/*    print('  ' +_prelude.join('\n  '));*/
    print('  ' + _lines.join('\n  '));
    print('');
  }
}
