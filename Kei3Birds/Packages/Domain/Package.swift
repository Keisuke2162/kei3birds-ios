// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
    ]
)
