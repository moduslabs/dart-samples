// @dart=2.12
import 'package:bravia/bravia.dart';
import 'package:debug/debug.dart';
import 'package:hostbase/hostbase.dart';
import 'package:modus_mqtt/modus_mqtt.dart';

final MQTT_HOST = 'nuc1';

class BraviaHost extends HostBase {
  late final Bravia _bravia;
  final _commandQueue = [];
  final _inputs = {};

  BraviaHost(String host) : super(MQTT_HOST, 'bravia/${host}', false) {
    _bravia = Bravia(host);
  }

  @override
  Future<void> command(cmd, arg) async {
    // presence supports no commands other than restart, which is handled
    // by HostBase
  }

  getPlayingContentInfo() async {
    final state = await _bravia.avContent.invoke('getPlayingContentInfo');
    print('state ${state}');
    return state;
  }

  pollSpeakers() async {
    final state = await _bravia.audio.invoke('getSoundSettings', version: '1.1', params: {});
    print('speakers ${state}');
    return state;
  }

  @override
  Future<Never> run() {
    var lastVolume = null;

    while (true) {
      pollSpeakers();
    }
  }
}

Future<Never> main(List<String> arguments) async {
  await MQTT.connect();
  var mbr = BraviaHost('sony-950h');
  await mbr.getPlayingContentInfo();
  await mbr.pollSpeakers();
  // await mbr.system.getMethodTypes('1.0');
  // await mbr.getIRCCCodes();
  // print(await mbr.appControl.invoke("getApplicationList"));
  var office = Bravia('sony-810c');
  print('hello, bravia');
  for (;;) {
    await HostBase.sleep(120);
  }
}
