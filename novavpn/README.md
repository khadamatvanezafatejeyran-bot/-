# NovaVPN Flutter starter

This folder contains a new Flutter UI starter for NovaVPN, separate from the APK/decompilation files currently at the repository root.

## Run

```sh
cd novavpn
flutter pub get
flutter run
```

## Current scope

- Dark, neon blue/purple dashboard styled from the supplied visual reference.
- Home, server-location list, and settings screens.
- Selectable sample locations and local theme/auto-connect/kill-switch UI preferences.
- Clearly marked ad placeholder; no ad network SDK or ad unit IDs are configured.

**Important:** This is a UI prototype only. The connect control does not establish a VPN tunnel, and the listed countries/latencies are sample data rather than live servers. A production VPN needs a trusted VPN backend and native Android `VpnService`/iOS `NetworkExtension` implementations, consent and privacy disclosures, and real server infrastructure. Do not present the prototype as protecting traffic until that work is implemented and independently tested.
