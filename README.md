# EmpikAppiOS

A SwiftUI weather app built as an iOS Developer recruitment task. Search for a city and view its current, hourly and 7-day forecast, powered by the free [Open-Meteo](https://open-meteo.com) API (no API key required).

## Features

- **City search**: debounced, as-you-type search via the Open-Meteo Geocoding API, with results in the device language
- **Input validation**: city names are trimmed, normalized and checked for digits and invalid characters
- **Search history**: recently opened cities are kept between launches and can be swiped away or cleared
- **Forecast details**: current conditions, the next hours and the upcoming 7 days, with pull-to-refresh
- **Loading, empty and error states** on every screen
- **Accessibility**: Dynamic Type across all screens (layouts reflow at large text sizes) and VoiceOver labels, headings and hints

## Requirements

- Xcode 26 or 27
- iOS 17.0+
- Swift 6

## Getting started

1. Open `EmpikApp/EmpikApp.xcodeproj` in Xcode.
2. Select the `EmpikApp` scheme and an iOS 17+ simulator.
3. Build and run (`⌘R`).

The app has no third-party dependencies. All code lives in the app target and the local `WeatherModules` package.

## Architecture

MVVM with `@Observable` view models, Swift Concurrency and protocol-based dependency injection. The app target only does composition (`AppDependencies`) and navigation (`AppRouter` + `NavigationStack`). Everything else is split into modules in `Packages/WeatherModules`:

| Module | Responsibility |
| --- | --- |
| `Domain` | Models (`Location`, `Forecast`, `WeatherCondition`), errors and service protocols |
| `Networking` | Generic `HTTPClient` on top of `URLSession`, endpoints and network errors |
| `OpenMeteo` | Geocoding and forecast services, DTOs and mapping to domain models |
| `Persistence` | Search history stored as JSON in Application Support (actor-based) |
| `DesignSystem` | Shared UI components, formatting and weather condition presentation |
| `CitySearchFeature` | City search screen, validation and search history |
| `ForecastFeature` | Forecast details screen and its cards |

Feature modules depend only on `Domain` and `DesignSystem`, so they never know about Open-Meteo or networking. Concrete services are wired in the app target.

## Tests

Unit tests use Swift Testing and live in `Packages/WeatherModules/Tests`, one target per module (`DomainTests`, `NetworkingTests`, `OpenMeteoTests`, `PersistenceTests`, `DesignSystemTests`, `CitySearchFeatureTests`, `ForecastFeatureTests`). The `TestSupport` target holds shared stubs and fixtures.

They cover view models, validation, mapping, networking (with a stubbed `URLProtocol`) and file persistence. SwiftUI views are not unit tested.

The shared `EmpikApp` scheme runs all of them through `EmpikApp/EmpikApp.xctestplan`, which also collects code coverage for the package modules. Each module also has its own shared scheme (`Domain`, `Networking`, …) that builds it and runs only its tests with coverage for that module. In Xcode, select an iOS simulator and press `⌘U`. From the command line:

```sh
cd EmpikApp
xcodebuild test -project EmpikApp.xcodeproj -scheme EmpikApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
