// swift-tools-version: 5.9
// Swift Package Manager integration. The Rust library is consumed as a
// prebuilt xcframework; update it with `update_swift_package.sh`.

import PackageDescription

let package = Package(
    name: "tex_to_speech",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "tex-to-speech", targets: ["tex_to_speech"]),
    ],
    targets: [
        .binaryTarget(
            name: "tex_to_speech",
            url: "https://github.com/simpleclub/tex_to_speech_flutter/releases/download/RELEASE_TAG/tex_to_speech.xcframework.zip",
            checksum: "CHECKSUM"
        ),
    ]
)
