# MonetKit iOS SDK

Subscriptions, entitlements and StoreKit 2 purchases for iOS, with a SwiftUI paywall.

## Requirements

| | |
| --- | --- |
| iOS | 16.0+ |
| Xcode | 26+ |

## Installation

In Xcode, **File → Add Package Dependencies…** and paste:

```
https://github.com/supremetech/monetkit-ios-sdk-public
```

Add `MonetKit` to your target, and `MonetKitUI` if you use the paywall.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/supremetech/monetkit-ios-sdk-public", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MonetKit",   package: "monetkit-ios-sdk-public"),
            .product(name: "MonetKitUI", package: "monetkit-ios-sdk-public")  // only for the paywall
        ]
    )
]
```

## Quick start

```swift
import MonetKit

Purchases.configure(withAPIKey: "YOUR_API_KEY")
```

For the paywall, `import MonetKitiOS` and present `PaywallView()`.
