import 'package:edu_verse/widgets/instructor/question_bank/question_text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders repaired pasted LaTeX without throwing', (tester) async {
    const pastedQuestion =
        r'Consider the system \beginmatrix \dotx_1 \\ \dotx_2 \endbmatrix = '
        r'\beginbmatrix 0 & 1 \\ 0 & 0 \endbmatrix '
        r'\beginbmatrix x_1 \\ x_2 \endbmatrix + '
        r'\beginbmatrix 0 \\ 1 \endbmatrix u such that '
        r'$J = \int_0^\infty (x^T Q x + u^2) dt$ is minimized.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuestionFormattedText(
            text: pastedQuestion,
            fallback: 'Question',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsWidgets);
  });

  testWidgets('lets multi-line math choose its real height', (tester) async {
    const matrixQuestion =
        r'Consider the system $$\begin{bmatrix}\dot{x}_1 \\ \dot{x}_2\end{bmatrix}'
        r'=\begin{bmatrix}0 & 1 \\ 0 & 0\end{bmatrix}'
        r'\begin{bmatrix}x_1 \\ x_2\end{bmatrix}$$';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            child: QuestionFormattedText(
              text: matrixQuestion,
              fallback: 'Question',
              maxLines: 2,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsWidgets);
    expect(
      tester.getSize(find.byType(QuestionFormattedText)).height,
      greaterThan(70),
    );
  });

  testWidgets('uses safe plain preview when math text is max-lined', (
    tester,
  ) async {
    const matrixQuestion =
        r'Consider the system $$\begin{bmatrix}\dot{x}_1 \\ \dot{x}_2\end{bmatrix}'
        r'=\begin{bmatrix}0 & 1 \\ 0 & 0\end{bmatrix}$$ '
        r'and determine the optimal signal with a very long explanation.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: QuestionFormattedText(
              text: matrixQuestion,
              fallback: 'Question',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              clipMathToMaxLines: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsNothing);
    expect(find.textContaining('Consider the system'), findsOneWidget);
  });
}
