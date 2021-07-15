import 'package:args/command_runner.dart';
import 'package:mt/mt_yaml.dart';

abstract class MTCommand extends Command {
  late final _mt_yaml = ProjectOptions('.');

  ProjectOptions get mt_yaml {
    return _mt_yaml;
  }

/*  Future<List<String>> _loadFile(String filename) async {*/
/*    File file = File(filename);*/
/*    return await file.readAsLines();*/
/*  }*/
}
