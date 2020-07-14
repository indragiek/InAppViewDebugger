// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "InAppViewDebugger",
    platforms: [
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "InAppViewDebugger",
            targets: ["InAppViewDebugger"]),
    ],
    targets: [
        .target(
            name: "InAppViewDebugger",
            dependencies: [],
            path: "InAppViewDebugger",
	    exclude: ["Info.plist", "BUILD"]
        ),
    ]
)
