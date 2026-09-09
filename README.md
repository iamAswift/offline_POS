# Creator Yard

A responsive, offline-first **POS and inventory management application** built with Flutter for retail businesses.

## Features

- Point of Sale with cash, POS, transfer and split payments
- Product, category and stock management
- Supplier and delivery management
- Staff and attendance management
- Sales, profit and inventory reports
- Configurable 58mm, 80mm and A4 receipts
- Configurable business identity
- Optional transactional email and email credits
- Responsive layouts for phones, tablets, POS devices and desktop

## Technology

**Flutter · Dart · Drift · SQLite · Cloudflare Workers · Cloudflare D1 · Resend · Flutterwave**

Core POS and inventory functionality works locally using SQLite. External services are only required for features that need them.

## Run Locally

Requirements:

- Flutter SDK
- Android SDK for Android development
- Xcode for macOS/iOS development

Clone and run:

```bash
git clone <PUBLIC_REPOSITORY_URL>
cd supermarket_inventory
flutter pub get
flutter analyze
flutter run -d macos
```

For Android:

```bash
flutter devices
flutter run -d <DEVICE_ID>
```

## Email & External Services

Transactional email is optional. The public repository does **not** contain production API credentials, payment secrets, email-provider secrets, signing keys or production databases.

For authorized local development:

```bash
flutter run -d macos \
  --dart-define=CREATOR_YARD_EMAIL_API_TOKEN='YOUR_TOKEN'
```

**Never commit production credentials to the repository.**

## Commercial Demo

Creator Yard is provided here so prospective users and developers can inspect and test the application before purchasing or deploying a production version.

Production infrastructure and credentials are maintained separately from the public source code.

## License

Commercial licensing may apply to production use, redistribution, modification or deployment. Contact the project owner for licensing information.
