## Step-by-step setup (A to Z)

### 1. Install prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.19+ recommended)
- Android Studio (for the Android emulator) and/or Xcode (for iOS, macOS only)
- A free [Firebase](https://console.firebase.google.com) account

Verify Flutter is installed correctly:
```bash
flutter doctor
```

### 2. Get the project onto your machine
Unzip the project you downloaded. This package contains the Dart
source (`lib/`), `pubspec.yaml`, and Firestore rules - but not the
native `android/`, `ios/`, `web/` platform folders (those are
machine-generated). From inside the unzipped folder, generate them:
```bash
flutter create --project-name feedback_review_app --org com.example .
```
This scaffolds the platform folders **without** touching your existing
`lib/` code or `pubspec.yaml` dependencies. Then fetch the packages:
```bash
flutter pub get
```

### 3. Create a Firebase project
1. Go to https://console.firebase.google.com → **Add project**
2. Name it (e.g. `pulse-feedback`) → finish the wizard
3. In the project, open **Build → Authentication → Get started** →
   enable the **Email/Password** sign-in method
4. Open **Build → Firestore Database → Create database** → start in
   **production mode** (rules are provided below) → choose a region

### 4. Connect the Flutter app to Firebase (generates real API keys)
Install the FlutterFire CLI once:
```bash
dart pub global activate flutterfire_cli
```
Then, from the project root:
```bash
flutterfire configure
```
- Select your Firebase project
- Select the platforms you want (Android / iOS / Web)
- This **overwrites** the placeholder `lib/firebase_options.dart` with
  your real project's configuration - no manual key-copying needed.

If `flutterfire` isn't found after activating it, add Dart's global
pub-cache `bin` folder to your PATH (the CLI prints the exact path to
add when this happens).

`flutterfire configure` also requires the official Firebase CLI to be
installed:
```bash
npm install -g firebase-tools
firebase login
```

For Android specifically, also make sure `android/app/build.gradle.kts`
has a `minSdkVersion` of at least 21 (FlutterFire CLI usually handles
this automatically).

### 5. Deploy the Firestore security rules
1. Firebase Console → **Firestore Database → Rules** tab
2. Delete the existing content and paste in the contents of
   `firestore.rules` (included in this project)
3. Click **Publish**

(Alternatively, via CLI: `firebase init firestore` then
`firebase deploy --only firestore:rules`.)

### 6. Create the required Firestore index
The History and Home screens query by `userId` + `createdAt` together,
which needs a composite index:
1. Firebase Console → **Firestore Database → Indexes** tab → **Create Index**
2. Collection ID: `feedback`
3. Fields: `userId` (Ascending), `createdAt` (Descending)
4. Create, and wait for status to switch from "Building" to "Enabled"
   (usually 1-5 minutes)

Tip: if you skip this step, the app will show a clear on-screen error
with a link you can open to auto-create the correct index instead.

### 7. Run the app
```bash
flutter run
```
Pick a connected device/emulator when prompted. For web:
```bash
flutter run -d chrome
```

### 8. Try it out
1. Sign up with a new account - **the very first account created
   automatically becomes an admin** (see `AuthService.signUp`), so use
   it to explore the admin dashboard and analytics.
2. Sign up a second account normally to test the regular user flow:
   submit feedback, watch it appear instantly, search/edit/delete it,
   and see the admin reply once you respond to it from the admin account.
3. Toggle Dark mode from the Profile tab.

### 9. (Optional) Change the admin rule
Auto-promoting the first sign-up is meant for quick demos. For a real
rollout, remove that logic in `AuthService.signUp` and instead set
`isAdmin: true` manually on specific users' documents inside the
Firebase Console → Firestore → `users` collection.

### 10. Build a release
```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (via Xcode)
flutter build web --release      # Web
```

## Notes
- All screens use real-time Firestore streams - multiple devices stay
  in sync automatically, no manual refresh needed.
- The "Sentiment Ring" and gradient system in `app_theme.dart` is the
  one visual idea reused everywhere ratings appear, so update the
  colors there to re-skin the whole app at once.
- Editing/deleting feedback is only allowed while status is "Pending",
  both in the UI and enforced server-side in `firestore.rules` - once
  an admin reviews it, the item is locked for the original author.