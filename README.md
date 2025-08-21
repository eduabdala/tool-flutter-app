# Flutter Environment Setup

<!-- Badges -->

![Project Status](https://img.shields.io/badge/status-stopped-red)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Build](https://img.shields.io/badge/build-unavailable-red)
![Issues](https://img.shields.io/github/issues/eduabdala/tool-flutter-app)
![Python](https://img.shields.io/badge/dart-3.3.4-blue) ![Flutter](https://img.shields.io/badge/flutter-3.13-blue)

---

## Description

This document explains how to set up the Flutter environment and build the Flutter application for Windows.

---

## Table of Contents

* [Flutter Environment Setup](#flutter-environment-setup)
* [Building the Application](#building-the-application)
* [Screenshots](#screenshots)

---

## Flutter Environment Setup

### Requirements

* Ensure the Flutter SDK is installed and properly configured.
* Follow the instructions in the [Flutter Documentation](https://docs.flutter.dev/get-started/install/windows/desktop).

### Flutter Dependencies

Run the following command to fetch dependencies:

```bash
flutter pub get
```

---

## Building the Application

### Creating the Flutter Project with Windows Support

```bash
flutter create --platforms=windows flutter_tools
```

This command creates a Flutter project named `flutter_tools` with Windows support.

### Navigating to the Project Directory

```bash
cd flutter_tools
```

### Verifying the Environment

```bash
flutter doctor
```

This ensures all necessary tools are ready for Windows development.

### Running the Application on Windows

```bash
flutter run -d windows
```

The `-d windows` flag ensures the app runs in a Windows desktop environment.

### Building for Windows

```bash
flutter build windows
```

This generates the build files for distributing the application on Windows.

---

## Screenshots

<p align="center">
  <img src="assets/screenshots/Screenshot-menu-dark.png" alt="App main screen" width="600"/>
</p>
<p>Image 1: Main screen of the app.</p>

<p align="center">
  <img src="assets/screenshots/Screenshot-data-chart.png" alt="Serial communication screen" width="600"/>
</p>
<p>Image 2: Serial communication screen.</p>

<p align="center">
  <img src="assets/screenshots/Screenshot-key-derivation.png" alt="Key derivation screen" width="600"/>
</p>
<p>Image 3: Key derivation screen.</p>

<p align="center">
  <img src="assets/screenshots/Screenshot-menu-light.png" alt="App main screen in light mode" width="600"/>
</p>
<p>Image 4: Main screen in light mode with tab system.</p>

---

<!-- Personal Notes -->

> Keep the README updated with badges, version, and project status.

