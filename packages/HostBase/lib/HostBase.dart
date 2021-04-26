import 'package:StatefulEmitter/StatefulEmitter.dart';
import 'package:debug/debug.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mqtt/MQTT.dart';
import 'package:JSON/JSON.dart';

final debug = Debug('HostBase');

abstract class HostBase extends StatefulEmitter {
  final MQTT = Mqtt('nuc1');
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
    statusRoot = topic + "status";

    //
    MQTT.on("connect", null, (event, context) {
      print("HostBase connect");
      MQTT.subscribe("${setRoot}/", (topic, message) {
        final command = topic.substring(setRootLength);
        this.command(command, message);
      });
    });

    this.on("statechange", null, (ev, context) {
      Map<String, dynamic> newState = state, oldState = ev.eventData;
      bool save = this.retain;
      newState.forEach((k, v) {
        // ignore mongodb's generated _id field
        print("key ${k} v ${v}");
        if (oldState[k] != newState[k]) {
          publish(k, newState[k]);
        }
      });
    });
  }

  Future<void> command(cmd, args);

  Future<void> wait(int seconds) =>
      Future<void>.delayed(Duration(seconds: seconds));

  void publish(String key, value) {
    final topic = "${setRoot}/${key}",
        val = value is String ? value : JSON.stringify(value);

    debug("publish ${topic} >>> ${val}");
    MQTT.publish(topic, value);
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
