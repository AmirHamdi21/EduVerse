import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/admin/courses/course_staff_assignment.dart';

class _AssignmentHost extends StatefulWidget {
  final List<InstructorAssignmentDraft> initialAssignments;
  final ValueNotifier<List<InstructorAssignmentDraft>> changes;

  const _AssignmentHost({
    super.key,
    required this.initialAssignments,
    required this.changes,
  });

  @override
  State<_AssignmentHost> createState() => _AssignmentHostState();
}

class _AssignmentHostState extends State<_AssignmentHost> {
  late List<InstructorAssignmentDraft> _assignments;

  @override
  void initState() {
    super.initState();
    _assignments = List<InstructorAssignmentDraft>.from(
      widget.initialAssignments,
    );
    widget.changes.value = _assignments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CourseStaffAssignment(
        isDark: false,
        assignments: _assignments,
        availableStaff: const <StaffMemberOption>[
          StaffMemberOption(userId: 7, fullName: 'Dr. Ada Lovelace'),
        ],
        onAssignmentsChanged: (next) {
          setState(() {
            _assignments = next;
            widget.changes.value = next;
          });
        },
      ),
    );
  }
}

Widget _buildHost({
  Size? surfaceSize,
  Key? hostKey,
  required List<InstructorAssignmentDraft> assignments,
  required ValueNotifier<List<InstructorAssignmentDraft>> changes,
}) {
  final mediaQuery = MediaQueryData(
    size: surfaceSize ?? const Size(390, 844),
    devicePixelRatio: 1,
  );

  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
    home: MediaQuery(
      data: mediaQuery,
      child: _AssignmentHost(
        key: hostKey,
        initialAssignments: assignments,
        changes: changes,
      ),
    ),
  );
}

@Timeout(Duration(seconds: 30))
void main() {
  testWidgets('shows responsibilities field only for TA rows', (
    WidgetTester tester,
  ) async {
    final changes = ValueNotifier<List<InstructorAssignmentDraft>>(
      const <InstructorAssignmentDraft>[],
    );

    await tester.pumpWidget(
      _buildHost(
        hostKey: const ValueKey<String>('primary-host'),
        assignments: const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(userId: 7, role: 'primary'),
        ],
        changes: changes,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);

    await tester.pumpWidget(
      _buildHost(
        hostKey: const ValueKey<String>('ta-host'),
        assignments: const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(
            userId: 7,
            role: 'ta',
            responsibilities: 'Grading labs',
          ),
        ],
        changes: changes,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('clears responsibilities when changing role away from TA', (
    WidgetTester tester,
  ) async {
    final changes = ValueNotifier<List<InstructorAssignmentDraft>>(
      const <InstructorAssignmentDraft>[],
    );

    await tester.pumpWidget(
      _buildHost(
        assignments: const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(
            userId: 7,
            role: 'ta',
            responsibilities: 'Run office hours',
          ),
        ],
        changes: changes,
      ),
    );
    await tester.pumpAndSettle();

    final roleDropdownFinder = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<String>,
    );
    expect(roleDropdownFinder, findsOneWidget);

    final roleDropdown = tester.widget<DropdownButtonFormField<String>>(
      roleDropdownFinder,
    );
    roleDropdown.onChanged?.call('primary');
    await tester.pumpAndSettle();

    expect(changes.value, isNotEmpty);
    expect(changes.value.first.role, 'primary');
    expect(changes.value.first.responsibilities, isNull);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('does not overflow on narrow width', (WidgetTester tester) async {
    final changes = ValueNotifier<List<InstructorAssignmentDraft>>(
      const <InstructorAssignmentDraft>[],
    );

    await tester.pumpWidget(
      _buildHost(
        hostKey: const ValueKey<String>('narrow-host'),
        surfaceSize: const Size(280, 640),
        assignments: const <InstructorAssignmentDraft>[
          InstructorAssignmentDraft(
            userId: 7,
            role: 'co_instructor',
            responsibilities: 'Very long responsibilities text',
          ),
        ],
        changes: changes,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
