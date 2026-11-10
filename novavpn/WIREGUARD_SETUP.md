# WireGuard client implementation readiness

This is a security checklist for developing NovaVPN as a legitimate user-facing VPN client. It is not a working tunnel implementation.

## Credential incident

The client private key was disclosed in chat. Revoke that peer with the VPN provider/server administrator and generate a new client keypair. Register only the new client **public** key with the server. Keep the replacement private key on the device; do not commit it, put it in CI variables unless there is a specific deployment need, log it, or bake it into an APK.

## Configuration items to verify with the provider

- Client tunnel address and DNS resolver(s).
- Server public key and UDP endpoint.
- Allowed IP routes and whether both IPv4 and IPv6 full-tunnel routing are enabled on the server.
- Server-side peer registration for the new client public key, forwarding/NAT, firewall/UDP reachability, and DNS behavior.
- Whether keepalive is required for the client's network environment.

The recent config contains no `PrivateKey` value. That field must be provided locally on the client; do not ask for or paste it into this repository.

## Implementation requirements

- Use Android's user-approved `VpnService` API and a maintained WireGuard implementation. The WireGuard Android project's README documents the tunnel library and requires Java 17 plus core-library desugaring; consult its current upstream docs and license before choosing a dependency/version.
- Obtain VPN authorization via the Android system consent flow before starting the tunnel.
- Keep configuration in app-private storage, redact secrets from logs/errors, and never claim connected until the tunnel reports a successful state.
- Implement disconnect, errors, lifecycle/reconnect behavior, and test DNS, IPv4/IPv6 routing, and leak behavior on real devices and networks.
- Do not advertise auto-connect or kill-switch features until they are genuinely implemented and tested.
- Confirm Play VPN-service disclosure, Data safety, privacy policy, ad SDK disclosures, and current target API requirements before release.

## Current status

UI only: no WireGuard dependency, native service, stored configuration, tunnel, server backend, ad SDK, or release signing setup is included yet.
