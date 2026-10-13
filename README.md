# MonetKit iOS SDK

Subscriptions, entitlements and StoreKit 2 purchases for iOS, with a SwiftUI paywall.

**Get started:** [iOS quick start](https://docs.monetkit.com/docs/quick-start/ios/) — install, configure, show a paywall and unlock content in a few minutes.

## Requirements

| | |
| --- | --- |
| iOS | 16.0+ |
| Xcode | 26+ |

## Installation

The SDK is distributed through Swift Package Manager as two products:

| Product | Import | Use |
| --- | --- | --- |
| `MonetKit` | `import MonetKit` | Required. Configuration, offerings, purchases, customer info. |
| `MonetKitPaywallUI` | `import MonetKitPaywallUI` | Optional. The SwiftUI paywall. |

In Xcode, **File → Add Package Dependencies…**, paste the URL below and add the
products your target needs:

```
https://github.com/supremetech/monetkit-ios-sdk-public.git
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/supremetech/monetkit-ios-sdk-public.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MonetKit", package: "monetkit-ios-sdk-public"),
            .product(name: "MonetKitPaywallUI", package: "monetkit-ios-sdk-public")
        ]
    )
]
```

## Quick start

Configure once, at launch:

```swift
import MonetKit

Purchases.configure(withAPIKey: "YOUR_API_KEY")
```

Show the paywall:

```swift
import MonetKitPaywallUI

PaywallView()
```

## Documentation

- [iOS quick start](https://docs.monetkit.com/docs/quick-start/ios/)
- iOS SDK guide: [Installation](https://docs.monetkit.com/docs/sdk/ios/installation/) ·
  [Configuration](https://docs.monetkit.com/docs/sdk/ios/configuration/) ·
  [Paywalls](https://docs.monetkit.com/docs/sdk/ios/paywalls/) ·
  [Making purchases](https://docs.monetkit.com/docs/sdk/ios/making-purchases/) ·
  [Troubleshooting](https://docs.monetkit.com/docs/sdk/ios/troubleshooting/)
- [All MonetKit documentation](https://docs.monetkit.com/)
