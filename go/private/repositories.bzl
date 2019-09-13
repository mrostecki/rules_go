# Copyright 2014 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Once nested repositories work, this file should cease to exist.

load("@io_bazel_rules_go//go/private:common.bzl", "MINIMUM_BAZEL_VERSION")
load("@io_bazel_rules_go//go/private:compat/compat_repo.bzl", "go_rules_compat")
load("@io_bazel_rules_go//go/private:skylib/lib/versions.bzl", "versions")
load("@io_bazel_rules_go//go/private:nogo.bzl", "DEFAULT_NOGO", "go_register_nogo")
load("@io_bazel_rules_go//go/platform:list.bzl", "GOOS_GOARCH")
load("@io_bazel_rules_go//proto:gogo.bzl", "gogo_special_proto")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# master, as of 2019-03-03
GOLANG_X_TOOLS_COMMIT = "589c23e65e65055d47b9ad4a99723bc389136265"
GOLANG_X_TOOLS_SHA = "2d78895bf626de1fd750d7ce90d092b5c909d75a623af7049234bd42d4f103d9"

GOLANG_PROTOBUF_RELEASE = "1.3.0"
GOLANG_PROTOBUF_SHA = "f44cfe140cdaf0031dac7d7376eee4d5b07084cce400d7ecfac4c46d33f18a52"

BAZEL_SKYLIB_RELEASE = "0.7.0"
BAZEL_SKYLIB_SHA = "2c62d8cd4ab1e65c08647eb4afe38f51591f43f7f0885e7769832fa137633dcb"

PROTOBUF_RELEASE = "3.7.0"
PROTOBUF_SHA = "a19dcfe9d156ae45d209b15e0faed5c7b5f109b6117bfc1974b6a7b98a850320"

# master, as of 2019-03-03
GO_PROTO_VALIDATORS_COMMIT = "1f388280e944c97cc59c75d8c84a704097d1f1d6"
GO_PROTO_VALIDATORS_SHA = "ad2e28b8a0a1c3fcf6dc1c22eba2204e2a6bc822a6d4cab543a233c62e5a85b7"

GOGO_PROTOBUF_RELEASE = "1.2.1"
GOGO_PROTOBUF_SHA = "99e423905ba8921e86817607a5294ffeedb66fdd4a85efce5eb2848f715fdb3a"

# master, as of 2019-03-3
GOLANG_X_NET_COMMIT = "16b79f2e4e95ea23b2bf9903c9809ff7b013ce85"
GOLANG_X_NET_SHA = "916d7b42140ec92fc85f67a58cf10c0ce3feec468ae1f919ff22720844731be6"

# v0.3.0, latest as of 2019-03-03
GOLANG_X_TEXT_COMMIT = "f21a4dfb5e38f5895301dc265a8def02365cc3d0"
GOLANG_X_TEXT_SHA = "339419ef0264faa388f9d20fc66025a896f32dfc9d6acec3ec83591870de2de4"

# master, as of 2019-03-03
GOLANG_X_SYS_COMMIT = "d455e41777fca6e8a5a79e34a14b8368bc11d9ba"
GOLANG_X_SYS_SHA = "ed157d9ceeb5f12c59eb9cd821fccb7bff4d68c12d0e17369e2d2906e4b5fdd5"

GRPC_GO_RELEASE = "1.19.0"
GRPC_GO_SHA = "299e274bb6f514f2bbfcbe067b65f5cc1fcfe5c4878ca1a05af2142169711c0a"

# master, as of 2019-03-03
GO_GENPROTO_COMMIT = "4f5b463f9597cbe0dd13a6a2cd4f85e788d27508"
GO_GENPROTO_SHA = "687c8d929e562d01d2fbba886d21ca32c86d8f12268f9cf58fd5fb4ec6d1d1c5"

# master, as of 2019-03-03
GOOGLEAPIS_COMMIT = "41d72d444fbe445f4da89e13be02078734fb7875"
GOOGLEAPIS_SHA = "76c3286f238e7123229da9efe424bb597390d1d46bbc5b22ebc4795143d646a3"

# master as of 2019-03-03
GLOG_COMMIT = "23def4e6c14b4da8ac2ed8007337bc5eb5007998"
GLOG_SHA = "ef225f77e38c3f071656a5bc529d7a66585e2ebc2b6149fa2bd4de1fb1ddacd6"

