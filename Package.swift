// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PickColor",
    products: [
        .library(name: "PickColor", targets: ["PickColor"])
    ],
    targets: [
        .target(name: "PickColor", path: "PickColor")
    ]
)
