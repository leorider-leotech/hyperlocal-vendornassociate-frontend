# Release Checklist

Use this checklist before shipping a new vendor app build to production.

## Pre-build validation
- [ ] Confirm `.env` values for API base URL, Firebase, and payment gateways are updated for production.
- [ ] Increment the app version and build number in `pubspec.yaml`.
- [ ] Verify changelog and release notes are prepared.
- [ ] Ensure the CI pipeline on `main` is green.

## QA and regression
- [ ] Run `flutter analyze` and address any warnings.
- [ ] Execute `flutter test` and review coverage reports (>80% on auth, services, orders modules).
- [ ] Run the end-to-end test suite: `flutter test integration_test`.
- [ ] Manually verify login → OTP → onboarding → dashboard → service CRUD → logout.
- [ ] Validate offline queue by disabling network, changing a lead/order status, and ensuring the change syncs when connectivity returns.
- [ ] Confirm payments test flow completes in Razorpay/Stripe sandbox.
- [ ] Send a Firebase Cloud Messaging test push and confirm notification display.
- [ ] Review accessibility using screen reader (TalkBack/VoiceOver) for critical screens.

## Build & sign
- [ ] Generate Android release build: `flutter build apk --release` (or appbundle) with production keystore.
- [ ] Generate Web release build: `flutter build web --release`.
- [ ] Attach generated `app-release.apk`/`app-release.aab` and `web-build.zip` to the release artifacts.
- [ ] For iOS, archive in Xcode with the correct signing profile (if applicable).

## Post-build
- [ ] Smoke test the release build on at least one Android device and one modern browser.
- [ ] Upload build artifacts to the distribution channel (Play Console/TestFlight/staging server).
- [ ] Tag the release commit and publish release notes.
- [ ] Monitor Sentry dashboards after rollout for regressions.

