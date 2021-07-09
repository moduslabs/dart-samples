import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/pubspec.dart';
import 'package:mt/changelog.dart';

class Package {
  late final _pubspec;
  late final _changelog;
  late final _packageDir;
  late final _name;

  Package(String packageDir) {
    _packageDir = packageDir;
    _name = p.basename(packageDir);
    _pubspec = Pubspec(packageDir);
    _changelog = Changelog(packageDir);
    // dump();
  }

  void dump() {
    print('');
    print('================================================================');
    print('==== Package $_name ($_packageDir)');
    print('================================================================');
    print('  ${_pubspec.name} ${_pubspec.version}');
    print('  ${_pubspec.description}');
    // _pubspec.dump();
    // _changelog.dump();
  }

}

class Packages {
  late final _packageDir;
  final _packages = [];
  final List<String> search = [
    './packages', //
    './pkg', //
    '../packages', //
    '../pkg'
  ];

  ///
  /// _locatePackageDir
  ///
  /// recursively look for dirName starting at path
  ///
  bool _locatePackageDir(String path, String dirName) {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        // print('directory(${f.path})');
        if (f.path.indexOf(dirName) != -1) {
          _packageDir = '$path/$dirName';
          return true;
        }
        if (_locatePackageDir(f.path, dirName)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _findPackageDir() {
    // first look for packages or pkg directory in this project or parent
    for (String path in search) {
      File f = File(path);
      if (f.existsSync() && f is Directory) {
        _packageDir = path;
        return true;
      }
    }
    return _locatePackageDir('.', 'pkg') ||
        _locatePackageDir('.', 'packages') ||
        _locatePackageDir('..', 'pkg') ||
        _locatePackageDir('..', 'packages');
  }

  bool _findPackages() {
    if (_findPackageDir()) {
      final dir = Directory(_packageDir);
      final dirList = dir.listSync();
      for (FileSystemEntity f in dirList) {
        if (f is Directory) {
          _packages.add(Package(f.path));
        }
      }
    } else {
      print('*** Warning: no package directory');
    }
    return true;
  }

  Packages() {
    // print('Packages Constructor ${Directory.current}');
    _findPackages();
  }
}
