#!/usr/bin/env python3
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import os
import glob
import re
from subprocess import Popen
import sys

thrift_libs = [
    "-lopenrctrlcppclients",
    "-lopenrctrlclients",
    "-lopenrplatformclients",
    "-lfb303clientswrapper", 
    "-lfb303serviceswrapper", 
]

def get_call(object_file, shared_object, extralibs=()):
    cmd = [
        "/usr/bin/g++-10",
        "-pthread",
        "-shared",
        "-Wl,-O2",
        "-Wl,-Bsymbolic-functions",
        "-Wl,-z,relro",
        "-g",
        "-fwrapv",
        "-O2",
        object_file,
        f"-L{glob.glob('/opt/facebook/boost-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/double-conversion-*/lib')[0]}",
        "-L/root/fbthrift_lib/",
        "-L/opt/facebook/fbthrift/lib",
        "-L/opt/facebook/fizz/lib",
        "-L/opt/facebook/fbzmq/lib",
        f"-L{glob.glob('/opt/facebook/fmt-*/lib')[0]}",
        "-L/opt/facebook/folly/lib",
        f"-L{glob.glob('/opt/facebook/gflags-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/glog-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/libevent-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/libsodium-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/lz4-*/lib')[0]}",
        f"-L{glob.glob('/opt/facebook/snappy-*/lib')[0]}",
        "-L/opt/facebook/wangle/lib/",
        f"-L{glob.glob('/opt/facebook/zstd-*/lib')[0]}",
        "-L/src/build/lib.linux-aarch64-3.8",
        "-L/tmp/fbcode_builder_getdeps-ZsrcZbuildZfbcode_builder-root/build/openr",
        "-L/opt/facebook/openr/lib",
        "-L/usr/lib/",
        "-L/libs/",
        "-Wl,--start-group",
        "-lalloc_prefix_cpp2",
        "-lbgp_config_cpp2",
        "-ldecision_cpp2",
        "-ldual_cpp2",
        "-lfib_cpp2",
        "-lkv_store_cpp2",
        "-llink_monitor_cpp2",
        "-llsdb_cpp2",
        "-lnetwork_cpp2",
        "-lopenr_config_cpp2",
        "-lopenr_ctrl_cpp2",
        "-lopenr_ctrl_cpp_cpp2",
        "-lpersistent_store_cpp2",
        "-lplatform_cpp2",
        "-lprefix_manager_cpp2",
        "-lspark_cpp2",
        "-lasync",
        "-lboost_atomic",
        "-lboost_chrono",
        "-lboost_container",
        "-lboost_context",
        "-lboost_contract",
        "-lboost_coroutine",
        "-lboost_date_time",
        "-lboost_exception",
        "-lboost_fiber",
        "-lboost_filesystem",
        "-lboost_graph",
        "-lboost_iostreams",
        "-lboost_locale",
        "-lboost_log",
        "-lboost_log_setup",
        "-lboost_math_c99",
        "-lboost_math_c99f",
        "-lboost_math_c99l",
        "-lboost_math_tr1",
        "-lboost_math_tr1f",
        "-lboost_math_tr1l",
        "-lboost_prg_exec_monitor",
        "-lboost_program_options",
        "-lboost_random",
        "-lboost_regex",
        "-lboost_serialization",
        "-lboost_stacktrace_addr2line",
        "-lboost_stacktrace_backtrace",
        "-lboost_stacktrace_basic",
        "-lboost_stacktrace_noop",
        "-lboost_system",
        "-lboost_test_exec_monitor",
        "-lboost_thread",
        "-lboost_timer",
        "-lboost_type_erasure",
        "-lboost_unit_test_framework",
        "-lboost_wave",
        "-lboost_wserialization",
        "-lbuild_info",
        "-lcompiler_ast",
        "-lcompiler_base",
        "-lcompiler_generate_templates",
        "-lcompiler_generators",
        "-lcompiler_lib",
        "-lconcurrency",
        "-ldouble-conversion",
        "-levent",
        "-levent_core",
        "-levent_extra",
        "-lfizz",
        "-lfmt",
        "-lfolly",
        "-lfolly_test_util",
        "-lfollybenchmark",
        "-lfbzmq",
        "-lglog",
        "-llz4",
        "-lmustache_lib",
        "-lopenrlib",
        "-lprotocol",
        "-lrpcmetadata",
        "-lsnappy",
        "-lsodium",
        "-lthrift-core",
        "-lthriftcpp2",
        "-lthriftfrozen2",
        "-lthriftmetadata",
        "-lthriftprotocol",
        "-ltransport",
        "-lwangle",
        "-lz",
        "-lzstd",
        *extralibs,
        "-Wl,--end-group",
        "-o",
        shared_object,
    ]
    return cmd

# Build thrift libs 
thrift_lib_paths = {
    "/src/build/temp.linux-aarch64-3.8/openr-thrift/openr/if/gen-py3/OpenrCtrl/clients_wrapper.o": "/libs/libopenrctrlclients.so",
    "/src/build/temp.linux-aarch64-3.8/openr-thrift/openr/if/gen-py3/OpenrCtrlCpp/clients_wrapper.o": "/libs/libopenrctrlcppclients.so",
    "/src/build/temp.linux-aarch64-3.8/openr-thrift/openr/if/gen-py3/Platform/clients_wrapper.o": "/libs/libopenrplatformclients.so",
    "/src/build/temp.linux-aarch64-3.8/fb303-thrift/fb303/thrift/gen-py3/fb303_core/clients_wrapper.o": "/libs/libfb303clientswrapper.so",
    "/src/build/temp.linux-aarch64-3.8/fb303-thrift/fb303/thrift/gen-py3/fb303_core/services_wrapper.o": "/libs/libfb303serviceswrapper.so",
}

procs = []
for object_file, shared_object in thrift_lib_paths.items():
    cmd = get_call(object_file, shared_object)
    procs += [Popen(cmd)]
print("Linking wrappers...")
failures = 0
for proc in procs:
    proc.wait()
    if proc.returncode != 0:
        failures += 1
if failures == 0:
    print(f"Wrapper linking succeeded")
else:
    sys.exit(1)

procs = []
object_dirs = ["/thrift", "/folly", "openr-thrift", "fbzmq-thrift", "fb303-thrift"]
for o in object_dirs:
    for root, _dirs, files in os.walk(f"/src/build/temp.linux-aarch64-3.8/{o}"):
        for f in files:
            if f.endswith(".o"):
                object_file = os.path.join(root, f)
                shared_object = re.sub(r".*gen-py3.", "", object_file
                    .replace('temp.linux', 'lib.linux') .replace(".o", ".cpython-38-aarch64-linux-gnu.so"))
                if "lib.linux-aarch64-3.8" not in shared_object:
                    shared_object = "/src/build/lib.linux-aarch64-3.8/" + shared_object
                cmd = get_call(object_file, shared_object, thrift_libs)
                print(" ".join(cmd))
                procs += [Popen(cmd)]

print("Waiting for linking to finish...")
failures = 0
for proc in procs:
    proc.wait()
    if proc.returncode != 0:
        failures += 1
print(f"{len(procs) - failures}/{len(procs)} succeeded")

