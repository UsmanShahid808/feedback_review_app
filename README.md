# PulseFeedback — Feedback & Review App

A cross-platform Flutter app (Android/iOS/Web) with a Firebase backend for
collecting, managing, and analyzing feedback on tasks, courses, or
services. Includes a user side (submit + track feedback) and an admin
side (live dashboard, moderation, analytics charts).

## What's included

- Email/password authentication (Firebase Auth)
- Real-time feedback submission and history (Cloud Firestore, live streams)
- Star rating + animated "Sentiment Ring" visual on every rating
- Category tagging (Task / Course / Service) and status workflow
  (Pending → Reviewed → Resolved)
- Admin dashboard: stat cards, filters, moderation screen with replies
- Admin analytics: bar chart (avg rating per category), pie chart
  (status breakdown), category volume bars — via `fl_chart`
- Polished custom UI: gradient hero surfaces, Sora + Inter typography,
  animated transitions (`animate_do`)
- Firestore security rules included (`firestore.rules`)

## Project structure

```
lib/
  main.dart                     # App entry point, Firebase init
  firebase_options.dart         # PLACEHOLDER — regenerate with FlutterFire CLI
  theme/app_theme.dart          # Colors, gradients, typography, component themes
  models/feedback_model.dart    # FeedbackModel + AppUser
  services/
    auth_service.dart           # Sign up / sign in / sign out / profile
    feedback_service.dart       # Firestore CRUD + real-time streams
  widgets/common_widgets.dart   # SentimentRing, StarRatingInput, GradientButton,
                                 # FeedbackCard, StatCard, EmptyState
  screens/
    splash_screen.dart
    auth/login_screen.dart, signup_screen.dart
    user/  (bottom-nav shell, home, submit, history, detail, profile)
    admin/ (bottom-nav shell, dashboard, moderation, analytics)
```

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
source (`lib/`), `pubspec.yaml`, and Firestore rules — but not the
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
  your real project's configuration — no manual key-copying needed.

For Android specifically, also make sure `android/app/build.gradle`
has a `minSdkVersion` of at least 21 (FlutterFire CLI usually handles
this automatically).

### 5. Deploy the Firestore security rules
Install the Firebase CLI if you don't have it:
```bash
npm install -g firebase-tools
firebase login
firebase init firestore   # point it at the same project, keep default file names
```
Copy the contents of `firestore.rules` (included in this project) into
the generated `firestore.rules` file, then deploy:
```bash
firebase deploy --only firestore:rules
```

### 6. Run the app
```bash
flutter run
```
Pick a connected device/emulator when prompted. For web:
```bash
flutter run -d chrome
```

### 7. Try it out
1. Sign up with a new account — **the very first account created
   automatically becomes an admin** (see `AuthService.signUp`), so use
   it to explore the admin dashboard and analytics.
2. Sign up a second account normally to test the regular user flow:
   submit feedback, watch it appear instantly, see the admin reply
   once you respond to it from the admin account.

### 8. (Optional) Change the admin rule
Auto-promoting the first sign-up is meant for quick demos. For a real
rollout, remove that logic in `AuthService.signUp` and instead set
`isAdmin: true` manually on specific users' documents inside the
Firebase Console → Firestore → `users` collection.

### 9. Build a release
```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (via Xcode)
flutter build web --release      # Web
```

## Notes
- All screens use real-time Firestore streams — multiple devices stay
  in sync automatically, no manual refresh needed.
- The "Sentiment Ring" and gradient system in `app_theme.dart` is the
  one visual idea reused everywhere ratings appear, so update the
  colors there to re-skin the whole app at once.
