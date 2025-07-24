# 🔒 Pascii — Offline-First Password Manager

*A secure, open-source password manager built with Flutter, featuring biometric authentication, AES encryption, and 100% offline storage.*

<p align="center">
  <img src="screenshots/homescreen.jpeg" width="300" alt="Pascii Home Screen" />
</p>

<p align="center">
  <a href="https://github.com/cxuri/pascii/stargazers">
    <img src="https://img.shields.io/github/stars/cxuri/pascii?style=flat-square&color=FFD700&label=Stars" alt="GitHub Stars">
  </a>
  <a href="https://github.com/cxuri/pascii/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/cxuri/pascii?style=flat-square&color=blue&label=License" alt="License">
  </a>
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Flutter-3.19.0-blue?style=flat-square&logo=flutter" alt="Flutter Version">
  </a>
  <a href="https://pub.dev/packages/hive">
    <img src="https://img.shields.io/badge/Database-Hive-orange?style=flat-square&logo=hive" alt="Hive">
  </a>
</p>

---

## ✨ Features

- 🔐 **Military-Grade Security** — AES-256 + Secure Key Storage
- 📱 **Biometric Authentication** — Fingerprint / FaceID
- 💾 **100% Offline** — No cloud, no tracking
- 🔄 **Lazy Decryption** — Decrypts only when needed
- 📝 **Secure Notes** — Store more than passwords
- 🎨 **Theming** — Dark/light modes, accent colors
- 📊 **Strength Analyzer** — Built-in password quality checker

---

## 📸 Screenshots

### 🏠 Main UI

| Home Screen | Create Password | View Password |
|-------------|------------------|----------------|
| <img src="screenshots/homescreen.jpeg" width="220" /> | <img src="screenshots/create password.jpeg" width="220" /> | <img src="screenshots/password view.png" width="220" /> |

### 🗒️ Notes UI

| Create/View Note | Stored Notes |
|------------------|--------------|
| <img src="screenshots/create and view note.jpeg" width="220" /> | <img src="screenshots/stored notes.jpeg" width="220" /> |

---

## 🛠️ Installation

### 📦 Requirements
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio / Xcode (for running emulator/simulator)

### 🚀 Quick Start

```bash
git clone https://github.com/cxuri/pascii.git
cd pascii
flutter pub get
flutter run
```

---

## 📱 Usage

1. Store:
   - 🔑 Passwords
   - 📝 Secure Notes
2. Use the **strength analyzer** to improve your credentials.

---

## 📤 Backup & Export

All data is stored **locally** using [Hive](https://pub.dev/packages/hive).

💡 Tip: Backup your encrypted Hive box file manually.
📦 Import/export feature coming soon!

---

## 🤝 Contributing

We welcome contributions!

### 💡 How to Contribute

```bash
# Fork the repo
git checkout -b feature/my-feature
git commit -am "Add awesome feature"
git push origin feature/my-feature
```

Then open a **Pull Request**.

### ✅ Run Tests Before PR

```bash
flutter analyze
flutter test
```

---

## 🌟 Support the Project

If you find **Pascii** useful:

- ⭐ Star this repo
- 🐞 Report issues or suggest features
- 🧠 Help improve docs, code or translations
- 📣 Share with other privacy-focused devs

---

## 📄 License

Licensed under the [MIT License](https://github.com/cxuri/pascii/blob/main/LICENSE)

---

## 🔗 Useful Links

- 🧰 [Flutter](https://flutter.dev)
- 📦 [Hive DB](https://pub.dev/packages/hive)
- 🔐 [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

> Built with ❤️ by [@cxuri](https://github.com/cxuri)
