# Internal Beta Checklist

## Required `--dart-define` values

- `API_BASE_URL`
- `REALTIME_URL`

The app now fails fast in non-debug modes if these are left at placeholder defaults.

## Android release prerequisites

- Set unique package:
  - `namespace` and `applicationId` in `android/app/build.gradle.kts`
- Add `android/app/keystore.properties` with:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`
- Ensure `android/app/src/main/AndroidManifest.xml` has `INTERNET` permission.

## Quality gate before every beta build

1. `dart format .`
2. `dart analyze`
3. `flutter test`

## Build command example

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://staging-api.example --dart-define=REALTIME_URL=wss://staging-realtime.example
```
