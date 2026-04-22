import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class FilterChipsBar extends StatelessWidget {
  final bool isDark;

  const FilterChipsBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filters = [
      _FilterItem(FileFilterOption.all, l10n.all, Icons.folder_rounded),
      _FilterItem(
        FileFilterOption.recent,
        l10n.recent,
        Icons.access_time_rounded,
      ),
      _FilterItem(
        FileFilterOption.favorites,
        l10n.favorites,
        Icons.star_rounded,
      ),
      _FilterItem(FileFilterOption.pdf, 'PDF', Icons.picture_as_pdf_rounded),
      _FilterItem(
        FileFilterOption.documents,
        l10n.documents,
        Icons.description_rounded,
      ),
      _FilterItem(FileFilterOption.images, l10n.images, Icons.image_rounded),
      _FilterItem(
        FileFilterOption.videos,
        l10n.videos,
        Icons.video_library_rounded,
      ),
      _FilterItem(FileFilterOption.audio, l10n.audio, Icons.audiotrack_rounded),
    ];

    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (p, c) => p.filterOption != c.filterOption,
      builder: (context, state) {
        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = state.filterOption == filter.option;

              return GestureDetector(
                onTap: () {
                  context.read<MyFilesCubit>().setFilter(filter.option);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FilterItem {
  final FileFilterOption option;
  final String label;
  final IconData icon;

  const _FilterItem(this.option, this.label, this.icon);
}
