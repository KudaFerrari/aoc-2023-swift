// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let defaultDeps: [Target.Dependency] = [.targetItem(name: "InputFiles", condition: .none)]

let package = Package(
    name: "AOC_2023",
    targets: [
        .target(name: "InputFiles", resources: [.copy("Input")]),
        .executableTarget(name: "Day1A", dependencies: defaultDeps),
        .executableTarget(name: "Day1B", dependencies: defaultDeps),
    ]
)
