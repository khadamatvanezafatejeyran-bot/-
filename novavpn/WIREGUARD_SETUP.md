# NovaVPN Android WireGuard client

The Flutter app includes a native Android bridge to the official WireGuard tunnel library. Users paste their own complete WireGuard client config into the app; the private key is not compiled into source, committed, or written by this bridge to a config file. Android's system VPN-consent dialog is shown before the tunnel starts.

## Important credential action

The private key previously pasted into chat must stay revoked. Do not paste the replacement key into chat or GitHub. Register its matching **client public key** with the VPN provider/server, then paste the new complete config directly into NovaVPN on the Android test device. Do not include comments on the same line as values. This bridge does not persist config between app process runs.

## Android project setup

This repository's `novavpn/` directory was initially source-only and does not include generated Android Gradle wrapper files. On a machine with Flutter installed, from `novavpn/` run once:

```sh
flutter create --platforms=android --org com.novavpn .
```

Keep the existing `lib/` files and the committed `android/app/src/main/kotlin/com/novavpn/novavpn/MainActivity.kt`. Confirm the generated MainActivity package matches `com.novavpn.novavpn`.

In `android/app/build.gradle` (or its `.kts` equivalent), add the WireGuard Maven Central dependency, Java 17 and core-library desugaring:

```gradle
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true
    }
}

dependencies {
    implementation 'com.wireguard.android:tunnel:1.0.20260102'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.5'
}
```

The WireGuard library manifest contributes its `GoBackend.VpnService`, protected by `BIND_VPN_SERVICE`. Ensure the app manifest includes `android.permission.INTERNET`; do not expose the VPN service yourself or remove the library's service declaration. Use Android SDK 36 for a new Play submission in the 2026 policy window, then re-check Google's current target API deadline before submission.

Run checks/build:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Scope and limitations

- This app uses the WireGuard `GoBackend` tunnel library and Android's VPN permission flow. It requests the routes supplied by the user's config; for full tunnel the config normally includes both IPv4 and IPv6 default routes. A configured route is not proof of working server forwarding, DNS, IPv6, or leak protection.
- Tunnel behavior has not been tested against your provider's server or on a physical device in this environment. Verify handshake, public IP, DNS, IPv4/IPv6 behavior, disconnection, and network changes before relying on it.
- The current bridge keeps the config only in memory and does not offer persistent auto-connect, always-on/lockdown, or a functioning kill switch. The corresponding switches are intentionally absent.
- No advertising SDK is integrated. The visible ad block is only a placeholder; add ads only after reviewing consent, privacy policy, and Google Play ad/data policies.
- This project is not certified or guaranteed to pass Google Play review. Add accurate policy disclosures, privacy policy, support/store listing, signing setup, and security review before release. Never commit signing keys or VPN credentials.

WireGuard Android embedding documentation: https://github.com/WireGuard/wireguard-android#embedding
