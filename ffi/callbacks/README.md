# callbacks

This sample demonstrates how a Dart program can pass a Dart method to "C" code and have that "C" code call back that
function.

***Warning!*** This is a synchronous example.  The Dart runtime is similar to NodeJS in that it has an event loop.  If
you call a "C" function that takes a long time, as our example does, the event loop does not run!

If you want to do asynchronous callbacks, you will need to use a much more complex bit of code.  See [this
issue](https://github.com/dart-sdk/issues/37022) on GitHub.

