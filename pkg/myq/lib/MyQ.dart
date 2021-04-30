///
/// MyQ class
///
/// Provides interface for interacting with MyQ devices (garage door openers and sensors)
///
library MyQ;

import 'package:debug/debug.dart';

final debug = Debug('MyQ');

class MyQ {
  // local variables
  var _securityToken, _account_id, _devices;

  /// construct MyQ instance
  /// We use login() to establish connection
  constructor() {
    debug('construct myQ');
  }

  // await login(email, password)
  void login(String email, String password) async {
    if (email == null || password == null) {
      throw 'MyQ.login email and password required';
    }

  }
}