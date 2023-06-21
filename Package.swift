// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Cara",
  platforms: [
      .macOS(.v10_12),
      .iOS(.v10),
      .tvOS(.v10),
      .watchOS(.v5)
  ],
  products: [
    .library(name: "Cara", targets: ["Cara"])
  ],
  dependencies: [],
  targets: [
    .target(name: "Cara", dependencies: [], path: "Sources")
  ],
  swiftLanguageVersions: [.v4_2]
)
