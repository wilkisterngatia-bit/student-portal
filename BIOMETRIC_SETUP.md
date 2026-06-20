# Setting up fingerprint authentication (local_auth)

The "Join lesson" biometric prompt uses the `local_auth` package, which
needs a couple of small native config changes. These are one-time setup
steps in your Android/iOS project files (not Dart code).

## Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Make sure `minSdkVersion` is at least 23. In `android/app/build.gradle`,
   find:
   ```
   defaultConfig {
       minSdkVersion flutter.minSdkVersion
   ```
   Change it to:
   ```
   defaultConfig {
       minSdkVersion 23
   ```
3. Open `android/app/src/main/kotlin/.../MainActivity.kt` (or `.java` if
   your project still uses Java). Change the base class from
   `FlutterActivity` to `FlutterFragmentActivity`:
   ```kotlin
   import io.flutter.embedding.android.FlutterFragmentActivity

   class MainActivity: FlutterFragmentActivity() {
   }
   ```

## iOS

1. Open `ios/Runner/Info.plist`
2. Add this entry (required for Face ID):
   ```xml
   <key>NSFaceIDUsageDescription</key>
   <string>This app uses Face ID to confirm your identity before joining an online lesson.</string>
   ```

## Testing

- On Chrome/web: the fingerprint prompt is simulated automatically (a
  short delay, then it succeeds) since browsers have no biometric
  sensor API. This is expected and lets you demo the flow without a
  phone.
- On a real Android/iOS device: run with `flutter run` (no `-d chrome`)
  and the OS's real fingerprint or face prompt will appear when you tap
  "Join" on an online lesson in the Timetable screen.
