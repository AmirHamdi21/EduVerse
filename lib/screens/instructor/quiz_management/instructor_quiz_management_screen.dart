import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';

class InstructorQuizManagementScreen extends StatefulWidget {
  const InstructorQuizManagementScreen({super.key});
  @override
  State<InstructorQuizManagementScreen> createState() => _State();
}

class _State extends State<InstructorQuizManagementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fade;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();
    context.read<QuizManagementCubit>().loadQuizzes();
  }

  @override
  void dispose() { _ac.dispose(); _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (_, ts) {
      final dk = ts.isDark;
      final bg = InstructorColors.background(dk);
      return Scaffold(
        backgroundColor: bg,
        body: Stack(children: [
          Container(height: 280, decoration: BoxDecoration(
            gradient: dk ? InstructorColors.darkHeaderGradient : InstructorColors.headerGradient)),
          SafeArea(child: Column(children: [
            FadeTransition(opacity: _fade, child: Padding(
              padding: EdgeInsets.fromLTRB(r.p20, r.p16, r.p20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _backBtn(), const Spacer(), _createBtn(),
                ]),
                SizedBox(height: r.p16),
                const Text('Quiz Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Create, manage, and grade quizzes', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                SizedBox(height: r.p16),
                _searchBar(),
              ]),
            )),
            SizedBox(height: r.p12),
            _filters(dk),
            SizedBox(height: r.p8),
            Expanded(child: Container(
              decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
              child: BlocBuilder<QuizManagementCubit, QuizManagementState>(builder: (_, s) {
                if (s is QuizMgmtLoading || s is QuizMgmtOperating) return const Center(child: CircularProgressIndicator(color: InstructorColors.primary));
                if (s is QuizMgmtError) return _errView(dk, s.message);
                if (s is QuizMgmtLoaded) return _listView(dk, s, r);
                return const SizedBox.shrink();
              }),
            )),
          ])),
        ]),
      );
    });
  }

  Widget _backBtn() => Container(
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
    child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18)),
  );

  Widget _createBtn() => GestureDetector(
    onTap: () { HapticFeedback.mediumImpact(); context.push('/instructor/quiz-create'); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add_rounded, color: Colors.white, size: 18), SizedBox(width: 6),
        Text('Create Quiz', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ),
  );

  Widget _searchBar() => Container(
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
    child: TextField(
      controller: _search,
      onChanged: (v) => context.read<QuizManagementCubit>().setSearchQuery(v),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search quizzes...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
    ),
  );

  Widget _filters(bool dk) => BlocBuilder<QuizManagementCubit, QuizManagementState>(builder: (_, s) {
    final cur = s is QuizMgmtLoaded ? s.statusFilter : 'all';
    return SizedBox(height: 38, child: ListView.separated(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4, separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final f = ['all','draft','published','closed'][i];
        final sel = cur == f;
        return GestureDetector(
          onTap: () => context.read<QuizManagementCubit>().setStatusFilter(f),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? InstructorColors.primary : Colors.white.withValues(alpha: 0.85))),
          ),
        );
      },
    ));
  });

  Widget _errView(bool dk, String msg) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline_rounded, size: 56, color: InstructorColors.error),
    const SizedBox(height: 16),
    Text(msg, textAlign: TextAlign.center, style: TextStyle(color: InstructorColors.textSecondaryColor(dk), fontSize: 14)),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: () => context.read<QuizManagementCubit>().loadQuizzes(),
      icon: const Icon(Icons.refresh_rounded, size: 18), label: const Text('Retry'),
      style: ElevatedButton.styleFrom(backgroundColor: InstructorColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ])));

  Widget _listView(bool dk, QuizMgmtLoaded st, ResponsiveUtil r) {
    final q = st.filteredQuizzes;
    if (q.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.quiz_outlined, size: 56, color: InstructorColors.textTertiaryColor(dk)),
      const SizedBox(height: 16),
      Text('No quizzes yet', style: TextStyle(color: InstructorColors.textSecondaryColor(dk), fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Tap "Create Quiz" to get started', style: TextStyle(color: InstructorColors.textTertiaryColor(dk), fontSize: 13)),
    ]));
    return RefreshIndicator(
      onRefresh: () => context.read<QuizManagementCubit>().loadQuizzes(), color: InstructorColors.primary,
      child: ListView.builder(padding: EdgeInsets.all(r.p16), physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: q.length, itemBuilder: (_, i) => _QuizCard(quiz: q[i], isDark: dk)),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final bool isDark;
  const _QuizCard({required this.quiz, required this.isDark});

  Color _sColor() { switch(quiz.status) { case QuizStatusEnum.draft: return InstructorColors.warning; case QuizStatusEnum.published: return InstructorColors.success; case QuizStatusEnum.closed: return InstructorColors.error; } }
  String _sLabel() { switch(quiz.status) { case QuizStatusEnum.draft: return 'Draft'; case QuizStatusEnum.published: return 'Published'; case QuizStatusEnum.closed: return 'Closed'; } }

  @override
  Widget build(BuildContext context) {
    final sc = _sColor();
    return Container(margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(
      color: InstructorColors.cardColor(isDark), borderRadius: BorderRadius.circular(18),
      border: Border.all(color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(_sLabel(), style: TextStyle(color: sc, fontSize: 11, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: InstructorColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: Text(quiz.quizType.name.toUpperCase(), style: const TextStyle(color: InstructorColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
            const Spacer(),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: InstructorColors.textTertiaryColor(isDark), size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: InstructorColors.cardColor(isDark),
              onSelected: (v) => _onMenu(context, v),
              itemBuilder: (_) => [
                _mi('edit', Icons.edit_outlined, 'Edit Quiz'),
                _mi('attempts', Icons.people_outline_rounded, 'View Attempts'),
                _mi('statistics', Icons.bar_chart_rounded, 'Statistics'),
                const PopupMenuDivider(),
                _mi('delete', Icons.delete_outline_rounded, 'Delete', c: InstructorColors.error),
              ]),
          ]),
          const SizedBox(height: 12),
          Text(quiz.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: InstructorColors.textPrimaryColor(isDark))),
          if (quiz.description?.isNotEmpty == true) ...[const SizedBox(height: 6), Text(quiz.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: InstructorColors.textSecondaryColor(isDark)))],
          const SizedBox(height: 14),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _meta(Icons.school_outlined, quiz.courseName),
            _meta(Icons.help_outline_rounded, '${quiz.questionCount} Q'),
            if (quiz.timeLimitMinutes != null) _meta(Icons.timer_outlined, '${quiz.timeLimitMinutes} min'),
            _meta(Icons.repeat_rounded, '${quiz.maxAttempts} attempts'),
          ]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18))),
          child: Row(children: [
            _actBtn(context, Icons.people_outline_rounded, 'Attempts', () => context.push('/instructor/quiz-attempts', extra: quiz)),
            const SizedBox(width: 8),
            _actBtn(context, Icons.bar_chart_rounded, 'Stats', () => context.push('/instructor/quiz-statistics', extra: quiz)),
            const Spacer(),
            if (quiz.status == QuizStatusEnum.draft) _pubBtn(context) else if (quiz.status == QuizStatusEnum.published) _clsBtn(context),
          ])),
      ]),
    );
  }

  Widget _meta(IconData ic, String l) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(ic, size: 14, color: InstructorColors.textTertiaryColor(isDark)), const SizedBox(width: 4),
    Text(l, style: TextStyle(fontSize: 12, color: InstructorColors.textTertiaryColor(isDark), fontWeight: FontWeight.w500)),
  ]);

  Widget _actBtn(BuildContext ctx, IconData ic, String l, VoidCallback tap) => GestureDetector(onTap: tap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: InstructorColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(ic, size: 15, color: InstructorColors.primary), const SizedBox(width: 5),
      Text(l, style: const TextStyle(color: InstructorColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  ));

  Widget _pubBtn(BuildContext ctx) => GestureDetector(
    onTap: () { HapticFeedback.mediumImpact(); ctx.read<QuizManagementCubit>().publishQuiz(quiz.id); },
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [InstructorColors.success, Color(0xFF059669)]), borderRadius: BorderRadius.circular(10)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.publish_rounded, size: 15, color: Colors.white), SizedBox(width: 5), Text('Publish', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])),
  );

  Widget _clsBtn(BuildContext ctx) => GestureDetector(
    onTap: () { HapticFeedback.mediumImpact(); ctx.read<QuizManagementCubit>().closeQuiz(quiz.id); },
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: InstructorColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: InstructorColors.error.withValues(alpha: 0.3))),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock_outline_rounded, size: 15, color: InstructorColors.error), SizedBox(width: 5), Text('Close', style: TextStyle(color: InstructorColors.error, fontSize: 12, fontWeight: FontWeight.w700))])),
  );

  PopupMenuItem<String> _mi(String v, IconData ic, String l, {Color? c}) => PopupMenuItem(value: v, child: Row(children: [
    Icon(ic, size: 18, color: c ?? InstructorColors.textSecondaryColor(isDark)), const SizedBox(width: 10),
    Text(l, style: TextStyle(fontSize: 13, color: c ?? InstructorColors.textPrimaryColor(isDark), fontWeight: FontWeight.w500)),
  ]));

  void _onMenu(BuildContext ctx, String a) {
    switch(a) {
      case 'edit': ctx.push('/instructor/quiz-edit', extra: quiz);
      case 'attempts': ctx.push('/instructor/quiz-attempts', extra: quiz);
      case 'statistics': ctx.push('/instructor/quiz-statistics', extra: quiz);
      case 'delete': _confirmDel(ctx);
    }
  }

  void _confirmDel(BuildContext ctx) {
    showDialog(context: ctx, builder: (d) => AlertDialog(
      backgroundColor: InstructorColors.cardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Quiz', style: TextStyle(color: InstructorColors.textPrimaryColor(isDark), fontWeight: FontWeight.w700)),
      content: Text('Are you sure you want to delete "${quiz.title}"? This cannot be undone.', style: TextStyle(color: InstructorColors.textSecondaryColor(isDark), fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: Text('Cancel', style: TextStyle(color: InstructorColors.textSecondaryColor(isDark)))),
        ElevatedButton(onPressed: () { Navigator.pop(d); ctx.read<QuizManagementCubit>().deleteQuiz(quiz.id); },
          style: ElevatedButton.styleFrom(backgroundColor: InstructorColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Delete')),
      ],
    ));
  }
}
