FROM arm64v8/ubuntu:focal

# Install tools needed for development
RUN apt update && \
    apt upgrade --yes && \
    apt install --yes \
	build-essential \
	cython3 \
	git \
	libssl-dev \
	m4 \
	python3-pip \
	g++-10 \
	rsync


# Copy needed source
RUN mkdir /src
ADD CMakeLists.txt FBGenCMakeBuildInfo.cmake ThriftLibrary.cmake /src/
COPY build /src/build
COPY openr /src/openr

# Apply patches
RUN cd /src && build/fetch.sh
RUN cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-folly.git; \
	git apply /src/build/patches/folly.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbzmq.git; \
	git apply /src/build/patches/fbzmq.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbthrift.git; \
	git apply /src/build/patches/fbthrift.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-openr.git; \
	git apply /src/build/patches/openr.patch

# Build OpenR + Dependencies via cmake
RUN cd /src && build/build_openr.sh || :

# Install `breeze` OpenR CLI
RUN cd /src && build/build_breeze.sh || :

CMD ["/opt/bin/docker_openr_helper.sh"]
# Expose OpenR Thrift port
EXPOSE 2018/tcp
