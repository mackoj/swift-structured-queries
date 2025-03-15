// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-structured-queries",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
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
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.8.1"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.1"),
    .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"601.0.0"),
  ],
  targets: [
    .target(
      name: "StructuredQueriesCore"
    ),
    .target(
      name: "StructuredQueries",
      dependencies: [
        "StructuredQueriesCore",
        "StructuredQueriesMacros",
      ],
      swiftSettings: [
        .unsafeFlags([
          "-Xfrontend",
          "-warn-long-function-bodies=50",
          "-Xfrontend",
          "-warn-long-expression-type-checking=50",
        ])
      ]
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
      name: "StructuredQueriesMacrosTests",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
    .testTarget(
      name: "StructuredQueriesTests",
      dependencies: [
        "StructuredQueries",
        "StructuredQueriesSQLite",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [
        .unsafeFlags([
          "-Xfrontend",
          "-warn-long-function-bodies=50",
          "-Xfrontend",
          "-warn-long-expression-type-checking=50",
        ])
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
