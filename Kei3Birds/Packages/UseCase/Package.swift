// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "UseCase",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "UseCase", targets: ["UseCase"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "UseCase", dependencies: ["Domain"]),
    ]
)
