// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-structured-queries",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "StructuredQueries",
      targets: ["StructuredQueries"]
    ),
    .library(
      name: "StructuredQueriesCore",
      targets: ["StructuredQueriesCore"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"601.0.0"),
  ],
  targets: [
    .target(
      name: "StructuredQueries",
      dependencies: [
        "StructuredQueriesCore",
        "StructuredQueriesMacros",
      ]
    ),
    .target(
      name: "StructuredQueriesCore"
    ),
    .macro(
      name: "StructuredQueriesMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "StructuredQueriesSQLite",
      dependencies: [
        "StructuredQueries"
      ]
    ),
    .testTarget(
      name: "StructuredQueriesTests",
      dependencies: [
        "StructuredQueries",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
      ]
    ),
    .testTarget(
      name: "StructuredQueriesIntegrationTests",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesSQLite",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),
    .testTarget(
      name: "StructuredQueriesMacrosTests",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
