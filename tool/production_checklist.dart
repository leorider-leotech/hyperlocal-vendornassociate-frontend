void main() {
  const items = [
    'Verify .env is configured with production endpoints and secrets',
    'Run flutter pub get && flutter analyze && flutter test',
    'Execute flutter build apk --release and flutter build web --release',
    'Upload release artefacts to distribution channels',
    'Confirm Firebase messaging keys and payment gateways are in sandbox/production',
    'Validate offline queue by simulating connectivity loss and resuming actions',
    'Update changelog and notify stakeholders',
  ];

  print('Production readiness checklist:\n');
  for (final item in items) {
    print('[ ] $item');
  }
}
