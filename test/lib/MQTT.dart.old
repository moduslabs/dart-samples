library mqtt;

import 'dart:collection';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:test/debug.dart';

typedef Callback = void Function(String topic, String message);

const KEEP_ALIVE = 20;

final debug = Debug('MQTT');

class Mqtt {
  late final client;
  late final broker;

  final subscriptions = HashMap<String, List<Callback>>();

  Mqtt(String broker) {
    this.broker = broker;
  }

  Future<void> connect() async {
    client = MqttServerClient(broker, '');

    client.logging(on: false);
    client.keepAlivePeriod = KEEP_ALIVE;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(
            KEEP_ALIVE) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    debug('Mqtt::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      debug('Mqtt::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      debug('Mqtt::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debug('Mqtt::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      debug(
          'Mqtt::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      final topic = c[0].topic;

//      debug('received $topic $pt');
      var l = subscriptions[topic];
      if (l != null) {
        l.forEach((cb) {
          cb(topic, pt);
        });
      }

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
//      debug('${c[0].topic}: $pt');
      //    debug('');
    });
  }

  void subscribe(String topic, Callback callback) {
    var l = subscriptions[topic];
    if (l == null) {
      subscriptions[topic] = [];
      l = subscriptions[topic];
    }
    subscriptions[topic]!.add(callback);
    debug('subscribe $l');
    if (subscriptions[topic]!.length == 1) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  void unsubscribe(String topic, Callback callback) {
    var l = subscriptions[topic];
    if (l != null) {
      l.forEach((cb) {
        if (cb == callback) {
          l.remove(callback);
        }
      });
      if (l.isEmpty) {
        client.unsubscribe(topic, MqttQos.atMostOnce);
      }
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    debug('Mqtt::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    debug('Mqtt::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      debug('Mqtt::OnDisconnected callback is solicited, this is correct');
    }
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    debug(
        'Mqtt::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    //  debug('Mqtt::Ping response client callback invoked');
  }
}
