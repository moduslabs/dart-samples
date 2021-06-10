/// Bravia class

import 'package:statefulemitter/statefulemitter.dart';
import 'package:debug/debug.dart';
import 'package:modus_json/modus_json.dart';
import 'package:dio/dio.dart';
import 'dart:io';

final debug = Debug('Bravia');

class ServiceProtocol {
  late final Bravia _bravia;
  late final String _protocol;
  final List<dynamic> _methods = [];

  ServiceProtocol(Bravia bravia, String protocol) {
    _bravia = bravia;
    _protocol = protocol;
  }

  getVersions() async {
    final versions = await invoke('getVersions');
    return versions[0];
  }

  getMethodTypes(String? version) async {
    if (_methods.length > 0) {
      if (version != null) {
        return _methods.firstWhere((method) => method['version'] == version);
      } else {
        return _methods;
      }
    }
    
    var versions = await getVersions();
    var index = 0;
    // local next function
    next(List<dynamic>? results) async {
      if (results != null) {
        Object record = {"version": versions[index - 1], "methods": results};
        _methods.add(record);
      }
      if (index < versions.length) {
        final result = await invoke('getMethodTypes',
            version: '1.0', params: versions[index++]);
        
        next(result);
      } else if (version != null && _methods.length > 0) {
        return _methods.firstWhere((method) => method['version'] == version);
      } else {
        return _methods;
      }
    }

    next(null);
  }

  invoke(String method, {String version = '1.0', dynamic params}) async {
    params = params != null ? [params] : [];
    final Map<String, dynamic> response = await _bravia.request(_protocol,
        {'id': 3, 'method': method, 'version': version, 'params': params});
    
    return response['result'];
  }
}

class Bravia extends StatefulEmitter {
  late final String _host, _psk;
  late final _port;
  late final _timeout;
  late final _url;
  var _codes = [];

  // protocols
  late final ServiceProtocol accessControl;
  late final ServiceProtocol appControl;
  late final ServiceProtocol audio;
  late final ServiceProtocol avContent;
  late final ServiceProtocol browser;
  late final ServiceProtocol cec;
  late final ServiceProtocol encryption;
  late final ServiceProtocol guide;
  late final ServiceProtocol recording;
  late final ServiceProtocol system;
  late final ServiceProtocol videoScreen;

  /// Constructor takes IP address or hostname argument
  Bravia(String host,
      {int port = 80, String psk = '0000', int timeout = 5000}) {
    _host = host;
    _port = port;
    _psk = psk;
    _timeout = timeout;

    _url = _port != 80 ? 'http://$_host:$_port/sony' : 'http://$_host/sony';

    debug('Construct Bravia $host $psk $timeout $_url');
    accessControl = ServiceProtocol(this, 'accessControl');
    appControl = ServiceProtocol(this, 'appControl');
    audio = ServiceProtocol(this, 'audio');
    avContent = ServiceProtocol(this, 'avContent');
    browser = ServiceProtocol(this, 'browser');
    cec = ServiceProtocol(this, 'cec');
    encryption = ServiceProtocol(this, 'encryption');
    guide = ServiceProtocol(this, 'guide');
    recording = ServiceProtocol(this, 'recording');
    system = ServiceProtocol(this, 'system');
    videoScreen = ServiceProtocol(this, 'videoScreen');
  }

  Future<Map<String, dynamic>> request(String path, dynamic json) async {
    // debug('$_host request $path JSON($json) $_url/$path');
    var dio = Dio();
    dio.options.headers['Content-Type'] = 'text/xml; charset=UTF-8';
    dio.options.headers['SOAPACTION'] =
        '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"';
    dio.options.headers['X-Auth-PSK'] = _psk;
    // dio.options.connectTimeout = TIMEOUT;
    final response = await dio.post('$_url/$path', data: JSON.stringify(json));
    // debug('$_host response $response ${response.data.runtimeType}');

    return response.data;
  }

  Future<List<dynamic>> getIRCCCodes() async {
    final result = await system.invoke('getRemoteControllerInfo');
    _codes = result[1];
    print('codes ${_codes.length}');
    for (var i=0; i<_codes.length; i++) {
      final code = _codes[i];
      print('code: ${code} ${code["name"]}');
    }
    return _codes;
  }
}
