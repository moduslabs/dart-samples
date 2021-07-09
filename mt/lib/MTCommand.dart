import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mt/pubspec.dart';

abstract class MTCommand extends Command {
  void _copyFile(String oldPath, String newPath) {
    File oldFile = File(oldPath);
    oldFile.copySync(newPath);
  }
  Future<List<String>> _loadFile(String filename) async {
    File file = File(filename);
    return await file.readAsLines();
  }
}
