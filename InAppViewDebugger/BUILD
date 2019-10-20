load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_static_framework",
)
load(
    "@build_bazel_rules_apple//apple:resources.bzl",
    "apple_resource_bundle",
)
load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)

apple_resource_bundle(
    name = "Assets",
    resources = glob([
        "Assets.xcassets/**",
    ]),
)

swift_library(
    name = "InAppViewDebugger",
    srcs = glob([
        "*.swift",
    ]),
    data = [
        ":Assets",
    ],
    module_name = "InAppViewDebugger",
)

ios_static_framework(
    name = "InAppViewDebuggerFramework",
    bundle_name = "InAppViewDebugger",
    minimum_os_version = "11.0",
    deps = [
        ":InAppViewDebugger",
    ],
)
