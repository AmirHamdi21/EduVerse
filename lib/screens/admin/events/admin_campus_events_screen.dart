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

class AdminCampusEventsScreen extends StatefulWidget {
  final AdminPeriodsService? periodsService;

  const AdminCampusEventsScreen({super.key, this.periodsService});

  @override
  State<AdminCampusEventsScreen> createState() =>
      _AdminCampusEventsScreenState();
}

class _AdminCampusEventsScreenState extends State<AdminCampusEventsScreen> {
  CoreApiClient? _coreApiClient;
  late final AdminPeriodsService _periodsService;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _statusFilter = 'all';
  int _page = 1;
  int _totalPages = 1;

  List<CampusEventModel> _events = const <CampusEventModel>[];

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
      _loadEvents();
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
      _page = 1;
    });
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _periodsService.getCampusEvents(
      page: _page,
      limit: 10,
      search: _searchController.text,
      status: _statusFilter == 'all' ? null : _statusFilter,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure || result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.error?.message ?? l10n.adminCampusEventsLoadFailed;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _events = result.data!.items;
      _totalPages = result.data!.meta.totalPages <= 0
          ? 1
          : result.data!.meta.totalPages;
    });
  }

  Future<void> _openEventForm({CampusEventModel? event}) async {
    final l10n = AppLocalizations.of(context);

    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    final locationController = TextEditingController(
      text: event?.location ?? '',
    );
    final maxAttendeesController = TextEditingController(
      text: event?.maxAttendees?.toString() ?? '',
    );

    String eventType = event?.eventType ?? 'GENERAL';
    String status = event?.status ?? 'draft';
    bool isMandatory = event?.isMandatory ?? false;
    bool registrationRequired = event?.registrationRequired ?? false;
    DateTime startDate =
        event?.startDateTime ?? DateTime.now().add(const Duration(days: 1));
    DateTime endDate =
        event?.endDateTime ??
        DateTime.now().add(const Duration(days: 1, hours: 1));

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event == null
                            ? l10n.adminCreateCampusEvent
                            : l10n.adminEditCampusEvent,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.title,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: eventType,
                        decoration: InputDecoration(
                          labelText: l10n.eventType,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'GENERAL',
                            child: Text(l10n.adminEventTypeGeneral),
                          ),
                          DropdownMenuItem(
                            value: 'WORKSHOP',
                            child: Text(l10n.adminEventTypeWorkshop),
                          ),
                          DropdownMenuItem(
                            value: 'SEMINAR',
                            child: Text(l10n.adminEventTypeSeminar),
                          ),
                          DropdownMenuItem(
                            value: 'EXAM',
                            child: Text(l10n.exam),
                          ),
                          DropdownMenuItem(
                            value: 'MEETING',
                            child: Text(l10n.adminEventTypeMeeting),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => eventType = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: InputDecoration(
                          labelText: l10n.status,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'draft',
                            child: Text(l10n.draft),
                          ),
                          DropdownMenuItem(
                            value: 'published',
                            child: Text(l10n.adminStatusPublished),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text(l10n.adminStatusCancelled),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => status = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      _DateTimeInputTile(
                        label: l10n.adminStart,
                        value: startDate,
                        onChanged: (next) =>
                            setModalState(() => startDate = next),
                      ),
                      const SizedBox(height: 8),
                      _DateTimeInputTile(
                        label: l10n.adminEnd,
                        value: endDate,
                        onChanged: (next) =>
                            setModalState(() => endDate = next),
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
                      TextField(
                        controller: maxAttendeesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.adminMaxAttendees,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: isMandatory,
                        onChanged: (value) =>
                            setModalState(() => isMandatory = value),
                        title: Text(l10n.adminMandatory),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: registrationRequired,
                        onChanged: (value) =>
                            setModalState(() => registrationRequired = value),
                        title: Text(l10n.adminRegistrationRequired),
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
                                      final title = titleController.text.trim();
                                      if (title.isEmpty) {
                                        _showSnackBar(
                                          l10n.adminEventTitleRequired,
                                        );
                                        return;
                                      }
                                      if (!endDate.isAfter(startDate)) {
                                        _showSnackBar(
                                          l10n.adminEndDateMustBeAfterStartDate,
                                        );
                                        return;
                                      }

                                      final payload = <String, dynamic>{
                                        'title': title,
                                        'eventType': eventType,
                                        'status': status,
                                        'startDatetime': startDate
                                            .toIso8601String(),
                                        'endDatetime': endDate
                                            .toIso8601String(),
                                        'isMandatory': isMandatory,
                                        'registrationRequired':
                                            registrationRequired,
                                        'color': event?.color ?? '#2B7FFF',
                                      };

                                      final description = descriptionController
                                          .text
                                          .trim();
                                      if (description.isNotEmpty) {
                                        payload['description'] = description;
                                      }

                                      final location = locationController.text
                                          .trim();
                                      if (location.isNotEmpty) {
                                        payload['location'] = location;
                                      }

                                      final maxAttendees = int.tryParse(
                                        maxAttendeesController.text.trim(),
                                      );
                                      if (maxAttendees != null) {
                                        payload['maxAttendees'] = maxAttendees;
                                      }

                                      setState(() => _isSaving = true);

                                      final operation = event == null
                                          ? _periodsService.createCampusEvent(
                                              payload,
                                            )
                                          : _periodsService.updateCampusEvent(
                                              event.eventId,
                                              payload,
                                            );
                                      final result = await operation;

                                      if (!mounted) {
                                        return;
                                      }

                                      setState(() => _isSaving = false);

                                      if (result.isFailure) {
                                        _showSnackBar(
                                          result.error?.message ??
                                              l10n.adminCampusEventSaveFailed,
                                        );
                                        return;
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.pop(context);
                                      _showSnackBar(
                                        event == null
                                            ? l10n.adminCampusEventCreated
                                            : l10n.adminCampusEventUpdated,
                                      );
                                      _loadEvents();
                                    },
                              child: Text(
                                event == null ? l10n.create : l10n.save,
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

    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    maxAttendeesController.dispose();
  }

  Future<void> _confirmDelete(CampusEventModel event) async {
    final l10n = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminDeleteCampusEventTitle),
          content: Text(l10n.adminDeleteCampusEventConfirmation(event.title)),
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

    final result = await _periodsService.deleteCampusEvent(event.eventId);
    if (result.isFailure) {
      _showSnackBar(result.error?.message ?? l10n.adminCampusEventDeleteFailed);
      return;
    }

    _showSnackBar(l10n.adminCampusEventDeleted);
    _loadEvents();
  }

  Future<void> _showRegistrations(CampusEventModel event) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.adminRegistrationsForEvent(event.title),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<CampusEventRegistrationModel>>(
                future: _loadRegistrations(event.eventId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Expanded(
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  }

                  final registrations =
                      snapshot.data ?? const <CampusEventRegistrationModel>[];

                  if (registrations.isEmpty) {
                    return Expanded(
                      child: Center(child: Text(l10n.adminNoRegistrationsYet)),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      itemCount: registrations.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final registration = registrations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AdminColors.primary.withValues(
                              alpha: 0.14,
                            ),
                            child: Text(
                              registration.attendeeName.isNotEmpty
                                  ? registration.attendeeName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(registration.attendeeName),
                          subtitle: Text(registration.attendeeEmail),
                          trailing: Text(
                            _eventStatusLabel(registration.status, l10n),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<CampusEventRegistrationModel>> _loadRegistrations(
    int eventId,
  ) async {
    final l10n = AppLocalizations.of(context);

    final result = await _periodsService.getCampusEventRegistrations(eventId);
    if (result.isFailure || result.data == null) {
      throw result.error?.message ?? l10n.adminRegistrationsLoadFailed;
    }
    return result.data!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

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
              l10n.adminCampusEvents,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _loadEvents,
                icon: Icon(Icons.refresh_rounded, color: AdminColors.primary),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSaving ? null : () => _openEventForm(),
            backgroundColor: AdminColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.adminCreateEvent,
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
                onRefresh: _loadEvents,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _buildFilters(isDark, l10n),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!_isLoading && _errorMessage != null)
                      _buildErrorCard(isDark, _errorMessage!, l10n),
                    if (!_isLoading && _errorMessage == null && _events.isEmpty)
                      _buildEmptyCard(isDark, l10n),
                    if (!_isLoading && _errorMessage == null)
                      ..._events.map(
                        (event) => _buildEventCard(event, isDark, l10n),
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

  Widget _buildFilters(bool isDark, AppLocalizations l10n) {
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
              labelText: l10n.adminSearchEvents,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${l10n.status}:'),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _statusFilter,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.all)),
                    DropdownMenuItem(value: 'draft', child: Text(l10n.draft)),
                    DropdownMenuItem(
                      value: 'published',
                      child: Text(l10n.adminStatusPublished),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text(l10n.adminStatusCancelled),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _statusFilter = value;
                      _page = 1;
                    });
                    _loadEvents();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    CampusEventModel event,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final location = _eventLocation(event, l10n);
    final hasCapacity = event.maxAttendees != null && event.maxAttendees! > 0;

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
                    event.title,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusPill(
                  label: _eventStatusLabel(event.status, l10n),
                  color: _statusColor(event.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_eventTypeLabel(event.eventType, l10n)} • ${_formatDateTime(event.startDateTime, l10n)}',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            if (event.endDateTime != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.adminEndsAt(_formatDateTime(event.endDateTime, l10n)),
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
              ),
            ],
            if (location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                location,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
              ),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (event.isMandatory)
                  _InfoChip(
                    label: l10n.adminMandatory,
                    color: AdminColors.error,
                  ),
                if (event.registrationRequired)
                  _InfoChip(
                    label: l10n.adminRegistrationRequired,
                    color: AdminColors.primary,
                  ),
                if (hasCapacity)
                  _InfoChip(
                    label: l10n.adminCapacityUsed(
                      event.registrationCount,
                      event.maxAttendees!,
                    ),
                    color: AdminColors.success,
                  ),
                if (event.spotsRemaining != null)
                  _InfoChip(
                    label: l10n.adminSpotsRemaining(event.spotsRemaining!),
                    color: AdminColors.warning,
                  ),
                ...event.tags
                    .take(3)
                    .map(
                      (tag) => _InfoChip(
                        label: '#$tag',
                        color: AdminColors.secondary,
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasCapacity
                        ? l10n.adminRegistrationCountWithCapacity(
                            event.registrationCount,
                            event.maxAttendees!,
                          )
                        : l10n.adminRegistrationCount(event.registrationCount),
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showRegistrations(event),
                  icon: const Icon(Icons.people_alt_rounded),
                  label: Text(l10n.adminRegistrations),
                ),
                IconButton(
                  tooltip: l10n.adminEditEventTooltip,
                  onPressed: _isSaving
                      ? null
                      : () => _openEventForm(event: event),
                  icon: Icon(Icons.edit_rounded, color: AdminColors.primary),
                ),
                IconButton(
                  tooltip: l10n.adminDeleteEventTooltip,
                  onPressed: _isSaving ? null : () => _confirmDelete(event),
                  icon: Icon(Icons.delete_rounded, color: AdminColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, String message, AppLocalizations l10n) {
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
            l10n.adminCampusEventsLoadErrorTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Text(
        l10n.adminCampusEventsEmptyState,
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
                      _loadEvents();
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
                      _loadEvents();
                    },
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(l10n.next),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return AdminColors.success;
      case 'cancelled':
        return AdminColors.error;
      default:
        return AdminColors.warning;
    }
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

  String _eventStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'draft':
        return l10n.draft;
      case 'published':
      case 'active':
        return l10n.adminStatusPublished;
      case 'cancelled':
      case 'canceled':
        return l10n.adminStatusCancelled;
      case 'registered':
        return l10n.adminStatusRegistered;
      default:
        return _toTitleCase(status);
    }
  }

  String _eventTypeLabel(String eventType, AppLocalizations l10n) {
    switch (eventType.toUpperCase()) {
      case 'GENERAL':
        return l10n.adminEventTypeGeneral;
      case 'WORKSHOP':
        return l10n.adminEventTypeWorkshop;
      case 'SEMINAR':
        return l10n.adminEventTypeSeminar;
      case 'EXAM':
        return l10n.exam;
      case 'MEETING':
        return l10n.adminEventTypeMeeting;
      default:
        return _toTitleCase(eventType);
    }
  }

  String _eventLocation(CampusEventModel event, AppLocalizations l10n) {
    final parts = <String>[];
    void add(String? value) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty && !parts.contains(text)) {
        parts.add(text);
      }
    }

    add(event.location);
    add(event.building);
    add(event.room);

    if (parts.isEmpty) {
      return l10n.adminTbd;
    }

    return parts.join(' • ');
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DateTimeInputTile extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeInputTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (pickedDate == null || !context.mounted) {
          return;
        }

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );

        if (pickedTime == null) {
          return;
        }

        final next = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        onChanged(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: AdminColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label: ${_formatDateTime(value)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
