// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WeatherModules",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "WeatherModules",
            targets: [
                "Domain",
                "Networking",
                "OpenMeteo",
                "Persistence",
                "DesignSystem",
                "CitySearchFeature",
                "ForecastFeature",
            ]
        ),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Networking"),

        .target(name: "OpenMeteo", dependencies: ["Domain", "Networking"]),
        .target(name: "Persistence", dependencies: ["Domain"]),

        .target(name: "DesignSystem", dependencies: ["Domain"]),
        .target(name: "CitySearchFeature", dependencies: ["Domain", "DesignSystem"]),
        .target(name: "ForecastFeature", dependencies: ["Domain", "DesignSystem"]),

        .target(name: "TestSupport", dependencies: ["Domain", "Networking"], path: "Tests/TestSupport"),

        .testTarget(name: "DomainTests", dependencies: ["Domain", "TestSupport"]),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "TestSupport"]),
        .testTarget(name: "OpenMeteoTests", dependencies: ["OpenMeteo", "Domain", "Networking", "TestSupport"]),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence", "Domain", "TestSupport"]),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem", "Domain", "TestSupport"]),
        .testTarget(name: "CitySearchFeatureTests", dependencies: ["CitySearchFeature", "Domain", "TestSupport"]),
        .testTarget(name: "ForecastFeatureTests", dependencies: ["ForecastFeature", "Domain", "TestSupport"]),
    ]
)
