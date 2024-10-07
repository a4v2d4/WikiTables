//// swift-tools-version:3.1
//import PackageDescription
//
//let package = Package(
//    name: "WikiStats",
//    platforms: [
//        .macOS(.v15),
//        .iOS(.v17)
//    ],
//    products: [
//        .library(
//            name: "WikiStats",
//            targets: ["WikiStats"]),
//    ],
//    dependencies: [
//        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
//    ],
//    targets: [
//        .target(
//            name: "WikiStats",
//            dependencies: ["SwiftSoup"]),
//        .testTarget(
//            name: "WikiStatsTests",
//            dependencies: ["WikiStats"]),
//        .testTarget(
//            name: "WikiStatsUITests",
//            dependencies: ["WikiStats"]),
//    ]
//)
