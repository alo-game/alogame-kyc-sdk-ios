# Alogame KYC SDK

Native identity-verification (XMDT) SDK for copub games — no WebView. Android
(Kotlin, callable from Java) and iOS (Swift Package, callable from
Objective-C).

Full docs: https://docs.alogame.vn/xmdt

## Status

Shipped and live. Both platforms are on **1.0.0** — `DEV` and `PROD`
environments are both up (`AlogameKycEnv.DEV` / `.PROD`, or `.dev` / `.prod`
on iOS); see the [Android](https://docs.alogame.vn/xmdt/android) and
[iOS](https://docs.alogame.vn/xmdt/ios) integration guides for install
instructions and current version numbers.

**Unity** (`unity/`) — UPM package `com.alogame.kycsdk`, installable by git
URL, vendoring the compiled AAR/xcframework. See `unity/README.md` for what
has and hasn't been verified on a real device.

A Cocos Creator plugin exists on the `feat/cocos-plugin` branch (Android
verified on a real device; iOS paused on a crash inside Cocos's own engine
code) and is not merged here yet. Unreal and a standalone npm/TypeScript
wrapper are not started.

## Repo layout

```
alogame-kyc-sdk/
├── android/    Kotlin source (android/sdk/) + sample app (android/sample/)
├── ios/        Swift Package source (ios/Sources/AlogameKycSdk/) + sample apps
├── unity/      UPM package wrapping the compiled AAR + xcframework
├── fixtures/   shared flow vectors + copy deck consumed by both platforms
└── scripts/    release scripts (deploy_jitpack.sh, deploy_ios_spm.sh) —
                publish compiled artifacts to github.com/alo-game, source
                stays in this private repo
```

## Tests

```sh
cd android && ./gradlew :sdk:testDebugUnitTest
cd ios && swift test
```

`FlowController`, `AgeCalculator`, `PhoneNormalizer`, `Validators` and
`TokenBroker` are plain Kotlin/Foundation-only Swift with no platform UI
dependency, so both suites run on a JVM/host machine — no emulator or
simulator required.
