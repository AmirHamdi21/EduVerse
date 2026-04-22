import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_periods_models.dart';
import '../../../services/api/admin_periods_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

class AdminOfficeHoursScreen extends StatefulWidget {
  final AdminPeriodsService? periodsService;

  const AdminOfficeHoursScreen({super.key, this.periodsService});

  @override
  State<AdminOfficeHoursScreen> createState() => _AdminOfficeHoursScreenState();
}

class _AdminOfficeHoursScreenState extends State<AdminOfficeHoursScreen> {
  CoreApiClient? _coreApiClient;
  late final AdminPeriodsService _periodsService;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  int _page = 1;
  int _totalPages = 1;

  int? _selectedInstructorId;
  String _selectedDay = 'all';
  String _selectedMode = 'all';
  String _selectedRole = 'all';

  List<AdminStaffSummaryModel> _staff = const <AdminStaffSummaryModel>[];
  List<OfficeHourSlotModel> _slots = const <OfficeHourSlotModel>[];

  int? _expandedSlotId;
  final Map<int, List<OfficeHourAppointmentModel>> _appointmentsBySlot =
      <int, List<OfficeHourAppointmentModel>>{};
  final Set<int> _appointmentsLoading = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.periodsService != null) {
      _periodsService = widget.periodsService!;
    } else {
      _coreApiClient = CoreApiClient();
      _periodsService = AdminPeriodsService(coreApiClient: _coreApiClient!);
    }
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _coreApiClient?.dio.close(force: true);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger local filtering only.
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait<void>(<Future<void>>[_loadStaff(), _loadSlots()]);
  }

  Future<void> _loadStaff() async {
    final result = await _periodsService.getStaffMembers();

    if (!mounted || result.isFailure || result.data == null) {
      return;
    }

    setState(() {
      _staff = result.data!;
    });
  }

  Future<void> _loadSlots() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _periodsService.getOfficeHours(
      page: _page,
      limit: 10,
      instructorId: _selectedInstructorId,
      dayOfWeek: _selectedDay == 'all' ? null : _selectedDay,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure || result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.error?.message ?? l10n.adminOfficeHoursLoadFailed;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _slots = result.data!.items;
      _totalPages = result.data!.meta.totalPages <= 0
          ? 1
          : result.data!.meta.totalPages;
    });
  }

  Future<void> _openSlotForm({OfficeHourSlotModel? slot}) async {
    final l10n = AppLocalizations.of(context);

    int? selectedInstructorId = slot?.instructorId ?? _selectedInstructorId;
    String selectedDay = (slot?.dayOfWeek ?? 'MONDAY').toUpperCase();
    String selectedMode = (slot?.mode ?? 'in_person').toLowerCase();
    bool isActive = slot?.isActive ?? true;

    final startTimeController = TextEditingController(
      text: slot?.startTime ?? '09:00',
    );
    final endTimeController = TextEditingController(
      text: slot?.endTime ?? '10:00',
    );
    final locationController = TextEditingController(
      text: slot?.location ?? '',
    );
    final maxAppointmentsController = TextEditingController(
      text: slot?.maxAppointments.toString() ?? '',
    );
    final notesController = TextEditingController(text: slot?.notes ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot == null
                            ? l10n.adminAddOfficeHourSlot
                            : l10n.adminEditOfficeHourSlot,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: selectedInstructorId,
                        decoration: InputDecoration(
                          labelText: l10n.adminInstructorOrTa,
                          border: const OutlineInputBorder(),
                        ),
                        items: _staff
                            .map(
                              (person) => DropdownMenuItem<int>(
                                value: person.userId,
                                child: Text(person.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setModalState(() => selectedInstructorId = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDay,
                        decoration: InputDecoration(
                          labelText: l10n.adminDayOfWeek,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'MONDAY',
                            child: Text(l10n.adminDayMonday),
                          ),
                          DropdownMenuItem(
                            value: 'TUESDAY',
                            child: Text(l10n.adminDayTuesday),
                          ),
                          DropdownMenuItem(
                            value: 'WEDNESDAY',
                            child: Text(l10n.adminDayWednesday),
                          ),
                          DropdownMenuItem(
                            value: 'THURSDAY',
                            child: Text(l10n.adminDayThursday),
                          ),
                          DropdownMenuItem(
                            value: 'FRIDAY',
                            child: Text(l10n.adminDayFriday),
                          ),
                          DropdownMenuItem(
                            value: 'SATURDAY',
                            child: Text(l10n.adminDaySaturday),
                          ),
                          DropdownMenuItem(
                            value: 'SUNDAY',
                            child: Text(l10n.adminDaySunday),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => selectedDay = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              decoration: InputDecoration(
                                labelText: l10n.adminStartTimeHint,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              decoration: InputDecoration(
                                labelText: l10n.adminEndTimeHint,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: l10n.location,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMode,
                        decoration: InputDecoration(
                          labelText: l10n.adminMode,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'in_person',
                            child: Text(l10n.adminModeInPerson),
                          ),
                          DropdownMenuItem(
                            value: 'online',
                            child: Text(l10n.online),
                          ),
                          DropdownMenuItem(
                            value: 'hybrid',
                            child: Text(l10n.hybrid),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => selectedMode = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: maxAppointmentsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.adminMaxAppointments,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.adminNotesOptional,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.adminSlotIsActive),
                        value: isActive,
                        onChanged: (value) =>
                            setModalState(() => isActive = value),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                      final location = locationController.text
                                          .trim();
                                      final startTime = startTimeController.text
                                          .trim();
                                      final endTime = endTimeController.text
                                          .trim();

                                      if (selectedInstructorId == null) {
                                        _showSnackBar(
                                          l10n.adminSelectInstructorFirst,
                                        );
                                        return;
                                      }
                                      if (location.isEmpty) {
                                        _showSnackBar(
                                          l10n.adminLocationRequired,
                                        );
                                        return;
                                      }
                                      if (!_isValidTime(startTime) ||
                                          !_isValidTime(endTime)) {
                                        _showSnackBar(l10n.adminUseTimeFormat);
                                        return;
                                      }

                                      final payload = <String, dynamic>{
                                        'instructorId': selectedInstructorId,
                                        'dayOfWeek': selectedDay,
                                        'startTime': startTime,
                                        'endTime': endTime,
                                        'location': location,
                                        'mode': selectedMode,
                                        'isActive': isActive,
                                      };

                                      final maxAppointments = int.tryParse(
                                        maxAppointmentsController.text.trim(),
                                      );
                                      if (maxAppointments != null) {
                                        payload['maxAppointments'] =
                                            maxAppointments;
                                      }

                                      final notes = notesController.text.trim();
                                      if (notes.isNotEmpty) {
                                        payload['notes'] = notes;
                                      }

                                      setState(() => _isSaving = true);

                                      final result = slot == null
                                          ? await _periodsService
                                                .createOfficeHour(payload)
                                          : await _periodsService
                                                .updateOfficeHour(
                                                  slot.slotId,
                                                  payload,
                                                );

                                      if (!mounted) {
                                        return;
                                      }

                                      setState(() => _isSaving = false);

                                      if (result.isFailure) {
                                        _showSnackBar(
                                          result.error?.message ??
                                              l10n.adminOfficeHourSaveFailed,
                                        );
                                        return;
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.pop(context);
                                      _showSnackBar(
                                        slot == null
                                            ? l10n.adminOfficeHourSlotCreated
                                            : l10n.adminOfficeHourSlotUpdated,
                                      );
                                      _loadSlots();
                                    },
                              child: Text(
                                slot == null ? l10n.create : l10n.save,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    startTimeController.dispose();
    endTimeController.dispose();
    locationController.dispose();
    maxAppointmentsController.dispose();
    notesController.dispose();
  }

  Future<void> _confirmDelete(OfficeHourSlotModel slot) async {
    final l10n = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminDeleteOfficeHourSlotTitle),
          content: Text(
            l10n.adminDeleteOfficeHourSlotConfirmation(
              _dayLabel(slot.dayOfWeek, l10n),
              slot.startTime,
              slot.endTime,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AdminColors.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final result = await _periodsService.deleteOfficeHour(slot.slotId);

    if (result.isFailure) {
      _showSnackBar(result.error?.message ?? l10n.adminOfficeHourDeleteFailed);
      return;
    }

    _showSnackBar(l10n.adminOfficeHourSlotDeleted);
    _loadSlots();
  }

  Future<void> _toggleAppointments(int slotId) async {
    final isExpanded = _expandedSlotId == slotId;

    if (isExpanded) {
      setState(() => _expandedSlotId = null);
      return;
    }

    setState(() => _expandedSlotId = slotId);

    if (_appointmentsBySlot.containsKey(slotId) ||
        _appointmentsLoading.contains(slotId)) {
      return;
    }

    setState(() => _appointmentsLoading.add(slotId));

    final result = await _periodsService.getOfficeHourAppointments(
      slotId: slotId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _appointmentsLoading.remove(slotId);
      if (result.isFailure || result.data == null) {
        _appointmentsBySlot[slotId] = const <OfficeHourAppointmentModel>[];
      } else {
        _appointmentsBySlot[slotId] = result.data!.items;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final visibleSlots = _filteredSlots();

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: AppBar(
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
              l10n.officeHours,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _loadSlots,
                icon: Icon(Icons.refresh_rounded, color: AdminColors.primary),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSaving ? null : () => _openSlotForm(),
            backgroundColor: AdminColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.adminAddOfficeHour,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: RefreshIndicator(
                onRefresh: _loadSlots,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildFiltersCard(isDark, l10n),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!_isLoading && _errorMessage != null)
                      _buildErrorCard(_errorMessage!, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        visibleSlots.isEmpty)
                      _buildEmptyCard(isDark, l10n),
                    if (!_isLoading && _errorMessage == null)
                      ...visibleSlots.map(
                        (slot) => _buildSlotCard(slot, isDark, l10n),
                      ),
                    if (!_isLoading) _buildPaginationRow(isDark, l10n),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: l10n.adminSearchOfficeHours,
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            initialValue: _selectedInstructorId,
            decoration: InputDecoration(
              labelText: l10n.adminFilterByInstructor,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.adminAllStaff),
              ),
              ..._staff.map(
                (person) => DropdownMenuItem<int?>(
                  value: person.userId,
                  child: Text(person.fullName),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedInstructorId = value;
                _page = 1;
              });
              _loadSlots();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedDay,
            decoration: InputDecoration(
              labelText: l10n.adminFilterByDay,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l10n.adminAllDays)),
              DropdownMenuItem(
                value: 'MONDAY',
                child: Text(l10n.adminDayMonday),
              ),
              DropdownMenuItem(
                value: 'TUESDAY',
                child: Text(l10n.adminDayTuesday),
              ),
              DropdownMenuItem(
                value: 'WEDNESDAY',
                child: Text(l10n.adminDayWednesday),
              ),
              DropdownMenuItem(
                value: 'THURSDAY',
                child: Text(l10n.adminDayThursday),
              ),
              DropdownMenuItem(
                value: 'FRIDAY',
                child: Text(l10n.adminDayFriday),
              ),
              DropdownMenuItem(
                value: 'SATURDAY',
                child: Text(l10n.adminDaySaturday),
              ),
              DropdownMenuItem(
                value: 'SUNDAY',
                child: Text(l10n.adminDaySunday),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedDay = value;
                _page = 1;
              });
              _loadSlots();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedMode,
            decoration: InputDecoration(
              labelText: l10n.adminFilterByMode,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l10n.all)),
              DropdownMenuItem(
                value: 'in_person',
                child: Text(l10n.adminModeInPerson),
              ),
              DropdownMenuItem(value: 'online', child: Text(l10n.online)),
              DropdownMenuItem(value: 'hybrid', child: Text(l10n.hybrid)),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedMode = value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              labelText: l10n.adminFilterByRole,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l10n.all)),
              DropdownMenuItem(
                value: 'instructor',
                child: Text(l10n.instructor),
              ),
              DropdownMenuItem(value: 'ta', child: Text(l10n.ta)),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedRole = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(
    OfficeHourSlotModel slot,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isExpanded = _expandedSlotId == slot.slotId;
    final appointments =
        _appointmentsBySlot[slot.slotId] ??
        const <OfficeHourAppointmentModel>[];
    final loadingAppointments = _appointmentsLoading.contains(slot.slotId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _staffName(slot.instructorId, l10n: l10n),
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (slot.isActive
                                ? AdminColors.success
                                : AdminColors.warning)
                            .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    slot.isActive ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: slot.isActive
                          ? AdminColors.success
                          : AdminColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_dayLabel(slot.dayOfWeek, l10n)} • ${slot.startTime} - ${slot.endTime}',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_modeLabel(slot.mode, l10n)} • ${slot.location}',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.adminAppointmentsRatio(
                slot.currentAppointments,
                slot.maxAppointments,
              ),
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (slot.notes != null && slot.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                slot.notes!,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _toggleAppointments(slot.slotId),
                  icon: Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(
                    isExpanded
                        ? l10n.adminHideAppointments
                        : l10n.adminShowAppointments,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _openSlotForm(slot: slot),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.edit),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _confirmDelete(slot),
                  icon: Icon(Icons.delete_rounded, color: AdminColors.error),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(color: AdminColors.error),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              if (loadingAppointments)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (appointments.isEmpty)
                Text(l10n.adminNoAppointmentsForSlot)
              else
                ...appointments.map(
                  (appointment) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AdminColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            appointment.studentName.isNotEmpty
                                ? appointment.studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(appointment.topic),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDateTime(
                                appointment.appointmentDate,
                                l10n,
                              ),
                              style: TextStyle(
                                color: AdminColors.getTextSecondaryColor(
                                  isDark,
                                ),
                              ),
                            ),
                            Text(
                              _appointmentStatusLabel(appointment.status, l10n),
                              style: TextStyle(
                                color: AdminColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminOfficeHoursLoadErrorTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _loadSlots,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Text(
        l10n.adminOfficeHoursEmptyState,
        style: TextStyle(
          color: AdminColors.getTextSecondaryColor(isDark),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaginationRow(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _page <= 1
                  ? null
                  : () {
                      setState(() => _page -= 1);
                      _loadSlots();
                    },
              icon: const Icon(Icons.chevron_left_rounded),
              label: Text(l10n.previous),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AdminColors.getCardColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
            ),
            child: Text('${l10n.page} $_page ${l10n.of_} $_totalPages'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _page >= _totalPages
                  ? null
                  : () {
                      setState(() => _page += 1);
                      _loadSlots();
                    },
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(l10n.next),
            ),
          ),
        ],
      ),
    );
  }

  List<OfficeHourSlotModel> _filteredSlots() {
    final query = _searchController.text.trim().toLowerCase();

    return _slots.where((slot) {
      if (_selectedMode != 'all' && slot.mode.toLowerCase() != _selectedMode) {
        return false;
      }

      if (_selectedRole != 'all' &&
          !_staffHasRole(slot.instructorId, _selectedRole)) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final source = <String>[
        _staffName(slot.instructorId),
        slot.dayOfWeek,
        slot.location,
        slot.mode,
      ].join(' ').toLowerCase();

      return source.contains(query);
    }).toList();
  }

  String _staffName(int userId, {AppLocalizations? l10n}) {
    for (final person in _staff) {
      if (person.userId == userId) {
        return person.fullName;
      }
    }
    if (l10n != null) {
      return l10n.adminUnknownUserWithId(userId);
    }
    return 'User #$userId';
  }

  bool _staffHasRole(int userId, String role) {
    for (final person in _staff) {
      if (person.userId != userId) {
        continue;
      }

      if (role == 'instructor') {
        return person.roles.any((entry) {
          final normalized = entry.trim().toLowerCase();
          return normalized == 'instructor' || normalized == 'doctor';
        });
      }

      if (role == 'ta') {
        return person.roles.any((entry) {
          final normalized = entry.trim().toLowerCase();
          return normalized == 'ta' ||
              normalized == 'teaching_assistant' ||
              normalized == 'teaching assistant';
        });
      }

      return true;
    }

    return false;
  }

  bool _isValidTime(String value) {
    final pattern = RegExp(r'^([01]\\d|2[0-3]):[0-5]\\d$');
    return pattern.hasMatch(value);
  }

  String _formatDateTime(DateTime? value, AppLocalizations l10n) {
    if (value == null) {
      return l10n.adminTbd;
    }

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  String _dayLabel(String value, AppLocalizations l10n) {
    switch (value.toUpperCase()) {
      case 'MONDAY':
        return l10n.adminDayMonday;
      case 'TUESDAY':
        return l10n.adminDayTuesday;
      case 'WEDNESDAY':
        return l10n.adminDayWednesday;
      case 'THURSDAY':
        return l10n.adminDayThursday;
      case 'FRIDAY':
        return l10n.adminDayFriday;
      case 'SATURDAY':
        return l10n.adminDaySaturday;
      case 'SUNDAY':
        return l10n.adminDaySunday;
      default:
        return value;
    }
  }

  String _modeLabel(String value, AppLocalizations l10n) {
    switch (value.toLowerCase()) {
      case 'in_person':
      case 'in person':
        return l10n.adminModeInPerson;
      case 'online':
        return l10n.online;
      case 'hybrid':
        return l10n.hybrid;
      default:
        return value;
    }
  }

  String _appointmentStatusLabel(String value, AppLocalizations l10n) {
    switch (value.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'cancelled':
      case 'canceled':
        return l10n.adminStatusCancelled;
      case 'completed':
        return l10n.completedTasks;
      case 'confirmed':
        return l10n.adminStatusConfirmed;
      default:
        return value;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
