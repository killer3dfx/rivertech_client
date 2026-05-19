# RiverTech Client

RiverTech Client turns an Android or iOS phone into a lightweight mobile gateway for RiverTech deployments. It runs in the background, captures device GPS telemetry, and sends location updates to the configured tracking server.

This project is based on the open-source Traccar Client app and keeps the same core tracking foundation while introducing RiverTech branding and a gateway-oriented product direction.

## Current Capabilities

- Background GPS tracking on Android and iOS.
- Configurable device identifier and server endpoint.
- Offline buffering for network gaps.
- QR-based configuration import.
- Quick actions for starting, stopping, and sending SOS updates.
- Local log review and support export.

## RiverTech Direction

The next product layer is to make the phone act as a field gateway for vessel and remote-site data. Planned integration areas include Bluetooth sensors, local network inputs, and marine data protocols such as NMEA.

## Development

```sh
flutter pub get
flutter analyze
```

Firebase, signing credentials, bundle identifiers, and production server defaults should be configured for the final RiverTech release environment.

## Credits

Original application foundation by Anton Tananaev and the Traccar project. See `LICENSE.txt` for licensing details.
