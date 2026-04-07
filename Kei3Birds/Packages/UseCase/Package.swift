// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "UseCase",
    platforms: [.iOS("26.0")],
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
