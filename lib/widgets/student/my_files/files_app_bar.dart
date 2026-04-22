import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class FilesAppBar extends StatefulWidget {
  final bool isDark;

  const FilesAppBar({super.key, required this.isDark});

  @override
  State<FilesAppBar> createState() => _FilesAppBarState();
}

class _FilesAppBarState extends State<FilesAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverAppBar(
      expandedHeight: 130,
      floating: true,
      pinned: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: widget.isDark ? Colors.white : const Color(0xFF3B82F6),
            size: 18,
          ),
        ),
      ),
      actions: [
        _buildViewToggle(),
        const SizedBox(width: 4),
        _buildSearchButton(l10n),
        const SizedBox(width: 4),
        _buildMoreButton(context, l10n),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: _isSearching ? _buildSearchField(l10n) : _buildTitle(l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.folder_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myFiles,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  BlocBuilder<MyFilesCubit, MyFilesState>(
                    buildWhen: (p, c) => p.files.length != c.files.length,
                    builder: (context, state) {
                      return Text(
                        '${state.files.length} ${l10n.files}',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              context.read<MyFilesCubit>().setSearchQuery(value);
            },
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: l10n.searchFiles,
              hintStyle: TextStyle(
                color: widget.isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: widget.isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  context.read<MyFilesCubit>().setSearchQuery('');
                  setState(() => _isSearching = false);
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: widget.isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (p, c) => p.viewMode != c.viewMode,
      builder: (context, state) {
        final isGrid = state.viewMode == ViewMode.grid;
        return IconButton(
          onPressed: () {
            context.read<MyFilesCubit>().setViewMode(
              isGrid ? ViewMode.list : ViewMode.grid,
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: widget.isDark ? Colors.white : const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(AppLocalizations l10n) {
    return IconButton(
      onPressed: () => setState(() => _isSearching = true),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.search_rounded,
          color: widget.isDark ? Colors.white : const Color(0xFF3B82F6),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: widget.isDark ? Colors.white : const Color(0xFF3B82F6),
          size: 20,
        ),
      ),
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'select':
            context.read<MyFilesCubit>().toggleMultiSelectMode();
            break;
          case 'refresh':
            context.read<MyFilesCubit>().refresh();
            break;
          case 'sort':
            _showSortDialog(context, l10n);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'select',
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.selectFiles,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.sortBy,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.refresh,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context, AppLocalizations l10n) {
    final cubit = context.read<MyFilesCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.sortBy,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(cubit, l10n.nameAZ, FileSortOption.nameAsc),
            _buildSortOption(cubit, l10n.nameZA, FileSortOption.nameDesc),
            _buildSortOption(cubit, l10n.dateNewest, FileSortOption.dateNewest),
            _buildSortOption(cubit, l10n.dateOldest, FileSortOption.dateOldest),
            _buildSortOption(
              cubit,
              l10n.sizeSmallest,
              FileSortOption.sizeSmallest,
            ),
            _buildSortOption(
              cubit,
              l10n.sizeLargest,
              FileSortOption.sizeLargest,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    MyFilesCubit cubit,
    String label,
    FileSortOption option,
  ) {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      bloc: cubit,
      buildWhen: (p, c) => p.sortOption != c.sortOption,
      builder: (context, state) {
        final isSelected = state.sortOption == option;
        return ListTile(
          onTap: () {
            cubit.setSort(option);
            Navigator.pop(context);
          },
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: isSelected
                ? const Color(0xFF3B82F6)
                : widget.isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}