GO_BINDATA_RELEASE = "3.13.0"
GO_BINDATA_SHA = "16d23471f8b092d36261fc6b162e4cc30b245bf3b9c28b0f548788e6180a5729"

def go_rules_dependencies():
    """See /go/workspace.rst#go-rules-dependencies for full documentation."""
    if getattr(native, "bazel_version", None):
        versions.check(MINIMUM_BAZEL_VERSION, bazel_version = native.bazel_version)

    # Compatibility layer, needed to support older versions of Bazel.
    _maybe(
        go_rules_compat,
        name = "io_bazel_rules_go_compat",
    )

    # Needed for nogo vet checks and go/packages.
    _maybe(
        http_archive,
        name = "org_golang_x_tools",
        sha256 = GOLANG_X_TOOLS_SHA,
        strip_prefix = "tools-" + GOLANG_X_TOOLS_COMMIT,
        urls = ["https://github.com/golang/tools/archive/" + GOLANG_X_TOOLS_COMMIT + ".tar.gz"],
        patches = [
            "@io_bazel_rules_go//third_party:org_golang_x_tools-gazelle.patch",
            "@io_bazel_rules_go//third_party:org_golang_x_tools-extras.patch",
        ],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/tools
    )

    # Proto dependencies
    _maybe(
        http_archive,
        name = "com_github_golang_protobuf",
        sha256 = GOLANG_PROTOBUF_SHA,
        strip_prefix = "protobuf-" + GOLANG_PROTOBUF_RELEASE,
        urls = ["https://github.com/golang/protobuf/archive/v" + GOLANG_PROTOBUF_RELEASE + ".tar.gz"],
        patches = [
            "@io_bazel_rules_go//third_party:com_github_golang_protobuf-gazelle.patch",
            "@io_bazel_rules_go//third_party:com_github_golang_protobuf-extras.patch",
        ],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix github.com/golang/protobuf -proto disable_global
    )

    # bazel_skylib is a dependency of com_google_protobuf.
    # Nothing in rules_go may depend on bazel_skylib, since it won't be declared
    # when go/def.bzl is loaded. The vendored copy of skylib in go/private/skylib
    # may be used instead.
    _maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = BAZEL_SKYLIB_SHA,
        strip_prefix = "bazel-skylib-" + BAZEL_SKYLIB_RELEASE,
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/" + BAZEL_SKYLIB_RELEASE + ".tar.gz"],
    )

    _maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = PROTOBUF_SHA,
        strip_prefix = "protobuf-" + PROTOBUF_RELEASE,
        urls =  ["https://github.com/protocolbuffers/protobuf/archive/v" + PROTOBUF_RELEASE + ".tar.gz"],
    )
    # Workaround for protocolbuffers/protobuf#5472
    # At master, they provide a macro that creates this dependency. We can't
    # load it from here though.
    if "net_zlib" not in native.existing_rules():
        native.bind(
            name = "zlib",
            actual = "@net_zlib//:zlib",
        )
        http_archive(
            name = "net_zlib",
            build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
            sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
            strip_prefix = "zlib-1.2.11",
            urls = ["https://zlib.net/zlib-1.2.11.tar.gz"],
        )

    _maybe(
        http_archive,
        name = "com_github_mwitkow_go_proto_validators",
        sha256 = GO_PROTO_VALIDATORS_SHA,
        strip_prefix = "go-proto-validators-" + GO_PROTO_VALIDATORS_COMMIT,
        urls = ["https://github.com/mwitkow/go-proto-validators/archive/" + GO_PROTO_VALIDATORS_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:com_github_mwitkow_go_proto_validators-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix github.com/mwitkow/go-proto-validators -proto disable
    )

    _maybe(
        http_archive,
        name = "com_github_gogo_protobuf",
        sha256 = GOGO_PROTOBUF_SHA,
        strip_prefix = "protobuf-" + GOGO_PROTOBUF_RELEASE,
        urls = ["https://github.com/gogo/protobuf/archive/v" + GOGO_PROTOBUF_RELEASE + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:com_github_gogo_protobuf-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix github.com/gogo/protobuf -proto legacy
    )

    _maybe(
        gogo_special_proto,
        name = "gogo_special_proto",
    )

    # GRPC dependencies
    _maybe(
        http_archive,
        name = "org_golang_x_net",
        sha256 = GOLANG_X_NET_SHA,
        strip_prefix = "net-" + GOLANG_X_NET_COMMIT,
        urls = ["https://github.com/golang/net/archive/" + GOLANG_X_NET_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:org_golang_x_net-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/net
    )

    _maybe(
        http_archive,
        name = "org_golang_x_text",
        sha256 = GOLANG_X_TEXT_SHA,
        strip_prefix = "text-" + GOLANG_X_TEXT_COMMIT,
        urls = ["https://github.com/golang/text/archive/" + GOLANG_X_TEXT_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:org_golang_x_text-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/text
    )
    _maybe(
        http_archive,
        name = "org_golang_x_sys",
        sha256 = GOLANG_X_SYS_SHA,
        strip_prefix = "sys-" + GOLANG_X_SYS_COMMIT,
        urls = ["https://github.com/golang/sys/archive/" + GOLANG_X_SYS_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:org_golang_x_sys-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix golang.org/x/sys
    )

    _maybe(
        http_archive,
        name = "org_golang_google_grpc",
        sha256 = GRPC_GO_SHA,
        strip_prefix = "grpc-go-" + GRPC_GO_RELEASE,
        urls = ["https://github.com/grpc/grpc-go/archive/v" + GRPC_GO_RELEASE + ".tar.gz"],
        patches = [
            "@io_bazel_rules_go//third_party:org_golang_google_grpc-gazelle.patch",
            "@io_bazel_rules_go//third_party:org_golang_google_grpc-crosscompile.patch",
        ],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix google.golang.org/grpc -proto disable
    )

    _maybe(
        http_archive,
        name = "org_golang_google_genproto",
        sha256 = GO_GENPROTO_SHA,
        strip_prefix = "go-genproto-" + GO_GENPROTO_COMMIT,
        urls = ["https://github.com/google/go-genproto/archive/" + GO_GENPROTO_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:org_golang_google_genproto-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix google.golang.org/genproto -proto disable_global
    )

    _maybe(
        http_archive,
        name = "go_googleapis",
        sha256 = GOOGLEAPIS_SHA,
        strip_prefix = "googleapis-" + GOOGLEAPIS_COMMIT,
        urls = ["https://github.com/googleapis/googleapis/archive/" + GOOGLEAPIS_COMMIT + ".tar.gz"],
        patches = [
            "@io_bazel_rules_go//third_party:go_googleapis-deletebuild.patch",
            "@io_bazel_rules_go//third_party:go_googleapis-directives.patch",
            "@io_bazel_rules_go//third_party:go_googleapis-gazelle.patch",
            "@io_bazel_rules_go//third_party:go_googleapis-fix.patch",
        ],
        patch_args = ["-E", "-p1"],
    )

    # Needed for examples
    _maybe(
        http_archive,
        name = "com_github_golang_glog",
        sha256 = GLOG_SHA,
        strip_prefix = "glog-" + GLOG_COMMIT,
        urls = ["https://github.com/golang/glog/archive/" + GLOG_COMMIT + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:com_github_golang_glog-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix github.com/golang/glog
    )
    _maybe(
        http_archive,
        name = "com_github_kevinburke_go_bindata",
        sha256 = GO_BINDATA_SHA,
        strip_prefix = "go-bindata-" + GO_BINDATA_RELEASE,
        urls = ["https://github.com/kevinburke/go-bindata/archive/v" + GO_BINDATA_RELEASE + ".tar.gz"],
        patches = ["@io_bazel_rules_go//third_party:com_github_kevinburke_go_bindata-gazelle.patch"],
        patch_args = ["-p1"],
        # gazelle args: -go_prefix github.com/kevinburke/go-bindata
    )

    # This may be overridden by go_register_toolchains, but it's not mandatory
    # for users to call that function (they may declare their own @go_sdk and
    # register their own toolchains).
    _maybe(
        go_register_nogo,
        name = "io_bazel_rules_nogo",
        nogo = DEFAULT_NOGO,
    )

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
