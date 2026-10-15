import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:ai_learn_mate/screens/dashboard/home_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/study_workspace_screen.dart';
import 'package:ai_learn_mate/screens/dashboard/analytics_screen.dart';
import 'package:ai_learn_mate/screens/profile/profile_screen.dart';
import 'package:ai_learn_mate/services/user_provider.dart';
import 'package:ai_learn_mate/services/learning_provider.dart';
import 'package:ai_learn_mate/services/quiz_provider.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';
import 'package:ai_learn_mate/services/flashcard_provider.dart';
import 'package:ai_learn_mate/services/planner_provider.dart';
import 'package:ai_learn_mate/services/exam_provider.dart';
import 'package:ai_learn_mate/services/analytics_provider.dart';
import 'package:ai_learn_mate/services/achievement_provider.dart';
import 'package:ai_learn_mate/services/pomodoro_timer_provider.dart';
import 'package:ai_learn_mate/services/theme_service.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

Widget createTestableWidget(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeService()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => LearningProvider()),
      ChangeNotifierProvider(create: (_) => QuizProvider()),
      ChangeNotifierProvider(create: (_) => MasteryProvider()),
      ChangeNotifierProvider(create: (_) => FlashcardProvider()),
      ChangeNotifierProvider(create: (_) => PlannerProvider()),
      ChangeNotifierProvider(create: (_) => ExamProvider()),
      ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ChangeNotifierProvider(create: (_) => PomodoroTimerProvider()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('HomeScreen Navigation Tests', () {
    testWidgets('Home screen initializes at index 0 showing HomeDashboard', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.byType(HomeDashboard), findsOneWidget);
    });

    testWidgets('Tapping Study tab switches view to StudyWorkspaceScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pump();

      final studyTab = find.text('Study');
      expect(studyTab, findsWidgets);

      await tester.tap(studyTab.first);
      await tester.pump();

      expect(find.byType(StudyWorkspaceScreen), findsOneWidget);
    });

    testWidgets('Tapping Progress tab switches view to AnalyticsScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pump();

      final progressTab = find.text('Progress');
      expect(progressTab, findsWidgets);

      await tester.tap(progressTab.first);
      await tester.pump();

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('Tapping Profile tab switches view to ProfileScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomeScreen()));
      await tester.pump();

      final profileTab = find.text('Profile');
      expect(profileTab, findsWidgets);

      await tester.tap(profileTab.first);
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
