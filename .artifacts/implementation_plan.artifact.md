# Complete AI Learn Mate Integration Plan

This plan details the steps required to redesign and integrate the existing "Ai Learn Mate" Flutter application to match the specified premium dark futuristic education design, while preserving and enhancing the core logic (timer, sharing, AI integration).

## User Review Required

> [!IMPORTANT]
> - **Visual Design Consistency:** The entire app will switch to the precise design tokens requested (`#0B0B14` for background, `#15151F` for cards, `#FFB020` for accent).
> - **Existing vs New Files:** I will preserve `pomodoro_timer_provider.dart` and `share_service.dart` but update their corresponding UI screens (`focus_timer_screen.dart` and sharing dialogs) to use the new unified design system.
> - **Vercel / Web Build:** The plan will ensure `flutter build web` works without compilation errors by maintaining proper imports and removing dart:html or mobile-only dependencies where possible.

## Open Questions

- Are there any specific Hugging Face models you prefer for the Scanner OCR / Summarization, or should we rely on the existing implementations (e.g., Google ML Kit + Groq)?
- Do you have a specific logo asset to use, or should I build a typographic `AppLogo` widget using an icon + styled text? (I will build the typographic one by default).

## Proposed Changes

### Core Theme & Design System
We will consolidate all styling into a single `ThemeService` and `AppColors` file.

#### [MODIFY] [theme_service.dart](file:///C:/Ai%20Learn%20Mate/lib/services/theme_service.dart)
Update `AppColors` to use exactly `#0B0B14`, `#15151F`, and `#FFB020`. Create centralized text styles, borders, and button styles.

#### [NEW] [app_theme.dart](file:///C:/Ai%20Learn%20Mate/lib/core/theme/app_theme.dart)
Create a centralized `AppTheme` containing `ThemeData` and reusable design tokens (radius, shadows, glowing effects).

#### [NEW] [app_logo.dart](file:///C:/Ai%20Learn%20Mate/lib/widgets/app_logo.dart)
Create `AppLogo` and `AppLogoCompact` widgets displaying the AI-inspired book icon with "AI Learn" in light text and "Mate" in amber.

---

### Authentication & Landing

#### [NEW] [landing_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/landing_screen.dart)
Build the requested marketing landing page featuring the hero badge, main heading ("Smarter learning for a brighter future"), and the feature bento grid cards with hover animations.

#### [MODIFY] [login_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/auth/login_screen.dart)
#### [MODIFY] [signup_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/auth/signup_screen.dart)
Refactor login and registration to use the new dark theme, add role selection (Student/Teacher/Parent), and Apple/Google social login buttons matching the reference.

---

### Student Dashboard & Navigation

#### [MODIFY] [home_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/home_screen.dart)
Update the main dashboard to greet the user, show "Questions to Review", "Today's Study Plan", "Study Streak", and the interactive grid of features.

#### [MODIFY] [bottom_navbar.dart](file:///C:/Ai%20Learn%20Mate/lib/widgets/bottom_navbar.dart)
Update colors (amber selected, gray unselected, subtle top glow) and ensure it maps to the correct new navigation structure (Home, Study, AI Tutor, Progress, Profile).

---

### Study Features (AI Tutor, Notes, Quizzes, Flashcards)

#### [MODIFY] [chat_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/chat_screen.dart)
Refactor into `AITutorScreen` with streaming text responses, thought processes/loading indicators, and action buttons to "Save as Note" or "Generate Quiz".

#### [MODIFY] [notes_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/notes_screen.dart)
Implement the Notes system with Folders/Tags, AI summarization, and the existing sharing architecture.

#### [MODIFY] [quiz_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/quiz_screen.dart)
#### [MODIFY] [mistake_bank_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/mistake_bank_screen.dart)
Wire wrong quiz answers directly into the Mistake Bank. Update the Mistake Bank UI to show spaced-repetition cues ("Questions waiting for you").

#### [MODIFY] [flashcard_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/flashcard_screen.dart)
Add 3D flip animations, spaced repetition buttons (Easy, Hard, Again, Known), and connect to the existing share mechanism.

---

### Timer, Analytics & Scanner

#### [MODIFY] [focus_timer_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/focus_timer_screen.dart)
Redesign to match the premium theme. Ensure it uses `PomodoroTimerProvider` seamlessly without modifying the underlying DateTime logic. Add circular progress ring.

#### [MODIFY] [analytics_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/analytics_screen.dart)
Refactor charts using `fl_chart` to display Study Time, Quiz Accuracy, and Subject Performance elegantly.

#### [MODIFY] [camera_solver_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/camera_solver_screen.dart)
Enhance the scanner UI to handle OCR correctly and pass text to the AI Tutor for explanations or flashcard generation.

---

### Sharing System & Profile

#### [MODIFY] [share_widgets.dart](file:///C:/Ai%20Learn%20Mate/lib/widgets/share_widgets.dart)
Update the Share dialog and "Shared With Me" joining input fields to use the premium dark UI (removing generic dialog looks).

#### [MODIFY] [profile_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/profile/profile_screen.dart)
#### [MODIFY] [firestore.rules](file:///C:/Ai%20Learn%20Mate/firestore.rules)
Add the required rules for `shared_items` (Owner vs Collaborator/Viewer). Update the profile screen to show stats and settings gracefully.

---

## Verification Plan

### Automated Build Checks
- `flutter analyze` to ensure zero lints.
- `flutter build web` to ensure clean Vercel compilation.
- `flutter test` for provider logic (timer, sharing).

### Manual Verification
- Run the timer, background the app, resume, and verify no drift.
- Answer a quiz incorrectly and check that the Mistake Bank updates.
- Share a note and use a secondary account to join via the 6-character code.
- Check responsive behavior across Mobile and Web bounds.