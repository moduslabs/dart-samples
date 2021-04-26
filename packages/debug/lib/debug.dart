/// Support for doing something awesome.
///
/// More dartdocs go here.
library debug;

import 'dart:io';
import 'package:dart_console/dart_console.dart';

final console = Console();

int Now() {
  var n = DateTime.now().millisecondsSinceEpoch;
  return n;
}

final lastCall = Now();

class Logger {
  var prompt;
  ConsoleColor fg = ConsoleColor.black, bg = ConsoleColor.white;
  var log;

  static int nextColor = 0;
  final List<ConsoleColor> fg_colors = [
    ConsoleColor.brightBlue,
    ConsoleColor.brightRed,
    ConsoleColor.blue,
    ConsoleColor.cyan,
    ConsoleColor.green,
    ConsoleColor.red,
    ConsoleColor.brightCyan,
    ConsoleColor.brightGreen,
    ConsoleColor.black,
    ConsoleColor.brightBlack,
  ];
  final List<ConsoleColor> bg_colors = [
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.black,
    ConsoleColor.white,
    ConsoleColor.white,
  ];

  Logger(String key) {
    prompt = key;
    fg = fg_colors[nextColor];
    bg = bg_colors[nextColor];

//    print("lastCall $lastCall");
    if (++nextColor >= fg_colors.length) {
      nextColor = 0;
    }

    final envVars = Platform.environment;
    var debug = envVars['DEBUG'];
    if (debug == null) {
      log = (s) {};
    } else {
      final parts = debug.split(';');
      if (parts.contains(prompt)) {
        log = (s) {
          var elapsed = Now() - lastCall;
//          print('$lastCall $now');
          console.setForegroundColor(fg);
          console.setBackgroundColor(bg);
          console.write('$prompt ');
          console.resetColorAttributes();
          console.write('$s ');
          console.setForegroundColor(fg);
          console.setBackgroundColor(bg);
          console.writeLine('+${elapsed}ms');
//          lastCall = now;
          console.resetColorAttributes();
        };
      } else {
        log = (s) {};
      }
    }
  }
}

Function(String s) Debug(String name) {
  var d = Logger(name);
  return d.log;
}
