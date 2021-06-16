#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

GETDEPS="$(dirname "$0")/fbcode_builder/getdeps.py"
INSTALL_PREFIX="/opt/facebook"
PYTHON3=$(command -v python3)
PIP3=$(command -v pip3)
# shellcheck disable=SC2089
EXTRA_CMAKE_DEFINES='{"CMAKE_POSITION_INDEPENDENT_CODE": "ON", "BUILD_SHARED_LIBS": "ON", "CMAKE_C_COMPILER": "/usr/bin/gcc-10", "CMAKE_CXX_COMPILER": "/usr/bin/g++-10"}'

# shellcheck disable=SC2090
export GETDEPS INSTALL_PREFIX PYTHON3 PIP3 EXTRA_CMAKE_DEFINE LDFLAGS

errorCheck() {
  return_code=$?
  if [ $return_code -ne 0 ]; then
    echo "[ERROR]: $1"
    exit $return_code
  fi
}

if [ "$PYTHON3" == "" ]; then
  echo "ERROR: No \`python3\` in PATH"
  exit 1
fi

if [ "$PIP3" == "" ]; then
  echo "ERROR: No \`pip3\` in PATH"
  exit 2
fi
