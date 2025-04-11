# 🌿 Liana Plant Mobile App

**Liana Plant** is a cross-platform mobile application built with [Flutter](https://flutter.dev), designed to provide access to the master directory platform via mobile devices. Users can easily browse, search, and interact with service providers (masters) directly from their smartphones.

> This mobile app connects to a Laravel-powered API backend, which is hosted in a separate repository.

---

## 📱 Features

- 📋 View and search for service providers (masters)
- 📍 Filter by location, category, and availability
- 🧑‍💼 View detailed master profiles with photos, descriptions, and reviews
- 📅 Book appointments (if available)
- 🔐 User authentication and profile management
- 🌐 Multi-language support

---

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Networking**: `http` package
- **Local Storage**: `shared_preferences`
- **Map Integration**: Google Maps / OpenStreetMap (via plugins)
- **Notifications**: Firebase Cloud Messaging (planned/optional)
- **API Backend**: [Laravel API Repository](https://github.com/your-api-repo-url)

---

## 🧑‍💻 Getting Started

### Prerequisites

- Flutter SDK (>= 3.x.x)
- Android Studio / Xcode (for platform-specific builds)
- An emulator or physical device
- Dart enabled

### Setup Instructions

```bash
# Clone the repository
git clone https://github.com/oleksandr-lysak/liana_plant_mobile.git
cd liana_plant_mobile

# Install dependencies
flutter pub get

# Run on connected device
flutter run
