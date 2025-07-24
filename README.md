# 🔒 Pascii — Offline-First Password Manager

*A secure, open-source password manager built with Flutter, featuring biometric authentication, AES encryption, and 100% offline storage.*

<p align="center">
  <img src="screenshots/homescreen.jpeg" width="400" alt="Pascii Home Screen" />
</p>

<p align="center">
  <a href="https://github.com/cxuri/pascii/stargazers">
    <img alt="GitHub Stars" src="https://img.shields.io/github/stars/cxuri/pascii?style=for-the-badge">
  </a>
  <a href="LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/cxuri/pascii?style=for-the-badge">
  </a>
  <a href="https://flutter.dev">
    <img alt="Flutter Version" src="https://img.shields.io/badge/Flutter-3.19.0-blue?style=for-the-badge">
  </a>
  <a href="https://pub.dev/packages/hive">
    <img alt="Hive" src="https://img.shields.io/badge/Hive-NoSQL%20DB-orange?style=for-the-badge">
  </a>
</p>

---

## ✨ Features

- 🔐 **Military-Grade Security** — AES-256 encryption + Flutter Secure Storage for keys.
- 📱 **Biometric Authentication** — Unlock with Face ID or fingerprint.
- 💾 **100% Offline** — No cloud, no tracking — data stays on your device.
- 🔄 **Lazy Decryption** — Only decrypts passwords when accessed.
- 📝 **Secure Notes** — Store notes and non-password data securely.
- 🎨 **Themes & Customization** — Dark/light mode with accent colors.
- 📊 **Password Strength Analyzer** — Built-in checker for strong credentials.

---

## 📸 Screenshots

### 🏠 Main UI

| Home Screen | Create Password | View Password |
|-------------|------------------|----------------|
| <img src="creenshots/homescreen.jpeg" width="250" alt="Home screen" /> | <img src="screenshots/create password.jpeg" width="250" alt="Create password" /> | <img src="screenshots/password view.png" width="250" alt="View password" /> |

### 🗒️ Notes UI

| Create/View Note | Stored Notes |
|------------------|--------------|
| <img src="screenshots/create and view note.jpeg" width="250" alt="Create and view note" /> | <img src="screenshots/stored notes.jpeg" width="250" alt="Stored notes" /> |

---

## 🛠️ Installation

### 📦 Requirements
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or Xcode for emulators/simulators

### 🚀 Quick Start

```bash
git clone https://github.com/cxuri/pascii.git
cd pascii
flutter pub get
flutter run
```

---

## 📱 Usage

1. Set a master password on first launch.
2. Enable biometrics for quick access (optional).
3. Store:
   - 🔑 Passwords
   - 📝 Secure Notes
4. Use the built-in strength analyzer to improve your passwords.

---

## 📤 Backup & Export

Pascii stores all data locally using [Hive](https://pub.dev/packages/hive).
💡 **Tip:** Back up your Hive box manually.
📦 Import/export functionality coming soon!

---

## 🤝 Contributing

We love contributions! Here's how to help:

### 💡 How to Contribute

```bash
# Fork this repository
git checkout -b feature/my-feature
git commit -am "Add awesome feature"
git push origin feature/my-feature
# Then open a Pull Request 🎉
```

### 🧪 Testing Before PR

```bash
flutter analyze
flutter test
```

---

## 🌟 Support the Project

If you find **Pascii** helpful:

- ⭐ Star the repo
- 🐛 Report bugs or request features
- 🧑‍💻 Contribute code, translations, or documentation
- 📢 Share it with privacy-conscious friends!

---

## 📄 License

Licensed under the [MIT License](LICENSE).

---

## 🔗 Related Links

- 🧰 [Flutter](https://flutter.dev)
- 📦 [Hive DB](https://pub.dev/packages/hive)
- 🔐 [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

> Built with ❤️ by [@cxuri](https://github.com/cxuri)
