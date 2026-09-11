#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter

export PATH="$PATH:`pwd`/_flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Building Flutter web app..."
flutter config --enable-web
flutter pub get
flutter build web --release
