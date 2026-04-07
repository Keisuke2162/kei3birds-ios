// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Infra",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Infra", targets: ["Infra"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Infra",
            dependencies: [
                "Domain",
                .product(name: "Supabase", package: "supabase-swift"),
            ]
        ),
    ]
)
