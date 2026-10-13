# MonetKit iOS SDK

In-app subscriptions for iOS, without running your own receipt server.
MonetKit wraps StoreKit 2, validates every purchase on the MonetKit backend and
tells your app, at any moment, what the user is entitled to. A SwiftUI paywall
designed in the MonetKit Portal ships alongside it.

📖 **[iOS quick start](https://docs.monetkit.com/docs/quick-start/ios/)** — from
an empty project to a working purchase in a few minutes.

## Features

- **Offerings and packages** configured in the Portal, so plans and prices change
  without an app release.
- **StoreKit 2 purchases**, including promotional and win-back offers, Ask to Buy
  and SCA.
- **Entitlements**: one `CustomerInfo` answers "is this user pro?", kept current
  across renewals, refunds and other devices.
- **Restore and sync**, with transactions validated server-side.
- **Identity**: anonymous users out of the box, `logIn` / `logOut` to your own
  user IDs.
- **SwiftUI paywall** (`MonetKitPaywallUI`): a remote-configured paywall in one
  view modifier.
- **Subscriber attributes** and **virtual currencies**.
- **Typed errors** carrying the backend's code and `request_id`, and **logging**
  you can route into your own pipeline.
- Swift 6 with strict concurrency, async/await throughout, zero third-party
  dependencies.

## Requirements

| | |
| --- | --- |
| iOS | 16.0+ |
| Xcode | 26+ |
| Swift | 6.2 |

## Installation

MonetKit is a binary Swift package — no registry login, no credentials. It offers
two products:

| Product | Import | Use |
| --- | --- | --- |
| `MonetKit` | `import MonetKit` | **Required.** Configuration, offerings, purchases, customer info. |
| `MonetKitPaywallUI` | `import MonetKitPaywallUI` | Optional. The SwiftUI paywall. |

### Xcode

1. **File → Add Package Dependencies…**
2. Paste `https://github.com/supremetech/monetkit-ios-sdk-public.git`.
3. Choose **Up to Next Major Version** and click **Add Package**.
4. Add `MonetKit` to your app target, and `MonetKitPaywallUI` if you use the paywall.

### Package.swift

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

## Usage

### Configure

Once, as early as possible — usually in your `App` initializer:

```swift
import MonetKit

@main
struct MyApp: App {
    init() {
        Purchases.configure(withAPIKey: "YOUR_API_KEY")
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

### Check entitlements

```swift
let customerInfo = try await Purchases.shared.customerInfo()
let isPro = customerInfo.entitlements["pro"]?.isActive == true
```

To react to changes — a renewal, a purchase on another device — observe the stream:

```swift
for await customerInfo in Purchases.shared.customerInfoStream {
    isPro = customerInfo.entitlements["pro"]?.isActive == true
}
```

### Fetch offerings and purchase

```swift
let offerings = try await Purchases.shared.offerings()
guard let package = offerings.current?.availablePackages.first else { return }

let result = try await Purchases.shared.purchase(package: package)
if !result.userCancelled {
    // result.customerInfo already reflects the purchase.
}
```

### Restore purchases

```swift
let customerInfo = try await Purchases.shared.restorePurchases()
```

### Identify the user

```swift
let (customerInfo, created) = try await Purchases.shared.logIn("your-user-id")
// …
let anonymousInfo = try await Purchases.shared.logOut()
```

### Show the paywall

```swift
import MonetKit
import MonetKitPaywallUI

struct ContentView: View {
    @State private var showPaywall = false
    @State private var offering: Offering?

    var body: some View {
        Button("Upgrade") { showPaywall = true }
            .task { offering = try? await Purchases.shared.offerings().current }
            .paywallSheet(isPresented: $showPaywall, offering: offering)
            .onPurchaseCompleted { _, customerInfo in
                // Unlock content — entitlements are up to date.
            }
    }
}
```

`.fullScreenCoverPaywall(isPresented:offering:)` presents it full screen, and
`PaywallView(offering:)` embeds it in your own layout. Purchase, restore, failure
and dismiss callbacks are all available as view modifiers — see
[Paywalls](https://docs.monetkit.com/docs/sdk/ios/paywalls/).

## Error handling

Every async API throws `MonetKitError`. A backend refusal carries the HTTP status,
the backend's error code, its `retryable` hint and the `request_id` to quote in a
support ticket:

```swift
do {
    let customerInfo = try await Purchases.shared.customerInfo()
} catch MonetKitError.backendError(let info) {
    print("backend \(info.statusCode), request \(info.requestID ?? "-")")
} catch MonetKitError.networkError {
    // The request never reached the server.
}
```

`paymentPending` (Ask to Buy, SCA) and `purchasePending` (accepted by the App Store,
still validating) are **not failures** — don't show an error for them. See
[Error handling](https://docs.monetkit.com/docs/sdk/ios/error-handling/).

## Logging

```swift
Purchases.logLevel = .debug   // set before configure; defaults to .info
Purchases.logHandler = { level, message in
    MyLogger.shared.record(message)
}
```

Every line is tagged `[MonetKit][Area][LEVEL]`, so filtering the Xcode console on
`[MonetKit]` finds them. Without a handler, lines go to `os.Logger` under subsystem
`com.monetkit`.

## Privacy

Each framework ships a `PrivacyInfo.xcprivacy`. MonetKit does not track users and
contacts no tracking domains; it records purchase history for app functionality and
uses `UserDefaults` as a cache. Subscriber attributes such as email or phone number
are sent only when your app sets them — if it does, declare them in your app's
privacy details.

## Documentation

- **[iOS quick start](https://docs.monetkit.com/docs/quick-start/ios/)**
- iOS SDK guide:
  [Installation](https://docs.monetkit.com/docs/sdk/ios/installation/) ·
  [Configuration](https://docs.monetkit.com/docs/sdk/ios/configuration/) ·
  [Customer info](https://docs.monetkit.com/docs/sdk/ios/customer-info/) ·
  [Making purchases](https://docs.monetkit.com/docs/sdk/ios/making-purchases/) ·
  [Restoring purchases](https://docs.monetkit.com/docs/sdk/ios/restoring-purchases/) ·
  [Paywalls](https://docs.monetkit.com/docs/sdk/ios/paywalls/) ·
  [Error handling](https://docs.monetkit.com/docs/sdk/ios/error-handling/) ·
  [Troubleshooting](https://docs.monetkit.com/docs/sdk/ios/troubleshooting/)
- Testing: [Sandbox testing](https://docs.monetkit.com/docs/testing/sandbox-testing/) ·
  [Launch checklist](https://docs.monetkit.com/docs/testing/checklist/)
- [FAQ](https://docs.monetkit.com/docs/support/faq/) ·
  [Changelog](https://docs.monetkit.com/docs/support/changelog/)
- [All MonetKit documentation](https://docs.monetkit.com/)

Quick Help (Option-click) in Xcode documents every public symbol.
