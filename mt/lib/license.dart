import 'package:mt/mtcommand.dart';

class InstallCommand extends MTCommand {
  final name = 'install';
  final description = 'Install project as tool';
  late final _mt_yaml;
  InstallCommand(mt_yaml) {
    _mt_yaml = mt_yaml;
  }
  @override
  Future<void> run() async {}
}
