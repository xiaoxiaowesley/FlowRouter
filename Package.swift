// swift-tools-version: 6.1.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowRouter",
    platforms: [
        .iOS(.v13)
   ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FlowRouter",
            targets: ["FlowRouter"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FlowRouter",
            path: "Sources/FlowRouter",
            sources: [
                "FlowRouter.swift",
                "RouterModule.swift",
                "RouterProtocol.swift",
                "RouterViewController.swift",
                "RouteOption.swift",
                "PageRecord.swift",
                "RouteCloseData.swift",
                "NavigationType.swift",
                "RouteMapManager.swift",
                "Interceptor/CloseInterceptor.swift",
                "Interceptor/OpenInterceptor.swift",
                "Log/Log.swift",
                "Extension/StringExtension.swift",
                "Navibar/NaviBarView.swift",
                "UI/UI.swift",
                "UI/FadeAndSlideTransitioning.swift",
                "UI/FadeTransitioning.swift"
            ]
        ),
        .testTarget(
            name: "FlowRouterTests",
            dependencies: ["FlowRouter"]
        ),
    ]
)
