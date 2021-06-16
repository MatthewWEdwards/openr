# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import os
from subprocess import Popen

thrift_files = []
procs = []
cydirs = ["/thrift", "/folly", "openr-thrift", "fbthrift-thrift", "fbzmq-thrift", "fb303-thrift"]
for d in cydirs:
    for root, _dirs, files in os.walk(d):
        if "test" in root:
            continue
        for f in files:
            if f.endswith(".pyx"):
                thrift_file = os.path.join(root, f)
                cmd = [
                    "cython3",
                    "--fast-fail",
                    "-3",
                    "--cplus",
                    thrift_file,
                    "-o",
                    root,
                    "-I.",
                    "-I/src",
                    "-I/usr/lib/python3/dist-packages/Cython/Includes",
                    "-I/",
                    "-I/src/fbthrift-thrift/gen-py3",
                    "-I/src/fb303-thrift/fb303/thrift/gen-py3",
                    "-I/src/fbzmq-thrift/fbzmq/service/if/gen-py3",
                    "-I/opt/facebook/folly/python/include",
                ]
                print(f"Generating cython module {f}")
                procs += [Popen(cmd)]

print("Waiting for cython generation to finish...")
failures = 0
for proc in procs:
    proc.wait()
    if proc.returncode != 0:
        failures += 1
print(f"{len(procs) - failures}/{len(procs)} succeeded")
