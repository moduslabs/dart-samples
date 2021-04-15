/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'package:test/MQTT.dart';
import 'package:test/debug.dart';

final debug = Debug('main');

Future<void> asyncSleep(int seconds) =>
    Future<void>.delayed(Duration(seconds: seconds));

void onMessage(String topic, String message) {
  debug('onMessage "$topic" "$message"');
}

Future<int> main() async {
  final MQTT = Mqtt('nuc1');
  await MQTT.connect();

  /// Ok, lets try a subscription
  const topic = 'hubitat/Back Room Light/status/switch'; // Not a wildcard topic
  debug('Subscribing to $topic topic $onMessage');
  MQTT.subscribe(topic, onMessage);

  while (true) {
    await asyncSleep(120);
  }
}
