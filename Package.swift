import PackageDescription

let package = Package(
  name: "Cara",
  dependencies: [
    .Package(url: "https://github.com/icapps/ios-cara.git", majorVersion: 1, minor: 1)
  ]
)
