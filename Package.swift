// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Cara",
  products: [
    .library(name: "Cara", targets: ["Cara"])
  ],
  dependencies: [],
  platforms: [
      .macOS(.v10_10),
      .iOS(.v10_0),
      .tvOS(.v10_0)
  ],
  targets: [
    .target(name: "Cara", dependencies: [], path: "Sources")
  ],
  swiftLanguageVersions: [5]
)