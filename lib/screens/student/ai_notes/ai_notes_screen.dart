import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/ai_notes/ai_notes_cubit.dart';
import '../../../bloc/ai_notes/ai_notes_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/ai_notes/ai_notes_header.dart';
import '../../../widgets/student/ai_notes/ai_notes_search_bar.dart';
import '../../../widgets/student/ai_notes/ai_notes_filter_chips.dart';
import '../../../widgets/student/ai_notes/ai_notes_sort_dropdown.dart';
import '../../../widgets/student/ai_notes/ai_note_card.dart';
import '../../../widgets/student/ai_notes/ai_recommendations_section.dart';
import '../../../widgets/student/ai_notes/ai_notes_quick_stats.dart';
import '../../../widgets/student/ai_notes/ai_note_detail_view.dart';
import '../../../widgets/student/ai_notes/ai_notes_empty_state.dart';

class AiNotesScreen extends StatefulWidget {
  const AiNotesScreen({super.key});

  @override
  State<AiNotesScreen> createState() => _AiNotesScreenState();
}

class _AiNotesScreenState extends State<AiNotesScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    context.read<AINoteCubit>().loadNotes();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimationController.forward();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection.name == 'forward') {
      if (!_showFab) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      }
    } else if (_scrollController.position.userScrollDirection.name == 'reverse') {
      if (_showFab) {
        setState(() => _showFab = false);
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocConsumer<AINoteCubit, AINotesState>(
          listener: (context, state) {
            if (state is AINotesLoaded && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: l10n.dismiss,
                    textColor: Colors.white,
                    onPressed: () => context.read<AINoteCubit>().clearError(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AINotesLoading) {
              return _buildLoadingState(isDark);
            }

            if (state is AINotesError) {
              return _buildErrorState(isDark, l10n, state.message);
            }

            if (state is AINotesLoaded) {
              if (state.selectedNote != null) {
                return AiNoteDetailView(
                  note: state.selectedNote!,
                  onBack: () => context.read<AINoteCubit>().clearSelectedNote(),
                );
              }
              return _buildContent(context, isDark, l10n, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<AINoteCubit, AINotesState>(
        builder: (context, state) {
          if (state is AINotesLoaded && state.selectedNote == null) {
            return ScaleTransition(
              scale: _fabAnimationController,
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateNoteDialog(context, isDark, l10n),
                backgroundColor: const Color(0xFF8B5CF6),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  l10n.generateNotes,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your AI notes...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingNotes,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<AINoteCubit>().loadNotes(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, AppLocalizations l10n, AINotesLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<AINoteCubit>().loadNotes(),
      color: const Color(0xFF8B5CF6),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AiNotesHeader(
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AiNotesSearchBar(
                    onSearch: (query) => context.read<AINoteCubit>().searchNotes(query),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: AiNotesFilterChips(
                          currentFilter: state.currentFilter,
                          categories: state.categories,
                          selectedCategoryId: state.selectedCategoryId,
                          onFilterSelected: (filter, categoryId) =>
                              context.read<AINoteCubit>().applyFilter(filter, categoryId: categoryId),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AiNotesSortDropdown(
                        currentSort: state.currentSort,
                        onSortSelected: (sort) => context.read<AINoteCubit>().applySort(sort),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Quick Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AiNotesQuickStats(stats: state.stats),
                ),
                const SizedBox(height: 20),
                // AI Recommendations
                if (state.recommendations.isNotEmpty) ...[
                  AiRecommendationsSection(
                    recommendations: state.recommendations,
                    onRecommendationTap: (rec) {
                      if (rec.noteId != null) {
                        final note = state.notes.firstWhere(
                          (n) => n.id == rec.noteId,
                          orElse: () => state.notes.first,
                        );
                        context.read<AINoteCubit>().selectNote(note);
                      }
                    },
                    onGenerateFlashcards: () {
                      if (state.notes.isNotEmpty) {
                        context.read<AINoteCubit>().generateFlashcards(state.notes.first.id);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.yourNotes,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${state.filteredNotes.length} ${l10n.notes}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Notes list or empty state
          if (state.filteredNotes.isEmpty)
            SliverToBoxAdapter(
              child: AiNotesEmptyState(
                hasSearchQuery: state.searchQuery.isNotEmpty,
                filter: state.currentFilter,
                onClearFilters: () {
                  context.read<AINoteCubit>().searchNotes('');
                  context.read<AINoteCubit>().applyFilter(state.currentFilter);
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = state.filteredNotes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AiNoteCard(
                        note: note,
                        onTap: () => context.read<AINoteCubit>().selectNote(note),
                        onFavoriteToggle: () => context.read<AINoteCubit>().toggleFavorite(note.id),
                        onExpandToggle: () => context.read<AINoteCubit>().toggleNoteExpanded(note.id),
                        onDelete: () => context.read<AINoteCubit>().deleteNote(note.id),
                      ),
                    );
                  },
                  childCount: state.filteredNotes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context, bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateNoteBottomSheet(isDark: isDark),
    );
  }
}

class _CreateNoteBottomSheet extends StatelessWidget {
  final bool isDark;

  const _CreateNoteBottomSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.generateNewNotes,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.generateNotesDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildOption(
              context,
              icon: Icons.upload_file_rounded,
              title: l10n.uploadDocument,
              subtitle: l10n.uploadDocumentDescription,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.video_library_rounded,
              title: l10n.fromVideo,
              subtitle: l10n.fromVideoDescription,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.link_rounded,
              title: l10n.fromUrl,
              subtitle: l10n.fromUrlDescription,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.mic_rounded,
              title: l10n.fromAudio,
              subtitle: l10n.fromAudioDescription,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF2A2A2B) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title - Coming soon!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF8B5CF6),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

