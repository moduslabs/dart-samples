///
/// Editor class
///
/// Class to open a temporary file in $EDITOR and return the edited file as a string.
///

import 'dart:io';
import 'dart:io' show Platform;

class Editor {
  late final String editor;
  var tempFilename = '';

  static int nextFileNumber = 0;
  Editor([fn = '']) {
    final tmp = Directory.systemTemp.path;
    while (tempFilename.length < 1) {
      final fn = '$tmp/mt_editor_$nextFileNumber';
      nextFileNumber++;
      File f = File(tempFilename);
      if (!f.existsSync()) {
        this.tempFilename = fn;
        break;
      }
    }
    Map<String, String> env = Platform.environment;
    String? e = env['EDITOR'];
    if (e == null) {
      print('*** Warning: no editor defined, using vi');
      editor = '/bin/vi';
    } else {
      editor = e;
    }
  }

  Future<String> edit() async {
    final process = await Process.start(
        '$editor', //
        [tempFilename], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );

    final result = await process.exitCode;
    File f = File(tempFilename);
    if (f.existsSync()) {
      if (result == 0) {
        final res = f.readAsLinesSync();
        f.delete();
        return res.join('\n');
      } else {
        f.delete();
      }
    }
    return "";
  }
}
