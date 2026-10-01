# MonetKit iOS SDK

In-house monetization SDK — subscriptions, entitlements, StoreKit 2 purchases
(including promotional and win-back offers), virtual currencies, subscriber
attributes, identity, and a SwiftUI paywall.

Distributed as a signed binary XCFramework.

## Requirements

| | |
| --- | --- |
| iOS / iPadOS | 16.0 |
| Swift | 6.2 |
| Xcode | 26 |

`MonetKit` is the headless core. `MonetKitUI` adds the paywall and needs UIKit
and WebKit, so it is iOS only.

## Installation

### Xcode

**File → Add Package Dependencies…**, paste:

```
https://github.com/supremetech/monetkit-ios-sdk-public
```

Choose a version rule, then pick the products you need.

### Package.swift

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

## Usage

Configure once, as early as your app starts:

```swift
import MonetKit

Purchases.configure(withAPIKey: "YOUR_API_KEY")
```

Load offerings and buy a package:

```swift
let offerings = try await Purchases.shared.offerings()
guard let package = offerings.current?.availablePackages.first else { return }

do {
    let result = try await Purchases.shared.purchase(package: package)
    if !result.userCancelled,
       result.customerInfo.entitlements["premium"]?.isActive == true {
        // unlock
    }
} catch MonetKitError.paymentPending {
    // Ask to Buy / SCA: the App Store has not accepted it yet. Not a failure.
} catch MonetKitError.purchasePending {
    // Accepted by the App Store, still being validated. Not a failure.
} catch MonetKitError.purchaseCancelled {
    // The user backed out.
}
```

Watch entitlements while the app runs:

```swift
for await info in Purchases.shared.customerInfoStream {
    isPremium = info.entitlements["premium"]?.isActive == true
}
```

A restore that finds nothing throws `MonetKitError.noPurchasesToRestore` — tell
the user there was nothing to restore rather than showing an error.

### Paywall

Add the `MonetKitUI` product, then:

```swift
import MonetKitiOS

Button("Upgrade") { showPaywall = true }
    .paywallSheet(isPresented: $showPaywall, offering: nil)
```

`offering: nil` shows the current offering; pass one explicitly when the paywall
can open right at launch, before the SDK has fetched offerings. `PaywallView` can
also be embedded directly.

### Errors

Every throwing API throws `MonetKitError`. There is no `isRetryable`: retry
policy is yours. A backend refusal carries what you need to decide — HTTP status,
the backend's error code and type, its `retryable` hint, `Retry-After`, and a
`requestID` to quote when reporting a problem:

```swift
catch MonetKitError.backendError(let info) {
    print(info.statusCode, info.code?.rawValue ?? "-", info.requestID ?? "-")
}
```

Failures with no call to throw from — a renewal that fails verification, a
subscriber-attribute batch the backend refuses — arrive through
`PurchasesDelegate.purchases(_:receivedBackgroundError:)`.

### Logging

```swift
Purchases.logLevel = .debug              // default is .info
Purchases.logHandler = { level, message in
    // route into your own logging
}
```

Set both before `configure`. A handler replaces the default `os.Logger` output.

Documentation comments travel in the binary — Option-click any symbol in Xcode.

## Privacy

Both frameworks ship a `PrivacyInfo.xcprivacy`, and neither tracks. `MonetKit`
declares purchase history, recorded for app functionality, and `UserDefaults`,
used to cache what it has already fetched. `MonetKitiOS` declares nothing.

Subscriber attributes are yours to declare. `Attribution` can send an email
address, a phone number, a display name and a push token, but only when your
app calls it. They are left out of the manifest so that apps which never send
them are not made to report them; if yours does, add them to your own App
Privacy details.

## Signature

Releases are signed by **SUPREMETECH COMPANY LIMITED** (team `C9MWYPX772`).
Verify with:

```bash
codesign -dv --verbose=2 MonetKit.xcframework
```

## Support

This repository carries releases only; it takes no issues or pull requests.
