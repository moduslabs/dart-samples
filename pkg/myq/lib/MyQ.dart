///
/// MyQ class
///
/// Provides interface for interacting with MyQ devices (garage door openers and sensors)
///
library MyQ;

import 'package:debug/debug.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'dart:convert';
// import 'package:crypto/crypto.dart';

final debug = Debug('MyQ');

class MyQError implements Exception {
  String message;
  int code;

  MyQError(String message, String code) {
    this.message = message;
    this.code = MyQ.constants['codes'][code];
  }
}

const _authVersion = 'v5';
const _deviceVersion = 'v5.1';

class MyQ {
  // local variables
  var _securityToken, _accountId;
  List _devices;

  static const constants = {
    "codes": {
      "OK": 'OK',
      "INVALID_ARGUMENT": 'ERR_MYQ_INVALID_ARGUMENT',
      "LOGIN_REQUIRED": 'ERR_MYQ_LOGIN_REQUIRED',
      "AUTHENTICATION_FAILED": 'ERR_MYQ_AUTHENTICATION_FAILED',
      "AUTHENTICATION_FAILED_ONE_TRY_LEFT":
          'ERR_MYQ_AUTHENTICATION_FAILED_ONE_TRY_LEFT',
      "AUTHENTICATION_FAILED_LOCKED_OUT":
          'ERR_MYQ_AUTHENTICATION_FAILED_LOCKED_OUT',
      "DEVICE_NOT_FOUND": 'ERR_MYQ_DEVICE_NOT_FOUND',
      "DEVICE_STATE_NOT_FOUND": 'ERR_MYQ_DEVICE_STATE_NOT_FOUND',
      "INVALID_DEVICE": 'ERR_MYQ_INVALID_DEVICE',
      "SERVICE_REQUEST_FAILED": 'ERR_MYQ_SERVICE_REQUEST_FAILED',
      "SERVICE_UNREACHABLE": 'ERR_MYQ_SERVICE_UNREACHABLE',
      "INVALID_SERVICE_RESPONSE": 'ERR_MYQ_INVALID_SERVICE_RESPONSE',
    },
    "actions": {
      "door": {
        "open": 'open',
        "close": 'close',
      },
      "light": {
        "turnOn": 'turnon',
        "turnOff": 'turnoff',
      },
    },
    "stateAttributes": {
      "doorState": 'door_state',
      "lightState": 'light_state',
    },
    "baseUrls": {
      "auth": 'https: //api.myqdevice.com/api/${_authVersion}',
      "device": 'https: //api.myqdevice.com/api/${_deviceVersion}',
    },
    "routes": {
      "login": 'Login',
      "account": 'My',
      "getDevices": 'Accounts/{accountId}/Devices',
      "setDevice": 'Accounts/{accountId}/Devices/{serialNumber}/actions',
    },
    "headers": {
      'Content-Type': 'application/json',
      "MyQApplicationId":
          'JVM/G9Nwih5BwKgNCjLxiFUQxQijAebyyg8QUHr7JOrP+tuPb8iHfRHKwTmDzHOu',
      "ApiVersion": '5.2',
      "BrandId": '2',
      "Culture": 'en',
    },
  };

  static const actions = {
    "door": {
      "OPEN": 'open',
      "CLOSE": 'close',
    },
    "light": {
      "TURN_ON": 'turnOn',
      "TURN_OFF": 'turnOff',
    },
  };

  /// construct MyQ instance
  /// We use login() to establish connection
  constructor() {
    debug('construct myQ');
  }

  Future<Map<String, dynamic>> _executeServiceRequest(
      Map<String, dynamic> options) async {
    final mergedOptions = {
      ...options,
      "headers": {
        ...constants['headers'],
        "SecurityToken": _securityToken,
        ...options['headers']
      }
    };

    if (mergedOptions['headers']['User-Agent'] == null) {
      var random = Random.secure();
      var values = List<int>.generate(32, (i) => random.nextInt(256));
      // maybe use crypto here?
      mergedOptions['headers']['UserAgent'] = base64Url.encode(values);
    }

    var dio = Dio(BaseOptions(
      baseUrl: mergedOptions['baseUrl'],
      headers: mergedOptions['headers'],
      method: mergedOptions['method'],
    ));

    final response =
        await dio.request(mergedOptions['url'], data: mergedOptions['params']);
    return {"data": response.data};
  }

  Future<Map<String, dynamic>> _getAccountId() async {
    final Map<String, dynamic> getAccountServiceResponse =
        await this._executeServiceRequest({
      "baseUrl": constants['baseUrls']['auth'],
      "url": constants['routes']['account'],
      "method": 'get',
      "params": {"expand": 'account'}
    });

    if (getAccountServiceResponse == null ||
        getAccountServiceResponse['data'] == null ||
        getAccountServiceResponse['data'].Account == null ||
        getAccountServiceResponse['data'].Account.Id == null) {
      throw MyQError('Service did not return account ID in response',
          'INVALID_SERVICE_RESPONSE');
    }
    _accountId = getAccountServiceResponse['data'].Account.Id;
    return {"code": constants['codes']['OK'], "accountId": _accountId};
  }

