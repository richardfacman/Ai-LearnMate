#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Creating .env file..."
cat << EOF > .env
GROQ_API_KEY=${GROQ_API_KEY:-}
GROQ_MODEL=${GROQ_MODEL:-openai/gpt-oss-120b}
GEMINI_API_KEY=${GEMINI_API_KEY:-}
GEMINI_MODEL=${GEMINI_MODEL:-gemini-3.5-flash}
OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-}
OPENROUTER_MODEL=${OPENROUTER_MODEL:-google/gemini-3.5-flash}
NVIDIA_API_KEY=${NVIDIA_API_KEY:-}
EOF

echo "Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter

export PATH="$PATH:`pwd`/_flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Building Flutter web app..."
flutter config --enable-web
flutter pub get
flutter build web --release
