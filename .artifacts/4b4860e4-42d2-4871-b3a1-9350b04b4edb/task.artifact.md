# Tasks - Phase 1: Project Audit & Foundation

- `[x]` **Models**
    - `[x]` Update `UserModel` with learning progress fields
    - `[x]` Create `SubjectModel`
    - `[x]` Create `TopicModel`
    - `[x]` Create `MasteryModel`
- `[x]` **Services & Providers**
    - `[x]` Create `UserProvider` for profile management
    - `[x]` Create `LearningProvider` for subject/recommendation logic
    - `[x]` Update `main.dart` with MultiProvider
- `[x]` **UI: Smart Student Dashboard**
    - `[x]` Implement `LearningCard` widget
    - `[x]` Transform `HomeDashboard` with user stats and recommendations
    - `[x]` Add "What should I study now?" logic

# Tasks - Phase 2: AI Tutor & Document Processing

- `[x]` **AI Tutor Improvements**
    - `[x]` Add `LearningMode` enum and system prompts to `GroqService`
    - `[x]` Implement Mode Selector in `ChatScreen`
    - `[x]` Implement Quick Action Buttons (Simplify, Example, etc.)
- `[x]` **Ask My Notes & Document Processing**
    - `[x]` Create `TutorService` for document-based AI tasks
    - `[x]` Implement `NoteTutorScreen` for interactive note learning
    - `[x]` Add `.txt` file upload to `NotesScreen`

# Tasks - Phase 3: Quiz & Weakness Detection

- `[x]` **Quiz Improvements**
    - `[x]` Upgrade `QuizGenerator` to support multiple types and difficulties
    - `[x]` Implement `QuizProvider` for state management and adaptive logic
- `[x]` **Weakness Detection**
    - `[x]` Create `MistakeBank` to track incorrect answers
    - `[x]` Implement AI-driven question generation using Groq

# Tasks - Phase 4: Mastery & Retention

- `[x]` **Mastery System**
    - `[x]` Implement `MasteryProvider` and calculation logic
    - `[x]` Integrate mastery updates into the Quiz flow
- `[x]` **Retention**
    - `[x]` Create `KnowledgeMapScreen` for visual mastery tracking
    - `[x]` Implement SM-2 algorithm in `FlashcardProvider`
    - `[x]` Upgrade `FlashcardScreen` with interactive confidence ratings

# Tasks - Phase 5: Planning & Exams

- `[x]` **Study Planner**
    - `[x]` Create `PlannerProvider` and `StudyPlanModel`
    - `[x]` Implement `StudyPlannerScreen` for viewing AI sessions
- `[x]` **Exams**
    - `[x]` Create `ExamModel` and `ExamProvider`
    - `[x]` Implement Exam Countdown and Readiness on Dashboard
    - `[x]` Create `RecommendationService` for dynamic guidance

# Tasks - Phase 6: Analytics & Gamification

- `[x]` **Analytics**
    - `[x]` Create `AnalyticsProvider` for data handling
    - `[x]` Upgrade `AnalyticsScreen` with `fl_chart` visualizations
- `[x]` **Gamification**
    - `[x]` Create `AchievementModel` and `AchievementProvider`
    - `[x]` Implement `AchievementScreen`
    - `[x]` Add Daily Challenges to Home Dashboard

# Tasks - Phase 7: Extended Input & Tutor Upgrades

- `[x]` **Input Upgrades**
    - `[x]` Camera input for question solving
    - `[x]` Voice interaction logic
- `[ ]` **Tutor Personalities**
    - `[ ]` Implement Persona selection
    - `[ ]` Add Mood check-in integration
