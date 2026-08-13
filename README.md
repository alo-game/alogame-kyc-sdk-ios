# Alogame KYC SDK — iOS

Native identity-verification (XMDT) SDK for iOS games — no WebView. Swift Package, module `AlogameKycKit` (the entry class is `AlogameKycSdk`).

Full docs: https://docs.alogame.vn/xmdt/ios

> [!NOTE]
> Everything below describes the **dev** environment. Production has not been provisioned yet — do not point a live build at it.

## Install

Xcode → **File → Add Package Dependencies…**

```
https://github.com/alo-game/alogame-kyc-sdk-ios
```

Pick **Up to Next Major** starting at `0.2.0`, and add the **AlogameKycKit** product to your target.

The package declares zero third-party dependencies — only `Foundation`, `UIKit`, and `SafariServices` link.

## Quick start

```swift
import AlogameKycKit

AlogameKycSdk.shared.initialize(AlogameKycConfig(env: .dev))
AlogameKycSdk.shared.setGameRole(uid: uid, sessionToken: sessionToken)
AlogameKycSdk.shared.show(from: viewController, listener: listener)
```

`listener` conforms to `AlogameKycListener` — `onResult(_:)` fires exactly once, after the screen has been dismissed, with `.success` / `.failed(reason:, message:)` / `.cancelled`. `.success` is a UI signal, not proof of verification — see the docs for the server-side check to pair it with.

## Objective-C

The same `AlogameKycSdk` singleton is callable from Objective-C:

```objc
#import <AlogameKycKit/AlogameKycKit-Swift.h>
```

Use `AlogameKycObjcListener` in place of `AlogameKycListener`, and the `Int`-backed `AlogameKycResultStatus`/`AlogameKycFailReasonCode` enums in place of `AlogameKycResult`/`AlogameKycFailReason`. Full example in the [Objective-C section](https://docs.alogame.vn/xmdt/ios#objective-c) of the docs.

## What this SDK does

Collects full name, date of birth, phone number (OTP-verified), and consent, then talks directly to Alogame's XMDT server — none of that data ever transits your game server. Your server's only involvement is minting a short-lived session token and handing it to the client; see the docs for that one call and for how to independently confirm a player's real verification status.

## Requirements

- iOS 15+
- Swift or Objective-C
