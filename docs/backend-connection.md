# Backend connection

Development on Android: `flutter run --dart-define=API_BASE_URL=http://YOUR_PC_LAN_IP:8000/api/v1/`.
Start Laravel with `php artisan serve --host=0.0.0.0 --port=8000` on a trusted development network.
Use `10.0.2.2` for the standard Android emulator's host machine. A physical phone needs a reachable LAN address.
The previous local address remains the development default; it is not a deployment address.

Release: `flutter build apk --dart-define=API_BASE_URL=https://YOUR_SERVER/api/v1/`.
Release requests require HTTPS. Android HTTP permission is limited to debug builds.
The API URL must end in `/api/v1/`. Configure Laravel APP_URL to its externally reachable URL,
run `php artisan storage:link` where needed for avatars/slips, and configure the web server for HTTPS.

The shop map uses flutter_map with OpenStreetMap tiles and needs no Google Maps key.
Tiles require an internet connection. Attribution is displayed in the picker.
A real HTTPS deployment URL must be supplied by the project owner.

Backend changes include additive collector-tracking and sale-stock-allocation migrations. Back up the deployment database,
then run `php artisan migrate` during rollout before using the updated API. Existing invoice and shop balances
are not rewritten. Shop debt without matching invoices must be reconciled before it can be collected.
