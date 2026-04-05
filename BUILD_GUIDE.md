# Scripture Daily — Build Guide

## ─── STEP 1: Run the app immediately (Demo Mode) ──────────────────────────

No setup needed. Auth works in demo mode (any valid email/password).

```powershell
flutter pub get
flutter run
```

---

## ─── STEP 2: Build a Debug APK ───────────────────────────────────────────

```powershell
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`
Install on phone: connect phone via USB with Developer Mode on, then:
```powershell
flutter install
```

---

## ─── STEP 3: Build a Release APK ──────────────────────────────────────────

### 3a. Generate a keystore (one time only)
```powershell
keytool -genkey -v -keystore scripture_daily.jks -keyalg RSA -keysize 2048 -validity 10000 -alias scripture_daily
```
Save the `.jks` file somewhere safe. You will need it for every release.

### 3b. Create android/key.properties
Copy `android/key.properties.template` to `android/key.properties` and fill in:
```
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=scripture_daily
storeFile=C:/path/to/scripture_daily.jks
```

### 3c. Build the release APK
```powershell
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 3d. Build a split APK (smaller file per architecture — recommended)
```powershell
flutter build apk --split-per-abi
```
Outputs:
- `app-armeabi-v7a-release.apk`  (older/32-bit phones)
- `app-arm64-v8a-release.apk`    (most modern phones ← use this)
- `app-x86_64-release.apk`       (emulators)

---

## ─── STEP 4: Connect Real Firebase ────────────────────────────────────────

### 4a. Create Firebase project
1. Go to https://console.firebase.google.com
2. Create project → name it "Scripture Daily"
3. Enable: Authentication → Email/Password, Google, Apple
4. Enable: Firestore → Create database → Production mode

### 4b. Connect Flutter to Firebase
```powershell
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```
This auto-generates `lib/firebase_options.dart` and downloads config files.

### 4c. Uncomment Firebase in the code
In `pubspec.yaml` — uncomment the Firebase packages:
```yaml
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.8
  cloud_firestore: ^4.15.8
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0
  crypto: ^3.0.3
```

In `lib/main.dart` — uncomment:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:scripture_daily/firebase_options.dart';
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

In `lib/services/auth_provider.dart` — uncomment the LIVE blocks
and comment out the DEMO blocks.

In `lib/services/firestore_service.dart` — uncomment the LIVE blocks.

### 4d. Firestore Security Rules
In Firebase Console → Firestore → Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### 4e. Google Sign-In — Android
Add your SHA-1 fingerprint to Firebase:
```powershell
keytool -list -v -alias scripture_daily -keystore scripture_daily.jks
```
Copy the SHA-1 → Firebase Console → Project Settings → Android app → Add fingerprint.

### 4f. Run with Firebase
```powershell
flutter pub get
flutter run
```

---

## ─── App Info ──────────────────────────────────────────────────────────────

| Setting | Value |
|---------|-------|
| App ID | `com.example.scripture_daily` |
| Min SDK | 21 (Android 5.0+) |
| Target SDK | Flutter default |
| Version | 1.0.0+1 |

To change App ID, update `applicationId` in `android/app/build.gradle`
and `iosBundleId` in `lib/firebase_options.dart`.
