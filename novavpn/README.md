# NovaVPN Flutter UI prototype

NovaVPN is a Flutter UI prototype inspired by the supplied dark neon shield/dashboard references. The current source is **not a functioning VPN client**: it has no Android project scaffold, no WireGuard tunnel integration, and does not route device traffic.

## Run

```sh
cd novavpn
flutter create --platforms=android .
flutter pub get
flutter run
```

Review generated Android files and do not overwrite `lib/main.dart`.

## Important security notice

A WireGuard private key was pasted into chat. Treat that key as compromised: ask the VPN provider/server administrator to revoke the old peer, generate a fresh client keypair, and register the new **client public key** on the server. Never place the private key in source code, GitHub, CI logs, screenshots, or a built-in app default. Enter it locally on the device or import a configuration through private app storage. Do not send the replacement private key in chat.

The provided endpoint/public key/address/DNS/routes are not sufficient to make this repository a complete, verified VPN app. The client private key is absent from the latest supplied config; IPv6 routing and server forwarding also need provider confirmation. `AllowedIPs = 0.0.0.0/0, ::/0` requests full IPv4 and IPv6 routing, but does not prove that the server supports it or prevent leaks if its IPv6 routing is broken.

## Google Play

This UI prototype is not ready for submission. A real release requires a supported Android `VpnService` implementation with a reputable WireGuard tunnel engine, secure local configuration/key handling, real server operation and failure testing, accurate privacy and Data safety disclosures, app assets/support details, release signing, and review of current Play policies. No code change can guarantee acceptance.
