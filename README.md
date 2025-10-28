# Appydex Vendor Console

Production-ready Flutter frontend for the Appydex hyperlocal vendor platform. The app targets Android and Web with a responsive Material 3 experience, OTP-based authentication, KPI dashboard, service/lead/order management, and integrations for payments, referrals, and notifications.

## Features

- OTP login, session persistence via secure storage, and automatic refresh handling.
- Vendor dashboard with KPI cards, quick actions, and adaptive navigation.
- Service catalogue listing with image support and CRUD hooks.
- Leads and orders boards with status transitions and retry-friendly actions.
- Subscription, referral, and profile surfaces ready for payment gateway wiring.
- Firebase messaging, Sentry crash reporting, and offline-safe storage fallbacks.

## Project structure

```
lib/
  src/
    core/        # bootstrap, theme
    features/    # feature-specific screens/controllers
    models/      # data models
    providers/   # service and global providers
    services/    # API, auth, vendor, secure storage wrappers
    utils/       # shared helpers
```

## Getting started

1. Install Flutter 3.22+ (`flutter --version`).
2. Copy environment template and fill credentials:
   ```bash
   cp .env.example .env
   ```
3. Install packages and run code generation (none required):
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d chrome   # Web
   flutter run -d android  # Android
   ```

The app reads `APP_BASE_URL` (defaults to `https://api.appydex.co`).

## Testing

```bash
flutter test
flutter test integration_test
```

CI runs `flutter analyze`, `flutter test`, and builds Android APK plus Web bundle.

## Release checklist

- [ ] Configure `.env` with production API base and keys.
- [ ] Set Android keystore in `android/key.properties` and update `build.gradle`.
- [ ] Update Firebase options (`google-services.json`, `firebase-messaging-sw.js`).
- [ ] Verify payment sandbox credentials (Razorpay/Stripe) or enable `FAKE_PAY=true`.
- [ ] Run `flutter build apk --release` and `flutter build web`.
- [ ] Upload artefacts to distribution (Play Console / hosting) and attach CI outputs.
- [ ] Run `dart run tool/production_checklist.dart` and complete outstanding items.

## Additional docs

- [API Contract](docs/api_contract.md)

## CI

GitHub Actions workflow: `.github/workflows/ci.yml`.

## Support

- For backend API questions: https://api.appydex.co/docs
- For design and UX updates: product@appydex.co
