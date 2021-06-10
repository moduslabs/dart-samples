# FFI samples

These sample programs demonstrate Dart FFI features/functionality.

## Shared libraries

Each FFI sample program requires a shared library (.dylib on mac, .dll on Windows, .so on Linux) to be built.  The purpose of FFI is to call into these shared libraries from Dart.  The build-all.sh script will build all the libraries for you.

The C++ compiler will mangle method names so you cannot reliably call these C++ methods from Dart.  What you need to do
is to use something like the following to force the compiler/linker to not mangle specific variables or functions.

```
extern "C"  {
  <T> <function_name>(<args>);
};
```

## Running the samples
If you built all the libraries with build-all.sh, you simply cd into a <sample> directory and run the sample: 

```
# dart run <sample>.dart # where sample is the name of the .dart file in the sample directory.
```

If you did not build the libraries with build-all.sh, you cd into the <sample>/<sample>_lib directory and run:

```
# cmake .
# make
# cd .. # go to the <sample> directory
```

Then run the <sample>.dart program from the directory at <sample>:

```
# dart run <sample>.dart # where sample is the name of the .dart file in the sample directory.
```

## Current FFI samples:

*  callbacks/ - this sample is the minimal library and Dart code to pass a Dart function as an argument to a "C"
   function and have the "C" function call that Dart function.
   
*  opaque/ - this sample demonstrates the use of the Opaque Dart class.  It exposes a few ncurses library methods to
   Dart.
   
   



