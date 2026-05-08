# 🤖 Ai Learn Mate

**Ai Learn Mate** is an intelligent study companion designed to help students learn smarter and faster. Leveraging AI, it summarizes notes, generates quizzes, and provides a personal AI chat for academic support.

---

## 🚀 Features

*   **📝 AI Notes Summarizer**: Paste your lengthy notes and get a concise summary in seconds using Hugging Face models.
*   **❓ AI Quiz Generator**: Automatically generate MCQs from your notes to test your knowledge.
*   **💬 AI Study Chat**: A dedicated chat assistant powered by Groq (Llama-3.1) to answer any academic questions.
*   **🃏 Flashcards**: Review key concepts with an interactive 3D flipping card interface.
*   **⏱️ Study Timer**: Stay focused with a built-in focus timer.
*   **🌓 Dark/Light Mode**: Full theme support for comfortable late-night study sessions.
*   **☁️ Cloud Sync**: All your notes and quizzes are synced across devices using Firebase.

---

## 🛠️ Tech Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Auth, Firestore)
*   **AI Engine**: 
    *   Hugging Face (Summarization)
    *   Groq API (Chat & Question Generation)
*   **State Management**: Provider
*   **Local Storage**: Hive

---

## 📦 Installation & Setup

### 1. Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   A Firebase project set up.

### 2. Clone the Repository
```bash
git clone https://github.com/richardfacman/Ai-LearnMate.git
cd Ai-LearnMate
```

### 3. Setup Environment Variables
Create a `.env` file in the root directory and add your API keys:
```env
HUGGING_FACE_API_KEY=your_key_here
GROQ_API_KEY=your_key_here
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
# Run on Windows
flutter run -d windows

# Run on Edge (Web)
flutter run -d edge

# Build APK
flutter build apk --debug
```

---

## 📸 Screenshots

| Login | Dashboard | AI Chat |
|---|---|---|
| ![Login](https://via.placeholder.com/200) | ![Dashboard](https://via.placeholder.com/200) | ![Chat](https://via.placeholder.com/200) |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
