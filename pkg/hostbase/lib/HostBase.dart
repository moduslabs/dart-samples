///
/// HostBase class
///
/// Abstract class for implementing server side "hosts".  A host monitors and/or controls a single device, such as a TV (you might have multiple TVs in the home/office).
///
/// The run()

// @dart=2.12

library HostBase;

import 'package:statefulemitter/StatefulEmitter.dart';
import 'package:debug/debug.dart';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mqtt/MQTT.dart';
import 'package:json/JSON.dart';
import 'package:env/Env.dart';

final debug = Debug('HostBase');

abstract class HostBase extends StatefulEmitter {
  var retain = false;
  String? host, topic;
  bool? custom;
  late String setRoot, statusRoot;
  late int setRootLength;

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
        Map<dynamic, dynamic>? oldState = ev.eventData as Map<dynamic, dynamic>?, newState = state as Map<dynamic, dynamic>?;
        bool save = retain;
        newState!.forEach((k, v) {
          // ignore mongodb's generated _id field
          if (oldState![k] != newState[k]) {
            publish(k, newState[k]);
          }
        });
        retain = save;
      } catch (e, trace) {
        print('statechange exception $e $trace');
      }
    });
  }

  ///
  /// abstract (async) function run().  In your child class, you override this and implement the guts of your polling/WebSocket monitoring, etc.
  ///
  Future<Never> run() ;

  ///
  /// abstract (async) function command(command, args) is called when a command is received via MQTT.
  ///
  /// The HostBase class subscribes to $topic/set/# and passes the value of # as cmd and the message as args.
  ///
  /// The RESET command is handled automatically (program exits so something like forever will restart it).
  ///
  Future<void> command(cmd, args) ;

  ///
  /// General purpose async static wait(seconds) function.
  ///
  /// If you want to wait in a loop inside an async function, you can call this.
  ///
  static Future<void> wait(int seconds) =>
      Future<void>.delayed(Duration(seconds: seconds));

  ///
  /// publish(key, value)
  ///
  /// publishes to topic $topic/status/$key, message is value.
  ///
  /// if value is an object, it is converted as JSON before sending.
  ///
  void publish(String key, value) {
    final t = '${this.topic}/status/${key}';
    if (value is bool) {
      MQTT.publish(t, value);
      return;
    }
    final String val = value is String ? value : JSON.stringify(value);

    debug("publish ${t} >>> ${val}");
    MQTT.publish(t, val);
  }

  ///
  /// var settings = await getSetting(String key);
  ///
  /// Fetches the setting identified by key from the MongoDB.
  ///
  /// Caller must JSON.parse() it if it is expected to be an Object/Map.
  ///
  static Future<Map<String, dynamic>>? getSetting(String? setting) async {
    if (setting == null) {
      return {};
    }
    var host = Env.get('MONGODB_HOST');
    if (host == null) {
      debug('getSetting: no MONGODB_HOST');
      host = 'nuc1';
    }
    host = 'mongodb://${host}:27017/settings';
    final db = Db(host);
    await db.open();
    final collection = await db.collection('config');
    final s = await collection.findOne({"_id": setting}) ?? {};
    await db.close();
    return Future.value(s);
  }
}
