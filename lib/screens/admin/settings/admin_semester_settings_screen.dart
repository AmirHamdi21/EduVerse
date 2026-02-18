import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminSemesterSettingsScreen extends StatefulWidget {
  const AdminSemesterSettingsScreen({super.key});

  @override
  State<AdminSemesterSettingsScreen> createState() =>
      _AdminSemesterSettingsScreenState();
}

class _AdminSemesterSettingsScreenState
    extends State<AdminSemesterSettingsScreen> {
  final List<_Semester> _semesters = [
    _Semester(
      id: '1',
      name: 'Fall 2025',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2025, 12, 20),
      isActive: true,
      enrollmentOpen: true,
    ),
    _Semester(
      id: '2',
      name: 'Spring 2026',
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 5, 15),
      isActive: false,
      enrollmentOpen: false,
    ),
    _Semester(
      id: '3',
      name: 'Summer 2026',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 8, 15),
      isActive: false,
      enrollmentOpen: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSemesterDialog(context, l10n, isDark),
            backgroundColor: AdminColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.addSemester,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCurrentSemesterCard(isDark, l10n, responsive),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.allSemesters, isDark),
                  SizedBox(height: responsive.p12),
                  ..._semesters
                      .map((s) => _buildSemesterCard(s, isDark, l10n, responsive)),
                  SizedBox(height: responsive.p80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.semesterSettings,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentSemesterCard(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    final activeSemester = _semesters.firstWhere((s) => s.isActive);
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentSemester,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeSemester.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.active,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.play_arrow_rounded,
                  '${l10n.starts}: ${_formatDate(activeSemester.startDate)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  Icons.stop_rounded,
                  '${l10n.ends}: ${_formatDate(activeSemester.endDate)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoChip(
            activeSemester.enrollmentOpen
                ? Icons.lock_open_rounded
                : Icons.lock_rounded,
            activeSemester.enrollmentOpen
                ? l10n.enrollmentOpen
                : l10n.enrollmentClosed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildSemesterCard(
      _Semester semester, bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: semester.isActive
              ? AdminColors.primary.withValues(alpha: 0.3)
              : AdminColors.getCardBorderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(semester.startDate)} - ${_formatDate(semester.endDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (semester.isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.active,
                    style: TextStyle(
                      color: AdminColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                color: AdminColors.getCardColor(isDark),
                onSelected: (value) => _handleMenuAction(value, semester, l10n),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            size: 20, color: AdminColors.primary),
                        const SizedBox(width: 12),
                        Text(l10n.edit,
                            style: TextStyle(
                                color: AdminColors.getTextColor(isDark))),
                      ],
                    ),
                  ),
                  if (!semester.isActive)
                    PopupMenuItem(
                      value: 'activate',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 20, color: AdminColors.success),
                          const SizedBox(width: 12),
                          Text(l10n.setAsActive,
                              style: TextStyle(
                                  color: AdminColors.getTextColor(isDark))),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 20, color: AdminColors.error),
                        const SizedBox(width: 12),
                        Text(l10n.delete,
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusBadge(
                semester.enrollmentOpen ? l10n.enrollmentOpen : l10n.enrollmentClosed,
                semester.enrollmentOpen ? AdminColors.success : AdminColors.warning,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(
                '${_calculateDaysRemaining(semester.endDate)} ${l10n.daysRemaining}',
                AdminColors.primary,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, _Semester semester, AppLocalizations l10n) {
    switch (action) {
      case 'edit':
        _showEditSemesterDialog(context, l10n, semester);
        break;
      case 'activate':
        setState(() {
          for (var s in _semesters) {
            s.isActive = s.id == semester.id;
          }
        });
        _showSnackBar(l10n.semesterActivated);
        break;
      case 'delete':
        _showDeleteConfirmDialog(context, l10n, semester);
        break;
    }
  }

  void _showAddSemesterDialog(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AdminColors.getCardColor(isDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.addSemester,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: nameController,
                  label: l10n.semesterName,
                  hint: 'e.g., Fall 2026',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: l10n.startDate,
                  date: startDate,
                  isDark: isDark,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: l10n.endDate,
                  date: endDate,
                  isDark: isDark,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  setState(() {
                    _semesters.add(_Semester(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      startDate: startDate!,
                      endDate: endDate!,
                      isActive: false,
                      enrollmentOpen: false,
                    ));
                  });
                  Navigator.pop(context);
                  _showSnackBar(l10n.semesterAdded);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSemesterDialog(
      BuildContext context, AppLocalizations l10n, _Semester semester) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final nameController = TextEditingController(text: semester.name);
    DateTime startDate = semester.startDate;
    DateTime endDate = semester.endDate;
    bool enrollmentOpen = semester.enrollmentOpen;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AdminColors.getCardColor(isDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.editSemester,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: nameController,
                  label: l10n.semesterName,
                  hint: 'e.g., Fall 2026',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: l10n.startDate,
                  date: startDate,
                  isDark: isDark,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: l10n.endDate,
                  date: endDate,
                  isDark: isDark,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: enrollmentOpen,
                  onChanged: (v) => setDialogState(() => enrollmentOpen = v),
                  title: Text(
                    l10n.enrollmentStatus,
                    style: TextStyle(color: AdminColors.getTextColor(isDark)),
                  ),
                  subtitle: Text(
                    enrollmentOpen ? l10n.enrollmentOpen : l10n.enrollmentClosed,
                    style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark)),
                  ),
                  activeColor: AdminColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  semester.name = nameController.text;
                  semester.startDate = startDate;
                  semester.endDate = endDate;
                  semester.enrollmentOpen = enrollmentOpen;
                });
                Navigator.pop(context);
                _showSnackBar(l10n.semesterUpdated);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, AppLocalizations l10n, _Semester semester) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AdminColors.error),
            const SizedBox(width: 12),
            Text(
              l10n.deleteSemester,
              style: TextStyle(
                color: AdminColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteSemesterConfirm,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _semesters.removeWhere((s) => s.id == semester.id);
              });
              Navigator.pop(context);
              _showSnackBar(l10n.semesterDeleted);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AdminColors.getTextColor(isDark)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        hintStyle: TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
        filled: true,
        fillColor: AdminColors.getBackgroundColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AdminColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AdminColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? _formatDate(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDaysRemaining(DateTime endDate) {
    return endDate.difference(DateTime.now()).inDays;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Semester {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  bool isActive;
  bool enrollmentOpen;

  _Semester({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.enrollmentOpen,
  });
}
