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
            ]
        ),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Networking"),

        .target(name: "OpenMeteo", dependencies: ["Domain", "Networking"]),
    ]
)
