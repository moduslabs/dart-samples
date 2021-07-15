import 'dart:io';
import 'dart:io' show Platform;

class Git {
  static Future<int> commit(String message) async {
    print('git commit -a -m $message');
    return 0;
    final process = await Process.start(
        'git', //
        ['-a', '-m', message], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );

    final result = await process.exitCode;

    return result;
  }
}
