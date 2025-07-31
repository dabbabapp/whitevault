# WhiteVault

**A private creative playground app** - A collaborative digital whiteboard for creative minds.

## Overview

WhiteVault is a Flutter-based collaborative whiteboard application that allows users to create, share, and collaborate on digital canvases in real-time. Perfect for brainstorming, sketching, note-taking, and creative collaboration.

## Features

- 🎨 **Digital Canvas**: Infinite canvas with drawing, text, shapes, and sticky notes
- 🔄 **Real-time Collaboration**: Multi-user editing with Firebase sync
- 📱 **Cross-platform**: Works on iOS, Android, web, and desktop
- 🖼️ **Media Support**: Upload images, attach files, record voice memos
- ↩️ **Undo/Redo**: Full state management with 20-level history
- 🎨 **Customization**: Color picker, different shapes and tools
- 🔐 **Authentication**: Secure Firebase Auth integration
- 💾 **Cloud Storage**: Automatic saving to Firebase Firestore
- 📄 **Export**: Export canvases to PDF (planned feature)

## Tech Stack

- **Framework**: Flutter 3.32.8
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: StatefulWidget with Firebase real-time listeners
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Platform Support**: iOS, Android, Web, macOS, Windows, Linux

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/whitevault.git
cd whitevault
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Create a Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download configuration files and place them in appropriate directories

4. Run the app:
```bash
flutter run
```

## Firebase Configuration

Make sure you have the following Firebase services enabled:
- **Authentication**: Email/password sign-in
- **Cloud Firestore**: Real-time database for canvas data
- **Storage**: File uploads and image storage

## Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@whitevault.app or create an issue in this repository.
