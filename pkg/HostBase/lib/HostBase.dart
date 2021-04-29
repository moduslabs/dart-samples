import 'package:StatefulEmitter/StatefulEmitter.dart';
import 'package:debug/debug.dart';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mqtt/MQTT.dart';
import 'package:JSON/JSON.dart';

final debug = Debug('HostBase');

// final MQTT = Mqtt('nuc1');

abstract class HostBase extends StatefulEmitter {
  var retain = false;
  String host, topic;
  bool custom;
  String setRoot, statusRoot;
  int setRootLength;

  HostBase(String host, String topic, bool custom) {
    retain = true;
    this.host = host;
    this.topic = topic;
    this.custom = custom;
    setRoot = topic + "/set";
    setRootLength = setRoot.length;
    statusRoot = topic + "/status";

    //
    MQTT.subscribe("${setRoot}/", (topic, String message) {
      if (message.indexOf("__RESTART__") != -1) {
        MQTT.publish(topic, null, retain: true);
        MQTT.publish(topic, null, retain: false);
        exit(0);
      }
      final command = topic.substring(setRootLength);
      this.command(command, message);
    });

    this.on("statechange", null, (ev, context) {
      try {
        Map<dynamic, dynamic> oldState = ev.eventData, newState = state;
        bool save = retain;
        newState.forEach((k, v) {
          // ignore mongodb's generated _id field
          if (oldState[k] != newState[k]) {
            publish(k, newState[k]);
          }
        });
        retain = save;
      } catch (e, trace) {
        print('statechange exception $e $trace');
      }
    });
  }

  Future<void> command(cmd, args);

  static Future<void> wait(int seconds) =>
      Future<void>.delayed(Duration(seconds: seconds));

  void publish(String key, value) {
    final t = '${this.topic}/set/${key}';
    if (value is bool) {
      MQTT.publish(t, value);
      return;
    }
    final String val = value is String ? value : JSON.stringify(value);

    debug("publish ${t} >>> ${val}");
    MQTT.publish(t, val);
  }

  static Future<Map<String, dynamic>> getSetting(String setting) async {
    var db = Db("mongodb://nuc1:27017/settings");
    await db.open();
    var collection = db.collection('config');
    var s = await collection.findOne({"_id": setting});
    await db.close();
    return Future.value(s);
  }
}
