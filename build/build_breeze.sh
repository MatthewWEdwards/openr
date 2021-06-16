#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh"

alias thrift1=/opt/facebook/fbthrift/bin/thrift1

# Step 1: Stage compilation

# folly Cython
mkdir /folly
cp -r \
/tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-folly.git/folly/python/* /folly

# fb303 thrift
mkdir -p ./fb303-thrift
cp -r  /opt/facebook/fb303/include/thrift-files/fb303 ./fb303-thrift/

# fbzmq thrift
mkdir -p ./fbzmq-thrift/fbzmq
cp -r  /opt/facebook/fbzmq/include/fbzmq/service ./fbzmq-thrift/fbzmq/

# fbthrift Cython and thrift
mkdir -p /thrift/py3/
cp /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbthrift.git/thrift/lib/py3/* /thrift/py3
touch /thrift/py3/__init__.py
touch /thrift/__init__.py
sed -i "s/_ssl_timeout_ms,//g" /thrift/py3/client.pyx
sed -i "s/ssl_context._cpp_obj,//g" /thrift/py3/client.pyx
sed -i "s/thrift_ssl.createThriftChannelTCP(/createThriftChannelTCP(/g" /thrift/py3/client.pyx

mkdir /src/fbthrift-thrift
cp -r \
/tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbthrift.git/thrift/lib/thrift/* \
/src/fbthrift-thrift

# Open/R thrift
mkdir -p ./openr-thrift/openr
cp -r /src/openr/if/ ./openr-thrift/openr/

# Step 2. Generate mstch_cpp2 and mstch_py3 bindings

python3 /src/build/gen.py

# XXX HACK TO FIX fbthrift-py/gen-cpp2/
echo " " > /src/fbthrift-thrift/gen-cpp2/metadata_metadata.h
echo " " > /src/fbthrift-thrift/gen-cpp2/metadata_types.h
echo " " > /src/fbthrift-thrift/gen-cpp2/metadata_types_custom_protocol.h

# Step 3. Generate clients.cpp

python3 /src/build/cython_compile.py

# XXX HACK to fix folly python namespacing
# Can probably just use
# /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-folly.git/folly/python
# instead

mkdir -p /folly/python
cp -r /folly/* /folly/python

# Step 4. Compile .so
# XXX HACK fix compilation
find /opt/facebook/folly/include/ -type f -exec sed -i "s/std::experimental/std/g" {} \;
find /opt/facebook/folly/include/ -type f -exec sed -i "s/experimental\/corou/corou/g" {} \;
sed -i "s/elif __cpp_coroutines >= 201703L/elif 1 \/\//g" /opt/facebook/folly/include/folly/Portability.h
sed -Ei "s/(.*)namespace experimental/\/\/\1namespace experimental/g" /opt/facebook/folly/include/folly/Expected.h
sed -Ei "s/(.*)namespace experimental/\/\/\1namespace experimental/g" /opt/facebook/folly/include/folly/Optional.h
sed -i "s/if ((co_await/if (((folly::CancellationToken) co_await/g" /opt/facebook/fbthrift/include/thrift/lib/cpp2/async/ClientBufferedStream.h

# shellcheck disable=SC2097,SC2098
CC="/usr/bin/gcc-10" \
CXX="/usr/bin/g++-10" \
CFLAGS="-I. -Iopenr-thrift -Ifb303-thrift -Ifbzmq-thrift -std=c++20 -fcoroutines" \
CFLAGS="$CFLAGS -w -D_CPPLIB_VER=20" \
CXXFLAGS="$CFLAGS" \
python3 openr/py/setup.py build -j20

mkdir /libs/

python3 /src/build/link.py

/src/build/package_breeze.sh
