// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_file_dialog",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "flutter-file-dialog", targets: ["flutter_file_dialog"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_file_dialog",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
