// @dart=2.9
import 'package:mqtt/MQTT.dart';

// import 'package:test/debug.dart';
import 'package:debug/debug.dart';
import 'package:HostBase/HostBase.dart';

final debug = Debug('main');

final MQTT_HOST = "nuc1";

class PresenceHost extends HostBase {
  String device;
  PresenceHost(presence): super(MQTT_HOST, "presence/${presence["person"]}", false) {
    device = presence["device"];
    print("PresenceHost ${host} ${setRoot}");
  }

  @override
  Future<void> command(cmd, arg) async {

  }
}

Future<void> asyncSleep(int seconds) =>
    Future<void>.delayed(Duration(seconds: seconds));

void onMessage(String topic, String message) {
  debug('onMessage "$topic" "$message"');
}

Future<int> main() async {
  final MQTT = Mqtt('nuc1');
  final hosts = [];

  var config = await HostBase.getSetting("config");
  print("Config ${config["presence"]}");
  for (var person in config["presence"]) {
    hosts.add(PresenceHost(person));
  }
  await MQTT.connect();
  /// Ok, lets try a subscription
  const topic = 'hubitat/Back Room Light/status/switch'; // Not a wildcard topic
  debug('Subscribing to $topic topic $onMessage');
  MQTT.subscribe(topic, onMessage);

  while (true) {
    await asyncSleep(120);
  }
}
