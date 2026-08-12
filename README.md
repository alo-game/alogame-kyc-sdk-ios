# Alogame KYC SDK

Native (no WebView) identity-verification (XMDT) SDK for copub games, Android
and iOS. Independent of `v2/` — separate repo, separate release lifecycle, no
`vn.oeg.*` / `OegSdkV2` import anywhere in this tree.

Integration is exactly three calls, no payload beyond an id:

```kotlin
// Android
AlogameKycSdk.init(context, AlogameKycConfig(env = AlogameKycEnv.DEV, tokenProvider = ...))
AlogameKycSdk.setGameRole(uid, sessionToken)
AlogameKycSdk.show(activity, listener)
```

```swift
// iOS
AlogameKycSdk.shared.initialize(AlogameKycConfig(env: .dev, tokenProvider: ...))
AlogameKycSdk.shared.setGameRole(uid: uid, sessionToken: sessionToken)
AlogameKycSdk.shared.show(from: viewController, listener: listener)
```

Identity data (name, date of birth, phone, OTP) goes **device → `ekycx`
directly**, never through the game server. The game server's only
involvement is minting a short-lived session token via its own HMAC-signed
call to `ekycx` and relaying it to the client — see
`.kiro/specs/xmdt-session-api` in the parent workspace for that contract.

## Status

Phase 1 (native core) in progress. Engine wrappers live in this repo rather
than a separate one, matching `v2`'s own precedent of keeping its engine
bridge alongside the native SDK; easy to split out later. Planning for all of
them is in `.kiro/specs/alogame-kyc-sdk-engine-wrappers/`.

**Unity** (`unity/`) — UPM package `com.alogame.kycsdk`, installable by git
URL. Imports into Unity 6000.5.6f1 with zero errors, and both native shims
compile against the real vendored AAR/xcframework, but **no APK or IPA has
been built and nothing has run on a device yet**. See `unity/README.md` for
exactly what was and was not verified.

Unreal and the standalone npm/TypeScript wrapper are Phase 2+, not started.
(A Cocos Creator plugin exists on the `feat/cocos-plugin` branch — Android
working on a real device, iOS paused on a crash inside Cocos's own engine
code — and is not merged here yet.)

iOS deployment target is confirmed at **iOS 15** (`Package.swift`).
`minSdk` (Android) is still **not yet confirmed** against the live copub
roster (25 titles) — see the open item in `alogame-kyc-sdk-android/design.md`.
Do not treat the value in `android/sdk/build.gradle` as final until that
confirmation lands.

**`compileSdk 36` is required**, not a default choice — `OnBackInvokedDispatcher`
and `WindowInsets.Type` (needed once `KycActivity` is built, per
`alogame-kyc-sdk-android/design.md` §8) do not compile below it. The SDK's own
`targetSdk` is **not** what Google Play evaluates and does not raise a host
game's — every copub title targeting SDK 36 after Google's 31 Aug 2026
deadline is a compatibility concern for this SDK, not a compliance one for the
SDK itself.

## Repo layout

```
alogame-kyc-sdk/
├── ios/
│   ├── Package.swift      not released from this repo — each platform gets
│   │                       its own release repo later, so there's no SPM
│   │                       git-URL constraint pinning this to the repo root
│   ├── Sources/AlogameKycSdk/ iOS source
│   ├── Tests/AlogameKycSdkTests/ iOS unit tests (swift test)
│   └── TestApp/            iOS sample app — local SPM package dep on "..",
│                           NOT a Package.swift target; see
│                           ios/TestApp/README.md
├── fixtures/               shared flow vectors + copy deck, owned by the
│                           xmdt-kyc-flow spec, consumed by both platforms
├── android/
│   ├── sdk/src/test/kotlin/  Android unit tests (./gradlew :sdk:testDebugUnitTest)
│   └── sample/               Android sample app; see android/sample/README.md
└── unity/                  UPM package (com.alogame.kycsdk) — vendors the
                            compiled AAR + xcframework and wires them into a
                            game's generated Gradle/Xcode project with no
                            manual editing; see unity/README.md
```

## Tests

`FlowController`, `AgeCalculator`, `PhoneNormalizer`, `Validators` and
`TokenBroker` are plain Kotlin/Foundation-only Swift with no platform UI
dependency, so both platforms have a JVM/host-machine-only unit test suite —
no emulator or simulator required:

```sh
cd android && ./gradlew :sdk:testDebugUnitTest
cd ios && swift test
```

**Android: verified 2026-08-07** — `./gradlew :sdk:testDebugUnitTest` green,
**74/74 tests**, using Android Studio's bundled JBR as `JAVA_HOME` and a
freshly-provisioned SDK (`cmdline-tools`, `platforms;android-36`,
`build-tools;36.0.0`). AGP had moved to 9.x with **built-in Kotlin support**
since this was last written — `org.jetbrains.kotlin.android` is no longer
applied (it's incompatible with the new DSL); see the comments in
`android/settings.gradle` and `android/sdk/build.gradle`. Two things the
build itself corrected that no amount of reading would have caught:

- `PublicSurfaceTest.kt`'s reflection check needed to filter out Kotlin's
  `$<module>`-mangled `internal` members and `$default` bridge methods —
  both compile to `public` bytecode despite being `internal`/parameter-default
  in source. Fixed; see that file's doc comment for the exact names it saw.
- The published POM is **not** dependency-free — `org.jetbrains.kotlin:kotlin-stdlib`
  shows up at `compile` scope, because AGP's built-in Kotlin adds it
  automatically. This is true of every Kotlin Android library ever
  published, not a choice this module made; see the comment above the
  `dependencies` block in `android/sdk/build.gradle`. R5.4/P5's "zero
  dependencies" means zero *third-party* dependencies (no OkHttp, no Gson, no
  play-services at runtime) — not literally zero.

**iOS: still unverified** — this Windows machine cannot run `swift test`
(needs macOS/Xcode). Run it there before merging.

Not covered yet, because they need infrastructure beyond a JVM/host machine:
`KycApi`/`HttpKycApi` contract tests against a running Prism mock (task 9.3),
and instrumented/XCUITest tiers (`FLAG_SECURE`, rotation, `isModalInPresentation`
on a real device/simulator). The public-surface tests are also partial by
design — see the doc comments in `PublicSurfaceTest.kt` /
`PublicSurfaceTests.swift` for exactly what they do and don't guarantee.

## Building against the mock, not `ekycx`

`ekycx` does not implement the session-scoped routes this SDK calls
(`GET /xmdt/session`, `/xmdt/session/otp/*`, `/xmdt/session/collect`) yet —
only the legacy per-game HMAC routes. Build and test against the Prism mock
of `xmdt-api-contract/openapi.yaml`:

```sh
npx @stoplight/prism-cli mock ../path/to/.kiro/specs/xmdt-api-contract/openapi.yaml
```

See `fixtures/README.md` for scenario-specific invocation notes.