  Future<Map<String, dynamic>> _getDeviceState(
      String serialNumber, String stateAttribute) async {
    //
    final Map<String, dynamic> getDeviceResult = await getDevice(serialNumber);

    if (getDeviceResult['device']['state'] == null) {
      throw MyQError(
          'State attribute "$stateAttribute" is not present on device',
          'DEVICE_STATE_NOT_FOUND');
    }
    return {
      "code": constants['codes']['OK'],
      "deviceState": getDeviceResult['device']['state'][stateAttribute]
    };
  }

  Future<Map<String, dynamic>> _setDeviceState(
      String serialNumber, String action, String stateAttribute) async {
    //
    final Map<String, dynamic> device = findDevice(serialNumber);

    if (device == null || device['state'][stateAttribute] == null) {
      throw MyQError('State attribute $stateAttribute is not present on device',
          constants['codes']['DEVICE_STATE_NOT_FOUND']);
    }

    if (_accountId == null) {
      await _getAccountId();
    }

    final String url = constants['routes']['setDevice'];

    await _executeServiceRequest({
      "baseUrl": constants['baseUrls']['device'],
      "url": url
          .replaceAll('{accountId}', _accountId)
          .replaceAll('{serialNumber}', serialNumber),
      "method": 'put',
      "data": {'action_type': action}
    });

    return {"code": 'OK'};
  }

  // await login(email, password)
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email == null || password == null) {
      throw MyQError(
          'MyQ.login email and password required', 'ERR_MYQ_LOGIN_REQUIRED');
    }
    final loginResponse = await _executeServiceRequest({
      "baseUrl": constants['baseUrls']['auth'],
      "url": constants['routes']['login'],
      "method": 'post',
      "headers": {
        "securityToken": null,
      },
      "data": {
        "Username": email,
        "Password": password,
      }
    });

    if (loginResponse == null ||
        loginResponse['data'] == null ||
        loginResponse['data'].SecurityToken == null) {
      throw MyQError(
          'Service did not return security token', 'INVALID_SERVICE_RESPONSE');
    }

    _securityToken = loginResponse['data'].SecurityToken;
    _accountId = null;
    _devices = [];

    return {
      "code": constants['codes']['OK'],
      "securityToken": _securityToken,
    };
  }

  Future<Map<String, dynamic>> getDevices() async {
    if (_accountId == null) {
      await _getAccountId();
    }

    final String url = constants['routes']['getDevices'];
    final getDevicesServiceResponse = await _executeServiceRequest({
      "baseUrl": constants['baseUrls']['device'],
      "url": url.replaceAll('{accountId)', _accountId),
      "method": 'get'
    });

    if (getDevicesServiceResponse == null ||
        getDevicesServiceResponse['data'] == null ||
        getDevicesServiceResponse['data'].items == null) {
      throw MyQError(
          'Service did not return valid devices', 'INVALID_SERVICE_RESPONSE');
    }

    _devices = getDevicesServiceResponse['data'].items;

    return {"code": constants['codes']['OK'], "devices": _devices};
  }

  Map<String, dynamic> findDevice(String serialNumber) {
    final device = _devices.firstWhere((device) {
      return device.serial_number == serialNumber;
    });
    return device;
  }

  Future<Map<String, dynamic>> getDevice(String serialNumber) async {
    await this.getDevices();
    final device = findDevice(serialNumber);

    if (device == null) {
      throw MyQError('Could not find device with serial number "$serialNumber"',
          'DEVICE_NOT_FOUND');
    }
    return {"code": constants['codes']['OK'], "device": device};
  }

  Future<Map<String, dynamic>> getDoorState(String serialNumber) async {
    try {
      return await this._getDeviceState(
          serialNumber, constants['stateAttributes']['doorState']);
    } catch (e) {
      if (e.code == constants['codes']['DEVICE_STATE_NOT_FOUND']) {
        throw MyQError(
            'device with serial number "$serialNumber" is not a door',
            'Invalid Device');
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> setDoorState(
      String serialNumber, String action) async {
    try {
      switch (action) {
        case 'open':
        case 'close':
          return await _setDeviceState(
              serialNumber, action, constants['stateAttributes']['doorState']);
        default:
          throw MyQError(
              'Invalid Action parameter "$action" specified for door; valid actions are open and close',
              constants['codes']['INVALID_ARGUMENT']);
      }
    } catch (e) {
      if (e.code == constants['codes']['DEVICE_STATE_NOT_FOUND']) {
        throw MyQError(
            'device with serial number "$serialNumber" is not a door',
            'Invalid Device');
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> setLightState(
      String serialNumber, String action) async {
    try {
      switch (action) {
        case 'turnOn':
        case 'turnOff':
          return await _setDeviceState(
              serialNumber, action, constants['stateAttributes']['lightState']);
        default:
          throw MyQError(
              'Invalid Action parameter "$action" specified for light; valid actions are turnOn and turnOff',
              constants['codes']['INVALID_ARGUMENT']);
      }
    } catch (e) {
      if (e.code == constants['codes']['DEVICE_STATE_NOT_FOUND']) {
        throw MyQError(
            'device with serial number "$serialNumber" is not a door',
            'Invalid Device');
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> getLightState(String serialNumber) async {
    try {
      return await this._getDeviceState(
          serialNumber, constants['stateAttributes']['lightState']);
    } catch (e) {
      if (e.code == constants['codes']['DEVICE_STATE_NOT_FOUND']) {
        throw MyQError(
            'device with serial number "$serialNumber" is not a light',
            'Invalid Device');
      }
      throw e;
    }
  }
}
