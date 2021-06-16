#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh"

"$PYTHON3" "$GETDEPS" fetch fbzmq
"$PYTHON3" "$GETDEPS" fetch fbthrift
"$PYTHON3" "$GETDEPS" fetch folly
"$PYTHON3" "$GETDEPS" fetch openr
