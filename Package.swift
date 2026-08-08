// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlogameKycKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AlogameKycKit",
            targets: ["AlogameKycKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AlogameKycKit",
            path: "AlogameKycKit.xcframework"
        )
    ]
)
