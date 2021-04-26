/*
 * StatefulEmitter class
 *
 * This is an EventEmitter that supports a React-like state member and
 * setState() method.
 *
 * When setState() is called with a new state object, a statechange event
 * is emitted with oldState as arguments.  Callback can see newState by examining
 * the state member
 */
import 'package:eventify/eventify.dart';

class StatefulEmitter extends EventEmitter {
  Object _state = {};

  // constructor
  StatefulEmitter() {}

  // alias un to off
  void un(Listener listener) {
    off(listener);
  }

  // setter for state
  void set state(newState) {
    var oldState = _state;
    _state = newState;
    emit('statechange', null, oldState );
  }

  // getter for state
  Object get state {
    return _state;
  }

  // React style setState (same as state setter)
  void setState(newState) {
    state = newState;
  }
}