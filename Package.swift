// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Cara",
  products: [
    .library(name: "Cara", targets: ["Cara"])
  ],
  dependencies: [],
  targets: [
        .target(name: "Cara", dependencies: [], path: "Sources")
    ]
)