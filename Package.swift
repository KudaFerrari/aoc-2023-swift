// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let input = Target.Dependency.targetItem(name: "InputFiles", condition: .none)
    static let common = Target.Dependency.targetItem(name: "Common", condition: .none)
    
}

extension Array where Element == Target.Dependency {
    static var defaultDeps: [Target.Dependency] {
        return [.input, .common]
    }
}

let package = Package(
    name: "AOC_2023",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "Common"),
        .target(name: "InputFiles", resources: [.copy("Input")]),
        .executableTarget(name: "Day1A", dependencies: .defaultDeps),
        .executableTarget(name: "Day1B", dependencies: .defaultDeps),
        .target(name: "Day2"),
        .executableTarget(name: "Day2A", dependencies: .defaultDeps + [.targetItem(name: "Day2", condition: .none)]),
        .executableTarget(name: "Day2B", dependencies: .defaultDeps + [.targetItem(name: "Day2", condition: .none)]),
        .executableTarget(name: "Day3", dependencies: .defaultDeps),
        .executableTarget(name: "Day5", dependencies: .defaultDeps),
        .executableTarget(name: "Day6", dependencies: .defaultDeps),
        .executableTarget(name: "Day7", dependencies: .defaultDeps),
        .executableTarget(name: "Day8", dependencies: .defaultDeps),
        .executableTarget(name: "Day9", dependencies: .defaultDeps),
        .executableTarget(name: "Day10", dependencies: .defaultDeps),
        .executableTarget(name: "Day11", dependencies: .defaultDeps),
    ]
)
