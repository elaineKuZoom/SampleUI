// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "SampleUI",
  defaultLocalization: "en",
  platforms: [.iOS(.v13)],
  products: [.library(name: "SampleUI", targets: ["SampleUI"])],
  targets: [
    .binaryTarget(
      name: "ZoomVideoSDK",
      url: "https://github.com/zoom/videosdk-ios/releases/download/v2.3.5/ZoomVideoSDK.xcframework.zip",
      checksum: "c938845ca649bdc0fc10870606d03acb5d35eedde8b4d3ab2ae970738ac3c07b"
    ),
    .binaryTarget(
      name: "CptShare",
      url: "https://github.com/zoom/videosdk-ios/releases/download/v2.3.5/CptShare.xcframework.zip",
      checksum: "543ce99bdc5925f2db803782f8d95c6754a2beee5c8d8b9f3f49726097952975"
    ),
    .target(
      name: "SampleUIObjC",
      dependencies: [
        "ZoomVideoSDK",
        "CptShare",
      ],
      path: "Sources/SampleUIObjC",
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("Internal"),
        .define("SWIFT_PACKAGE")
      ]
    ),
    .target(
      name: "SampleUI",
      dependencies: ["SampleUIObjC"],
      path: "Sources/SampleUI",
      resources: [.process("Resources")]
    )
  ]
)
