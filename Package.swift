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
      url: "https://github.com/zoom/videosdk-ios/releases/download/v2.3.10/ZoomVideoSDK.xcframework.zip",
      checksum: "f6a31f3387d6638c35e08b7b413a282d3acad3eb01fdadc4692fb74e8736ecf7"
    ),
    .binaryTarget(
      name: "CptShare",
      url: "https://github.com/zoom/videosdk-ios/releases/download/v2.3.10/CptShare.xcframework.zip",
      checksum: "14d5037a0409883c13d86e49d8b91b244852904263a87a6ba0bdf6d5fb698cc4"
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
