#!/bin/sh

echo "This builds all the libraries for the ffi samples"

HERE=$PWD

cd callbacks/callbacks_library
cmake . 
make

cd $HERE
cd opaque/opaque_library
cmake . 
make

cd $HERE
echo "built libraries"
"
