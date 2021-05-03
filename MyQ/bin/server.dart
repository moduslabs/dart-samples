// @dart=2.12

import 'package:env/Env.dart';
import 'package:myq/MyQ.dart';
import 'package:debug/debug.dart';
import 'package:hostbase/HostBase.dart';

final debug = Debug('main');

final MQTT_HOST = Env.get('MQTT_HOST') ?? 'nuc1',
    TOPIC_ROOT = Env.get('TOPIC_ROOT') ?? 'myq';

class MyQHost extends HostBase {
  late Map<String, dynamic> _device;
  late String _name;

  MyQHost(device) : super(MQTT_HOST, '$TOPIC_ROOT/${device.name}', false) {
    //
    _device = device;
  }

  @override
  Future<Never> run() async {
    for (;;) {}
  }

  @override
  Future<void>command(cmd, args) async {
    //
  }
}

Future<Never> main(List<String> arguments) async {
  Env.dump();
  final hosts = [];

  final account = MyQ();
  final loggedIn = await account.login(Env.get('MYQ_EMAIL') ?? '', Env.get('MYQ_PASSWORD') ?? '');
  final devices = await account.getDevices();
  print('devices $devices');

  for(;;) {
    await HostBase.wait(120);
  }

}
