#!/usr/bin/env bash
set -e
command -v flutter >/dev/null 2>&1 || { echo "Flutter SDK was not found in PATH."; exit 1; }
flutter create .
flutter pub get
flutter run
