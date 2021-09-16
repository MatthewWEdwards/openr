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

# Get libs
mkdir /libs
cp /opt/facebook/folly/lib/libfolly.so /libs
cp /opt/facebook/double-conversion-na1iUH4Y-SMPmjD4MThegWPJy8IYafWCAQ5wHi9x5B8/lib/libdouble-conversion.so.3 /libs
cp /opt/facebook/lz4-PrjmY6L7hyfO15GNxaHFntInnNDHxafu2d6ytQyEKm0/lib/liblz4.so.1 /libs
cp /opt/facebook/boost-71WJuq3HiaXTDMgav3FARJHe9PTgpMwsHURNDTVdDH8/lib/libboost_filesystem.so.1.69.0 /libs
cp /opt/facebook/boost-71WJuq3HiaXTDMgav3FARJHe9PTgpMwsHURNDTVdDH8/lib/libboost_context.so.1.69.0 /libs
cp /opt/facebook/boost-71WJuq3HiaXTDMgav3FARJHe9PTgpMwsHURNDTVdDH8/lib/libboost_regex.so.1.69.0 /libs
cp /opt/facebook/boost-71WJuq3HiaXTDMgav3FARJHe9PTgpMwsHURNDTVdDH8/lib/libboost_program_options.so.1.69.0 /libs

# Strip
find /dist -type f -exec strip {} \;
find /libs -type f -exec strip {} \;

# Package
zip -r dist.zip /dist
zip -r libs.zip /libs
mkdir /packages
mv dist.zip /packages
mv libs.zip /packages
