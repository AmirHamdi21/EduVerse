import 'package:edu_verse/widgets/instructor/shared/safe_feature_back.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget appWithRouter(GoRouter router) {
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets(
    'safeFeatureBack uses the requested instructor fallback instead of dashboard',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/exam-generator/exams/42',
        routes: [
          GoRoute(
            path: '/instructor/dashboard',
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard')),
          ),
          GoRoute(
            path: '/instructor/exam-generator',
            builder: (context, state) =>
                const Scaffold(body: Text('Exam Generator')),
          ),
          GoRoute(
            path: '/instructor/exam-generator/exams/:examId',
            builder: (context, state) => Scaffold(
              body: FilledButton(
                key: const Key('feature-back'),
                onPressed: () =>
                    safeFeatureBack(context, '/instructor/exam-generator'),
                child: const Text('Back'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.tap(find.byKey(const Key('feature-back')));
      await tester.pumpAndSettle();

      expect(find.text('Exam Generator'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    },
  );

  testWidgets(
    'safeBack falls back to the correct dashboard for student instructor and ta',
    (tester) async {
      Future<void> expectFallback({
        required String initialLocation,
        required String fallbackRoute,
        required String fallbackText,
      }) async {
        final router = GoRouter(
          initialLocation: initialLocation,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard')),
            ),
            GoRoute(
              path: '/instructor/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Instructor Dashboard')),
            ),
            GoRoute(
              path: '/ta/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('TA Dashboard')),
            ),
            GoRoute(
              path: '/direct',
              builder: (context, state) => Scaffold(
                body: FilledButton(
                  key: const Key('safe-back'),
                  onPressed: () => safeBack(context, fallbackRoute),
                  child: const Text('Back'),
                ),
              ),
            ),
          ],
        );

        await tester.pumpWidget(appWithRouter(router));
        await tester.tap(find.byKey(const Key('safe-back')));
        await tester.pumpAndSettle();

        expect(find.text(fallbackText), findsOneWidget);
      }

      await expectFallback(
        initialLocation: '/direct',
        fallbackRoute: '/dashboard',
        fallbackText: 'Student Dashboard',
      );
      await expectFallback(
        initialLocation: '/direct',
        fallbackRoute: '/instructor/dashboard',
        fallbackText: 'Instructor Dashboard',
      );
      await expectFallback(
        initialLocation: '/direct',
        fallbackRoute: '/ta/dashboard',
        fallbackText: 'TA Dashboard',
      );
    },
  );

  testWidgets('safeBack pops stacked routes before using fallback', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              key: const Key('open-child'),
              onPressed: () => context.push('/child'),
              child: const Text('Dashboard'),
            ),
          ),
        ),
        GoRoute(
          path: '/child',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              key: const Key('safe-back'),
              onPressed: () => safeBack(context, '/ta/dashboard'),
              child: const Text('Child'),
            ),
          ),
        ),
        GoRoute(
          path: '/ta/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Text('TA Dashboard')),
        ),
      ],
    );

    await tester.pumpWidget(appWithRouter(router));
    await tester.tap(find.byKey(const Key('open-child')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('safe-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-child')), findsOneWidget);
    expect(find.text('TA Dashboard'), findsNothing);
  });

  testWidgets(
    'system back from a direct saved exam route falls back to Exam Generator',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/exam-generator/exams/42',
        routes: [
          GoRoute(
            path: '/instructor/exam-generator',
            builder: (context, state) =>
                const Scaffold(body: Text('Exam Generator')),
          ),
          GoRoute(
            path: '/instructor/exam-generator/exams/:examId',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  safeFeatureBack(context, '/instructor/exam-generator');
                }
              },
              child: const Scaffold(body: Text('Saved Exam Detail')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Exam Generator'), findsOneWidget);
      expect(find.text('Saved Exam Detail'), findsNothing);
    },
  );

  testWidgets(
    'system back from a direct draft route falls back to Exam Generator',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/exam-generator/drafts/99',
        routes: [
          GoRoute(
            path: '/instructor/exam-generator',
            builder: (context, state) =>
                const Scaffold(body: Text('Exam Generator')),
          ),
          GoRoute(
            path: '/instructor/exam-generator/drafts/:draftId',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  safeFeatureBack(context, '/instructor/exam-generator');
                }
              },
              child: const Scaffold(body: Text('Draft Detail')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Exam Generator'), findsOneWidget);
      expect(find.text('Draft Detail'), findsNothing);
    },
  );

  testWidgets(
    'create to draft to saved workflow keeps Exam Generator as back fallback',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/exam-generator',
        routes: [
          GoRoute(
            path: '/instructor/exam-generator',
            builder: (context, state) => Scaffold(
              body: FilledButton(
                key: const Key('create-exam'),
                onPressed: () =>
                    context.push('/instructor/exam-generator/create'),
                child: const Text('Create Exam'),
              ),
            ),
          ),
          GoRoute(
            path: '/instructor/exam-generator/create',
            builder: (context, state) => Scaffold(
              body: FilledButton(
                key: const Key('generate-draft'),
                onPressed: () => context.pushReplacement(
                  '/instructor/exam-generator/drafts/99',
                ),
                child: const Text('Generate Draft'),
              ),
            ),
          ),
          GoRoute(
            path: '/instructor/exam-generator/drafts/:draftId',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  safeFeatureBack(context, '/instructor/exam-generator');
                }
              },
              child: Scaffold(
                body: FilledButton(
                  key: const Key('save-draft'),
                  onPressed: () => context.pushReplacement(
                    '/instructor/exam-generator/exams/42',
                  ),
                  child: const Text('Save Draft'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/instructor/exam-generator/exams/:examId',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  safeFeatureBack(context, '/instructor/exam-generator');
                }
              },
              child: const Scaffold(body: Text('Saved Exam Detail')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.tap(find.byKey(const Key('create-exam')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('generate-draft')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-draft')));
      await tester.pumpAndSettle();

      expect(find.text('Saved Exam Detail'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('create-exam')), findsOneWidget);
      expect(find.text('Saved Exam Detail'), findsNothing);
    },
  );

  testWidgets(
    'system back from a direct question detail route falls back to Question Bank',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/question-bank/12',
        routes: [
          GoRoute(
            path: '/instructor/question-bank',
            builder: (context, state) =>
                const Scaffold(body: Text('Question Bank')),
          ),
          GoRoute(
            path: '/instructor/question-bank/:questionId',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  safeFeatureBack(context, '/instructor/question-bank');
                }
              },
              child: const Scaffold(body: Text('Question Detail')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Question Bank'), findsOneWidget);
      expect(find.text('Question Detail'), findsNothing);
    },
  );

  testWidgets(
    'system back from a direct question group child route falls back to group',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/instructor/question-bank/groups/7/link-questions',
        routes: [
          GoRoute(
            path: '/instructor/question-bank/groups',
            builder: (context, state) =>
                const Scaffold(body: Text('Question Groups')),
          ),
          GoRoute(
            path: '/instructor/question-bank/groups/:groupId',
            builder: (context, state) =>
                const Scaffold(body: Text('Question Group Detail')),
          ),
          GoRoute(
            path: '/instructor/question-bank/groups/:groupId/link-questions',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId'];
              return PopScope<Object?>(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) {
                    safeFeatureBack(
                      context,
                      '/instructor/question-bank/groups/$groupId',
                    );
                  }
                },
                child: const Scaffold(body: Text('Link Questions')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(appWithRouter(router));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Question Group Detail'), findsOneWidget);
      expect(find.text('Link Questions'), findsNothing);
    },
  );
}
