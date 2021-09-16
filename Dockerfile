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
	rsync \
	zip 

# Copy needed source
RUN mkdir /src
ADD CMakeLists.txt FBGenCMakeBuildInfo.cmake ThriftLibrary.cmake /src/
COPY build /src/build
COPY openr /src/openr

# Apply fbcode_builder patches
RUN cd /src && build/fetch.sh
RUN cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-folly.git; \
	git apply /src/build/patches/folly.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbzmq.git; \
	git apply /src/build/patches/fbzmq.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-fbthrift.git; \
	git apply /src/build/patches/fbthrift.patch; \
    cd /tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/repos/github.com-facebook-openr.git; \
	git apply /src/build/patches/openr.patch

# Apply Open/R patches
COPY patches /src/openr/patches
RUN cd /src; \
    git init; \
	git config user.name "someone"; \
	git config user.email "someone@someplace.com"; \
    git remote add origin https://github.com/facebook/openr; \
	git fetch origin master; \
	git reset --soft 4fba53eed4622b8576bd72156e20878ef6d18bc3; \
	git add openr; \
	git commit -m "foo"; \
    find openr/patches -type f -exec git am {} \;

# Build OpenR + Dependencies via cmake
RUN cd /src && build/build_openr.sh || :

# Install `breeze` OpenR CLI
RUN cd /src && build/build_breeze.sh || :

RUN cd /src && build/package_breeze.sh || :

CMD ["/opt/bin/docker_openr_helper.sh"]
# Expose OpenR Thrift port
EXPOSE 2018/tcp
