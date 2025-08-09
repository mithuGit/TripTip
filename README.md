<div align="center">
  <img src="assets/logo.png" alt="TripTip Logo" width="150" height="150"/>
</div>

# TripTip - Collaborative Travel App

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

</div>

**TripTip** is a comprehensive collaborative travel planning application built with Flutter and Firebase. Plan trips with friends, discover new places, manage expenses, and create unforgettable travel experiences together.

## Features

<div align="center">

| Feature | Description |
|---------|-------------|
| **Trip Management** | • Create and manage collaborative trips<br>• Invite friends and family members<br>• Set trip dates and destinations<br>• Admin controls for trip organizers |
| **Interactive Maps** | • Google Maps integration with real-time location<br>• Place recommendations based on interests<br>• Route planning with directions<br>• Custom markers for different place types<br>• Distance and duration calculations |
| **Expense Tracking** | • Split expenses among trip members<br>• Stripe integration for secure payments<br>• Payment requests and settlements<br>• Expense categorization |
| **Personalized Recommendations** | • AI-powered place suggestions<br>• Interest-based filtering<br>• Photo galleries for places<br>• User ratings and reviews |
| **Authentication & Security** | • Firebase Authentication<br>• Google Sign-In integration<br>• Facebook Login support<br>• Secure user data management |
| **User Experience** | • Modern Material Design UI<br>• Dark/Light theme support<br>• Offline capabilities<br>• Push notifications<br>• Multi-language support |

</div>

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0 <=3.15.0)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/mithuGit/TripTip.git
   cd TripTip
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API Keys**

   **Important**: All API keys need to be configured before running the app.

   **Firebase Configuration:**

   - Run `flutterfire configure` to set up Firebase for your project
   - Or manually update `lib/firebase_options.dart` with your Firebase config

   **Google Maps API:**

   - Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Update `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
     ```
   - Update `lib/ui/views/map/directions_repository.dart`:
     ```dart
     const String googleDirectionsApiKey = 'YOUR_GOOGLE_DIRECTIONS_API_KEY_HERE';
     ```
   - Update `lib/core/services/placeApiProvider.dart`:
     ```dart
     static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';
     ```

   **Stripe Configuration:**

   - Get keys from [Stripe Dashboard](https://dashboard.stripe.com/)
   - Update `lib/main.dart`:
     ```dart
     const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY_HERE';
     ```

   **Facebook Login (Optional):**

   - Configure at [Facebook Developers](https://developers.facebook.com/)
   - Update `android/app/src/main/res/values/strings.xml`:
     ```xml
     <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID_HERE</string>
     <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN_HERE</string>
     ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   └── services/           # Core business logic services
│       ├── placeApiProvider.dart
│       ├── map_service.dart
│       └── init_pushnotifications.dart
├── ui/
│   ├── styles/            # App themes and styling
│   ├── widgets/           # Reusable UI components
│   └── views/             # Screen implementations
│       ├── dashboard/     # Main dashboard screens
│       ├── map/          # Map and location features
│       ├── trip_setup_pages/ # Trip creation and management
│       ├── payments/      # Payment and expense features
│       └── profile/       # User profile management
├── firebase_options.dart  # Firebase configuration
└── main.dart              # App entry point
```

## Built With

### **Frontend Framework**

- **Flutter** - Cross-platform mobile app development
- **Dart** - Programming language
- **Material Design** - UI/UX framework

### **Backend & Services**

- **Firebase** - Backend-as-a-Service
  - **Firestore** - NoSQL database
  - **Authentication** - User management
  - **Cloud Functions** - Serverless functions
  - **Cloud Storage** - File storage
  - **Cloud Messaging** - Push notifications

### **Maps & Location**

- **Google Maps API** - Interactive maps
- **Google Places API** - Place search and details
- **Google Directions API** - Route planning
- **Geolocator** - Device location services

### **Payments**

- **Stripe** - Payment processing
- **Flutter Stripe** - Stripe SDK integration

### **Key Dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.8
  cloud_firestore: ^4.15.8
  google_maps_flutter: ^2.5.3
  flutter_stripe: ^7.0.0
  go_router: ^12.1.3
  provider: ^6.1.1
```

## Configuration

### Environment Setup

1. **Android Configuration**

   - Minimum SDK: 21
   - Target SDK: 34
   - Compile SDK: 34

2. **iOS Configuration** (if applicable)

   - iOS Deployment Target: 12.0

3. **Permissions**
   The app requires the following permissions:
   - Location access (fine and coarse)
   - Internet access
   - Camera access
   - Storage access
   - Notification permissions

## Usage

<div align="center">

| Action | Steps |
|--------|-------|
| **Creating a Trip** | 1. Sign in with Google or Facebook<br>2. Tap "Create Trip" on the dashboard<br>3. Enter destination and trip dates<br>4. Invite trip members<br>5. Start planning activities and expenses |
| **Using the Map** | 1. Navigate to the Map tab<br>2. Allow location permissions<br>3. Search for places or tap on the map<br>4. View recommendations based on your interests<br>5. Get directions between locations |
| **Managing Expenses** | 1. Go to the Payments section<br>2. Add new expenses<br>3. Split costs among trip members<br>4. Send payment requests<br>5. Track who owes what |

</div>

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter/Dart style conventions
- Write tests for new features
- Update documentation as needed
- Ensure all API keys are configurable

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

- All API keys are externalized and not committed to the repository
- Firebase Security Rules protect user data
- Stripe handles secure payment processing
- User authentication is managed by Firebase Auth

## Support

For support, please contact:

- **GitHub Issues**: [Create an issue](https://github.com/mithuGit/TripTip/issues)

## Acknowledgments

- **Flutter Team** - For the amazing framework
- **Firebase Team** - For the comprehensive backend services
- **Google Maps Platform** - For location services
- **Stripe** - For payment infrastructure
- **Open Source Community** - For the countless packages and tools

---

**Made by the TripTip Team**

### Team Members

- [Tim Carlo](https://github.com/tim-carlo)
- [Felix Bauer](https://github.com/FelixBauer01)
- [Thai Binh Nguyen](https://github.com/thaibinhnguyen7777777)
- [David](https://github.com/cmbe420)
- [Mithu](https://github.com/mithuGit)
