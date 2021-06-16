mkdir /dist

# openr
mkdir /dist/openr
cp -r /src/build/lib.linux-aarch64-3.8/openr/py/openr/* /dist/openr
cp -r /src/build/lib.linux-aarch64-3.8/openr/thrift/ /dist/openr/thrift
cp -r /src/openr-thrift/openr/if/gen-py/openr/* /dist/openr

# folly
mkdir /dist/folly
cp -r /src/build/lib.linux-aarch64-3.8/folly/* /dist/folly

# thrift
mkdir /dist/thrift
cp -r /src/build/lib.linux-aarch64-3.8/thrift/* /dist/thrift

# fbthrift
mkdir /dist/fbthrift
rsync -a /src/build/lib.linux-aarch64-3.8/fbthrift-thrift/gen-py3/ /dist/fbthrift/
rsync -a /src/fbthrift-thrift/gen-py/ /dist/fbthrift/

# fbzmq
mkdir /dist/fbzmq
rsync -a /src/fbzmq-thrift/fbzmq/service/if/gen-py/fbzmq/ /dist/fbzmq/
rsync -a /src/build/lib.linux-aarch64-3.8/fbzmq-thrift/fbzmq/service/if/gen-py3/fbzmq/ /dist/fbzmq/

# fb303
mkdir /dist/fb303_core
rsync -a /src/build/lib.linux-aarch64-3.8/fb303-thrift/fb303/thrift/gen-py3/fb303_core/ /dist/fb303_core/
rsync -a /src/fb303-thrift/fb303/thrift/gen-py/fb303_core/ /dist/fb303_core/

