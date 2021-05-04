// @dart=2.12

// import 'dart:io';
import 'package:env/Env.dart';
import 'package:mqtt/MQTT.dart';
import 'package:myq/MyQ.dart';
import 'package:debug/debug.dart';
import 'package:hostbase/HostBase.dart';

final debug = Debug('MyQHost');

final MQTT_HOST = Env.get('MQTT_HOST') ?? 'nuc1',
    TOPIC_ROOT = Env.get('TOPIC_ROOT') ?? 'myq';

final EMAIL = Env.get('MYQ_EMAIL') ?? '',
    PASSWORD = Env.get('MYQ_PASSWORD') ?? '';

const POLL_TIME = 2 * 1000;

class MyQHost extends HostBase {
  late Map<String, dynamic> _device;
  late String _name, _type, _serialNumber;
  bool _lowBatteryState = false;
  var _account;

  MyQHost(device) : super(MQTT_HOST, '$TOPIC_ROOT/${device['name']}', false) {
    //
    _device = device;
    _name = device['name'];
    _type = device['device_family'];
    _serialNumber = device['serial_number'];

    debug('MyQHost: device $_name $_type $_serialNumber');
    run();
  }

  /// run()
  /// Forever login, then poll device status
  @override
  Future<Never> run() async {
    for (;;) {
      // keep reconnecting on failure
      final account = MyQ();
      _account = account;
      try {
        final login = await account.login(EMAIL, PASSWORD);
        if (login['code'] != 'OK') {
          print('$_name login failed $login');
          continue;
        }
        print('$_name login succeeded');
      } catch (e) {
        continue;
      }
      // poll
      for (;;) {
        try {
          final result = await account.getDevice(_serialNumber);
          if (result['code'] == 'OK') {
            final device = result['device'],
                newState = device['state'];
            final s = {};
            newState.keys.forEach((key) {
              if (key != 'physical_devices') {
                s[key] = newState[key];
              }
              switch (key) {
                case 'dps_low_battery_mode':
                  _lowBatteryState = newState[key];
                  s['lowBatteryState'] = _lowBatteryState;
                  break;
                case 'door_state':
                  s['door_state'] = newState[key];
                  break;
              }
              // print('newState $key ${newState[key]}');
            });
            setState(s);
          }
        } catch (e) {
          print('$_name Exception $e');
          // print(st);
        }
        await HostBase.wait(POLL_TIME);
      }
    }
  }

  @override
  Future<void> command(cmd, args) async {
    //
    print('cmd $cmd args $args');
  }
}

Future<Never> main(List<String> arguments) async {
  final hosts = [];

  await MQTT.connect();

  final account = MyQ();
  for (;;) {
    final loggedIn = await account.login(EMAIL, PASSWORD);
    if (loggedIn['code'] != 'OK') {
      print('login failed');
    } else {
      print('login succeeded');
      break;
    }
    await HostBase.sleep(1);
  }
  for (;;) {
    try {
      final devices = await account.getDevices();

      if (devices['devices'] != null) {
        devices['devices'].forEach((device) {
          final host = MyQHost(device);
          hosts.add(host);
        });
        break;
      } else {
        print('device error  ${devices['code']}');
      }
    }
    catch (e) {
      //
    }
  }

  for (;;) {
    await HostBase.sleep(120);
  }
}
