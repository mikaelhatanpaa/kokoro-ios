// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KokoroSwift",
  platforms: [
    .iOS(.v18), .macOS(.v15)
  ],
  products: [
    .library(
      name: "KokoroSwift",
      type: .dynamic,
      targets: ["KokoroSwift"]
    ),
  ],
  dependencies: [
    // 0.30.2 has mlx#3083 (NAX hardware detection wrong on A18) and
    // mlx#3092 / mlx-swift#344 (ConvTransposed1d produces partially-wrong
    // output when T > ~8000 on iOS Metal — Kokoro's vocoder hits this
    // regime on every chunk). The combined symptom is alternating clean
    // speech / sustained tinnitus-like buzz mid-content, peak samples
    // appear clean (~0.5) but ~50% of frames in the bad region are
    // garbage. Fixed in 0.30.6+; fully fixed in 0.31.x.
    .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.31.0"),
    // .package(url: "https://github.com/mlalma/eSpeakNGSwift", from: "1.0.1"),
    // Forked from mlalma/MisakiSwift to fix the SPM nested-bundle codesign
    // bug ("../../Resources/" → Xcode 26.3 codesign rejects "bundle format
    // unrecognized"). Branch fix/spm-resources-bundle-codesign relocates
    // Resources/ to the standard Sources/MisakiSwift/Resources/ layout
    // and switches .copy → .process. Original 1.0.6 content otherwise.
    .package(url: "https://github.com/mikaelhatanpaa/MisakiSwift", branch: "fix/spm-resources-bundle-codesign"),
    .package(url: "https://github.com/mlalma/MLXUtilsLibrary.git", exact: "0.0.6")
  ],
  targets: [
    .target(
      name: "KokoroSwift",
      dependencies: [
        .product(name: "MLX", package: "mlx-swift"),
        .product(name: "MLXNN", package: "mlx-swift"),
        .product(name: "MLXRandom", package: "mlx-swift"),
        .product(name: "MLXFFT", package: "mlx-swift"),
        // .product(name: "eSpeakNGLib", package: "eSpeakNGSwift"),
        .product(name: "MisakiSwift", package: "MisakiSwift"),
        .product(name: "MLXUtilsLibrary", package: "MLXUtilsLibrary")
      ],
      resources: [
       .process("Resources")
      ]
    ),
    .testTarget(
      name: "KokoroSwiftTests",
      dependencies: ["KokoroSwift"]
    ),
  ]
)
