// swift-tools-version: 6.2
//
// Placeholder on the default branch. Each release is a tag whose commit holds
// the real manifest — binary targets with the URL and checksum of that
// release's XCFrameworks — so Swift Package Manager only ever resolves tags.
import PackageDescription

let package = Package(
    name: "MonetKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [],
    targets: []
)
