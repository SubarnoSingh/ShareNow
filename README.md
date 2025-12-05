# ShareNow — Flutter P2P File Sharing

A Flutter app for fast, offline peer‑to‑peer file transfer on Android using Wi‑Fi Direct. It supports device discovery, sender/receiver modes, high‑speed multi‑file transfer, live progress, and local history.

## Setup

- Prereqs: Flutter `>=3.35`, Android SDK, a physical Android device.
- Windows only: enable Developer Mode to allow plugin symlinks.
  - Run `start ms-settings:developers` and toggle Developer Mode.
- Install deps: `flutter pub get`
- Run: `flutter run` (connect a device)
- Build APK: `flutter build apk --release`

## Permissions

- `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `ACCESS_NETWORK_STATE`, `CHANGE_NETWORK_STATE`, `INTERNET`
- `ACCESS_FINE_LOCATION` (required by Wi‑Fi Direct scanning)
- `NEARBY_WIFI_DEVICES` (Android 13+ with `neverForLocation` flag)

Runtime permissions are requested at startup when starting discovery.

## How It Works (P2P)

- Discovery: Wi‑Fi Direct peers are discovered and listed with name and address.
- Connection: Sender connects to receiver via Wi‑Fi P2P.
- Transfer: A lightweight socket protocol sends metadata (`name|size`) then raw bytes.
- Progress: Receiver computes progress and speed from received bytes.
- Encryption: Metadata can be AES‑encrypted for privacy; extendable to data stream if needed.
- History: Completed files are stored in a JSON list in app documents and can be opened later.

## Architecture

- MVVM with Riverpod.
- Core service: `lib/services/p2p_service.dart` (discovery, connect, sockets, transfer).
- UI: Tabs for `Send`, `Receive`, `History`.
- State: Providers in `lib/providers/*`.

## Notes

- Hotspot fallback is device/OS restricted; Wi‑Fi Direct works offline without internet.
- iOS does not support Wi‑Fi Direct; cross‑platform P2P would require different tech.
- QR quick connect and file manager can be added as optional modules.

## Files of Interest

- `lib/services/p2p_service.dart` — P2P sockets and transfer
- `lib/features/send/send_page.dart` — Sender flow
- `lib/features/receive/receive_page.dart` — Receiver flow
- `lib/features/history/history_page.dart` — Transfer history
- `lib/providers/*` — Riverpod state

## Troubleshooting

- If `flutter pub get` fails with symlink errors on Windows, enable Developer Mode.
- Ensure Location is enabled on the device; Android requires it for Wi‑Fi scanning.
- When sending very large files, keep devices close to maintain link quality.
