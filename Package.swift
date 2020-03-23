// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "wallpaper-allspaces",
    products: [
    .executable(name: "wallpaper", targets: ["Wallpaper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.4"),
    ],
    targets: [
        .target(
            name: "Wallpaper",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
            ),
    ]
)
