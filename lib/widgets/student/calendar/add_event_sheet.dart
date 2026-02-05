import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AddEventSheet extends StatefulWidget {
  final bool isDark;

  const AddEventSheet({super.key, required this.isDark});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  EventType _selectedType = EventType.lecture;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2B7FFF,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Color(0xFF2B7FFF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        l10n.addNewEvent,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AI Suggested Time Slot
                  _buildAiSuggestionButton(l10n, isDark),
                  const SizedBox(height: 20),

                  // Event Title
                  _buildLabel(l10n.eventTitle, isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _titleController,
                    l10n.eventTitleHint,
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Event Type
                  _buildLabel(l10n.eventType, isDark),
                  const SizedBox(height: 8),
                  _buildEventTypeSelector(l10n, isDark),
                  const SizedBox(height: 16),

                  // Course (Optional)
                  _buildLabel('${l10n.course} (${l10n.optional})', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _courseController,
                    l10n.courseHint,
                    isDark,
                    prefixIcon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(l10n.date, isDark),
                            const SizedBox(height: 8),
                            _buildDatePicker(l10n, isDark),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(l10n.time, isDark),
                            const SizedBox(height: 8),
                            _buildTimePicker(l10n, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location (Optional)
                  _buildLabel('${l10n.location} (${l10n.optional})', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _locationController,
                    l10n.locationHint,
                    isDark,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Description (Optional)
                  _buildLabel('${l10n.description} (${l10n.optional})', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _descriptionController,
                    l10n.descriptionHint,
                    isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2939)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFD1D5DC)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: BlocBuilder<CalendarCubit, CalendarState>(
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: state.isLoading ? null : _handleAddEvent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2B7FFF),
                                      Color(0xFF155DFC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2B7FFF,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          l10n.addEvent,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAiSuggestionButton(AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () {
        final suggestion = context
            .read<CalendarCubit>()
            .getAiSuggestedTimeSlot();
        if (suggestion != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.aiSuggestedTime}: $suggestion'),
              backgroundColor: const Color(0xFF2B7FFF),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2B7FFF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Color(0xFF2B7FFF),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.getAiSuggestedTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B7FFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeSelector(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EventType>(
          value: _selectedType,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E2939) : Colors.white,
          icon: Icon(
            Icons.expand_more_rounded,
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          ),
          items: EventType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Text(
                    _getEventTypeEmoji(type),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getEventTypeName(type, l10n),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF2B7FFF),
                  onPrimary: Colors.white,
                  surface: isDark ? const Color(0xFF101828) : Colors.white,
                  onSurface: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMM d, yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          initialEntryMode: TimePickerEntryMode.dial,
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? ColorScheme.dark(
                        primary: const Color(0xFF2B7FFF),
                        onPrimary: Colors.white,
                        surface: const Color(0xFF101828),
                        onSurface: Colors.white,
                      )
                    : ColorScheme.light(
                        primary: const Color(0xFF2B7FFF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: const Color(0xFF1F2937),
                      ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: isDark ? const Color(0xFF101828) : Colors.white,
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: false,
                ),
                child: child!,
              ),
            );
          },
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 18,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Text(
              _selectedTime != null ? _selectedTime!.format(context) : '--:--',
              style: TextStyle(
                fontSize: 14,
                color: _selectedTime != null
                    ? (isDark ? Colors.white : const Color(0xFF1F2937))
                    : (isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddEvent() {
    final cubit = context.read<CalendarCubit>();

    cubit
        .addEvent(
          title: _titleController.text,
          type: _selectedType,
          date: _selectedDate,
          time: _selectedTime?.format(context),
          course: _courseController.text.isNotEmpty
              ? _courseController.text
              : null,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        )
        .then((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
  }

  String _getEventTypeEmoji(EventType type) {
    switch (type) {
      case EventType.lecture:
        return '📚';
      case EventType.lab:
        return '🔬';
      case EventType.assignment:
        return '📝';
      case EventType.exam:
        return '📋';
      case EventType.quiz:
        return '❓';
      case EventType.personalTask:
        return '⭐';
    }
  }

  String _getEventTypeName(EventType type, AppLocalizations l10n) {
    switch (type) {
      case EventType.lecture:
        return l10n.lectureType;
      case EventType.lab:
        return l10n.labType;
      case EventType.assignment:
        return l10n.assignmentType;
      case EventType.exam:
        return l10n.examType;
      case EventType.quiz:
        return l10n.quizType;
      case EventType.personalTask:
        return l10n.personalTaskType;
    }
  }
}
