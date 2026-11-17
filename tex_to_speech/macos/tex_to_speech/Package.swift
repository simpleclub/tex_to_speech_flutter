// swift-tools-version: 5.9
// Swift Package Manager integration. The Rust library is consumed as a
// prebuilt xcframework; update it with `update_swift_package.sh`.

import PackageDescription

let package = Package(
    name: "tex_to_speech",
    platforms: [
        .macOS("10.15"),
    ],
    products: [
        .library(name: "tex-to-speech", targets: ["tex_to_speech"]),
    ],
    targets: [
        .binaryTarget(
            name: "tex_to_speech",
            url: "https://github.com/simpleclub/tex_to_speech_flutter/releases/download/xcframework_c149097340b81c8c/tex_to_speech.xcframework.zip",
            checksum: "cba51b9a4b4af4cf523b2ffab8991ca5159643006a95cffef9ddafe62496c812"
        ),
    ]
)
