# Implementation Plan - Phase 1: Project Audit & Foundation

Upgrade **Ai Learn Mate** from a basic AI tool to a comprehensive adaptive learning system. Phase 1 focuses on building the foundational models, providers, and a smart dashboard.

## User Review Required

> [!IMPORTANT]
> The current `UserModel` is very basic. I am extending it to include learning-specific data like `xp`, `level`, `streak`, and `studyTime`. This will require a Firestore data migration for existing users (or handling defaults gracefully).

## Open Questions

- Should we keep the existing `HomeDashboard` typewriter effect, or move to a more data-rich dashboard immediately?
- For the "Knowledge Map", do you have a specific visualization preference (List-based vs. Graph-based)?

## Proposed Changes

### [Models]

I will create a set of comprehensive models to represent the learning ecosystem.

#### [MODIFY] [user_model.dart](file:///C:/Ai%20Learn%20Mate/lib/models/user_model.dart)
Update with learning progress fields.

#### [NEW] [subject_model.dart](file:///C:/Ai%20Learn%20Mate/lib/models/learning/subject_model.dart)
Represents a subject like "Mathematics" or "Computer Science".

#### [NEW] [topic_model.dart](file:///C:/Ai%20Learn%20Mate/lib/models/learning/topic_model.dart)
Represents a specific topic within a subject.

#### [NEW] [mastery_model.dart](file:///C:/Ai%20Learn%20Mate/lib/models/learning/mastery_model.dart)
Tracks student's mastery level for topics.

### [Services & Providers]

#### [NEW] [user_provider.dart](file:///C:/Ai%20Learn%20Mate/lib/services/user_provider.dart)
Manages the current user's learning state and profile.

#### [NEW] [learning_provider.dart](file:///C:/Ai%20Learn%20Mate/lib/services/learning_provider.dart)
Manages subjects, topics, and overall learning recommendations.

### [UI Components]

#### [MODIFY] [home_screen.dart](file:///C:/Ai%20Learn%20Mate/lib/screens/dashboard/home_screen.dart)
Transform the landing page into a Smart Student Dashboard.

#### [NEW] [learning_card.dart](file:///C:/Ai%20Learn%20Mate/lib/widgets/learning_card.dart)
Reusable component for displaying subject/topic progress.

## Verification Plan

### Automated Tests
- Unit tests for Model JSON serialization.
- Provider state transition tests (e.g., XP gain updating Level).

### Manual Verification
- Verify the Dashboard displays user-specific data (name, streak, XP).
- Ensure "What should I study now?" button logic triggers a mock recommendation.
