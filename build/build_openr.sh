#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh"

rm -r /usr/bin/c++ /usr/bin/cc
ln -sf $(which g++-10) /usr/bin/c++
ln -sf $(which gcc-10) /usr/bin/cc

errorCheck "Failed to build openr"
"$PYTHON3" "$GETDEPS" --allow-system-packages build --no-tests --install-prefix "$INSTALL_PREFIX" \
--extra-cmake-defines "$EXTRA_CMAKE_DEFINES" openr
errorCheck "Failed to build openr"

# TODO: Maybe fix src-dir to be absolute reference to dirname $0's parent
"$PYTHON3" "$GETDEPS" fixup-dyn-deps --strip --src-dir=. openr _artifacts/linux  --project-install-prefix openr:"$INSTALL_PREFIX" --final-install-prefix "$INSTALL_PREFIX" 
errorCheck "Failed to fixup-dyn-deps for openr"
