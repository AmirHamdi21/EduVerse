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

class AdminScheduleTemplatesScreen extends StatefulWidget {
  final AdminPeriodsService? periodsService;

  const AdminScheduleTemplatesScreen({super.key, this.periodsService});

  @override
  State<AdminScheduleTemplatesScreen> createState() =>
      _AdminScheduleTemplatesScreenState();
}

class _AdminScheduleTemplatesScreenState
    extends State<AdminScheduleTemplatesScreen> {
  CoreApiClient? _coreApiClient;
  late final AdminPeriodsService _periodsService;

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _typeFilter = 'all';

  int _page = 1;
  int _totalPages = 1;

  List<ScheduleTemplateModel> _templates = const <ScheduleTemplateModel>[];

  @override
  void initState() {
    super.initState();
    if (widget.periodsService != null) {
      _periodsService = widget.periodsService!;
    } else {
      _coreApiClient = CoreApiClient();
      _periodsService = AdminPeriodsService(coreApiClient: _coreApiClient!);
    }
    _searchController.addListener(_handleSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadTemplates();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _coreApiClient?.dio.close(force: true);
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _page = 1;
    });
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _periodsService.getScheduleTemplates(
      page: _page,
      limit: 10,
      search: _searchController.text,
      scheduleType: _typeFilter == 'all' ? null : _typeFilter,
    );

    if (!mounted) {
      return;
    }

    if (result.isFailure || result.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.error?.message ?? l10n.adminScheduleTemplatesLoadFailed;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _templates = result.data!.items;
      _totalPages = result.data!.meta.totalPages <= 0
          ? 1
          : result.data!.meta.totalPages;
    });
  }

  Future<void> _openTemplateForm({ScheduleTemplateModel? template}) async {
    final l10n = AppLocalizations.of(context);

    final nameController = TextEditingController(text: template?.name ?? '');
    final descriptionController = TextEditingController(
      text: template?.description ?? '',
    );

    String scheduleType = template?.scheduleType ?? 'LECTURE';
    bool isActive = template?.isActive ?? true;

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
                        template == null
                            ? l10n.adminCreateScheduleTemplate
                            : l10n.adminEditScheduleTemplate,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.adminTemplateName,
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
                        initialValue: scheduleType,
                        decoration: InputDecoration(
                          labelText: l10n.adminScheduleType,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'LECTURE',
                            child: Text(l10n.adminScheduleTypeLecture),
                          ),
                          DropdownMenuItem(
                            value: 'LAB',
                            child: Text(l10n.adminScheduleTypeLab),
                          ),
                          DropdownMenuItem(
                            value: 'TUTORIAL',
                            child: Text(l10n.adminScheduleTypeTutorial),
                          ),
                          DropdownMenuItem(
                            value: 'HYBRID',
                            child: Text(l10n.hybrid),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => scheduleType = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: isActive,
                        title: Text(l10n.adminTemplateIsActive),
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
                                      final name = nameController.text.trim();
                                      if (name.isEmpty) {
                                        _showSnackBar(
                                          l10n.adminTemplateNameRequired,
                                        );
                                        return;
                                      }

                                      final payload = <String, dynamic>{
                                        'name': name,
                                        'scheduleType': scheduleType,
                                        'isActive': isActive,
                                        'slots': template == null
                                            ? const <Map<String, dynamic>>[]
                                            : template.slots
                                                  .map(
                                                    (slot) => <String, dynamic>{
                                                      'dayOfWeek':
                                                          slot.dayOfWeek,
                                                      'startTime':
                                                          slot.startTime,
                                                      'endTime': slot.endTime,
                                                      'slotType': slot.slotType,
                                                      if (slot.building !=
                                                              null &&
                                                          slot.building!
                                                              .trim()
                                                              .isNotEmpty)
                                                        'building': slot
                                                            .building!
                                                            .trim(),
                                                      if (slot.room != null &&
                                                          slot.room!
                                                              .trim()
                                                              .isNotEmpty)
                                                        'room': slot.room!
                                                            .trim(),
                                                    },
                                                  )
                                                  .toList(),
                                      };

                                      final description = descriptionController
                                          .text
                                          .trim();
                                      if (description.isNotEmpty) {
                                        payload['description'] = description;
                                      }

                                      setState(() => _isSaving = true);

                                      final result = template == null
                                          ? await _periodsService
                                                .createScheduleTemplate(payload)
                                          : await _periodsService
                                                .updateScheduleTemplate(
                                                  template.templateId,
                                                  payload,
                                                );

                                      if (!mounted) {
                                        return;
                                      }

                                      setState(() => _isSaving = false);

                                      if (result.isFailure) {
                                        _showSnackBar(
                                          result.error?.message ??
                                              l10n.adminTemplateSaveFailed,
                                        );
                                        return;
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.pop(context);
                                      _showSnackBar(
                                        template == null
                                            ? l10n.adminTemplateCreated
                                            : l10n.adminTemplateUpdated,
                                      );
                                      _loadTemplates();
                                    },
                              child: Text(
                                template == null ? l10n.create : l10n.save,
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

    nameController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDelete(ScheduleTemplateModel template) async {
    final l10n = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminDeleteTemplateTitle),
          content: Text(l10n.adminDeleteTemplateConfirmation(template.name)),
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

    final result = await _periodsService.deleteScheduleTemplate(
      template.templateId,
    );

    if (result.isFailure) {
      _showSnackBar(result.error?.message ?? l10n.adminTemplateDeleteFailed);
      return;
    }

    _showSnackBar(l10n.adminTemplateDeleted);
    _loadTemplates();
  }

  Future<void> _openApplyDialog(ScheduleTemplateModel template) async {
    final l10n = AppLocalizations.of(context);

    final sectionIdController = TextEditingController();
    final buildingController = TextEditingController();
    final roomController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminApplyTemplateTitle(template.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sectionIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.adminSectionId,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: buildingController,
                decoration: InputDecoration(
                  labelText: l10n.adminBuildingOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomController,
                decoration: InputDecoration(
                  labelText: l10n.adminRoomOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final sectionId = int.tryParse(sectionIdController.text.trim());
                if (sectionId == null) {
                  _showSnackBar(l10n.adminSectionIdMustBeNumber);
                  return;
                }

                final result = await _periodsService.applyTemplate(
                  templateId: template.templateId,
                  sectionId: sectionId,
                  building: buildingController.text,
                  room: roomController.text,
                );

                if (!mounted) {
                  return;
                }

                if (result.isFailure) {
                  _showSnackBar(
                    result.error?.message ?? l10n.adminTemplateApplyFailed,
                  );
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);
                final schedulesCreated =
                    (result.data?['schedulesCreated'] as num?)?.toInt() ?? 0;
                _showSnackBar(
                  l10n.adminTemplateAppliedWithCount(schedulesCreated),
                );
              },
              child: Text(l10n.apply),
            ),
          ],
        );
      },
    );

    sectionIdController.dispose();
    buildingController.dispose();
    roomController.dispose();
  }

  Future<void> _openBulkApplyDialog(ScheduleTemplateModel template) async {
    final l10n = AppLocalizations.of(context);

    final sectionIdsController = TextEditingController();
    final buildingController = TextEditingController();
    final roomController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminBulkApplyTemplateTitle(template.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sectionIdsController,
                decoration: InputDecoration(
                  labelText: l10n.adminSectionIdsCommaSeparated,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: buildingController,
                decoration: InputDecoration(
                  labelText: l10n.adminBuildingOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomController,
                decoration: InputDecoration(
                  labelText: l10n.adminRoomOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final sections = sectionIdsController.text
                    .split(',')
                    .map((value) => int.tryParse(value.trim()))
                    .whereType<int>()
                    .toList();

                if (sections.isEmpty) {
                  _showSnackBar(l10n.adminAtLeastOneSectionRequired);
                  return;
                }

                final result = await _periodsService.bulkApplyTemplate(
                  templateId: template.templateId,
                  sectionIds: sections,
                  building: buildingController.text,
                  room: roomController.text,
                );

                if (!mounted) {
                  return;
                }

                if (result.isFailure) {
                  _showSnackBar(
                    result.error?.message ?? l10n.adminBulkApplyFailed,
                  );
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);
                final successful =
                    (result.data?['successful'] as num?)?.toInt() ?? 0;
                final failed = (result.data?['failed'] as num?)?.toInt() ?? 0;
                _showSnackBar(l10n.adminBulkApplyResult(successful, failed));
              },
              child: Text(l10n.adminBulkApply),
            ),
          ],
        );
      },
    );

    sectionIdsController.dispose();
    buildingController.dispose();
    roomController.dispose();
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
              l10n.adminScheduleTemplates,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _loadTemplates,
                icon: Icon(Icons.refresh_rounded, color: AdminColors.primary),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSaving ? null : () => _openTemplateForm(),
            backgroundColor: AdminColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.adminCreateTemplate,
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
                onRefresh: _loadTemplates,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                  children: [
                    _buildFiltersCard(isDark, l10n),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!_isLoading && _errorMessage != null)
                      _buildErrorCard(isDark, _errorMessage!, l10n),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _templates.isEmpty)
                      _buildEmptyCard(isDark, l10n),
                    if (!_isLoading && _errorMessage == null)
                      ..._templates.map(
                        (template) =>
                            _buildTemplateCard(template, isDark, l10n),
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
              labelText: l10n.adminSearchTemplates,
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${l10n.adminType}:'),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _typeFilter,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(l10n.all)),
                    DropdownMenuItem(
                      value: 'LECTURE',
                      child: Text(l10n.adminScheduleTypeLecture),
                    ),
                    DropdownMenuItem(
                      value: 'LAB',
                      child: Text(l10n.adminScheduleTypeLab),
                    ),
                    DropdownMenuItem(
                      value: 'TUTORIAL',
                      child: Text(l10n.adminScheduleTypeTutorial),
                    ),
                    DropdownMenuItem(value: 'HYBRID', child: Text(l10n.hybrid)),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _typeFilter = value;
                      _page = 1;
                    });
                    _loadTemplates();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    ScheduleTemplateModel template,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final statusColor = template.isActive
        ? AdminColors.success
        : AdminColors.warning;

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
                    template.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    template.isActive ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_scheduleTypeLabel(template.scheduleType, l10n)} • ${template.departmentName}',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.adminTemplateSlotsCreator(
                template.slotCount,
                template.creatorName,
              ),
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
            if (template.description != null &&
                template.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                template.description!,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
            if (template.slots.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.adminTemplateSlotsPreview,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...template.slots
                  .take(2)
                  .map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        l10n.adminTemplateSlotLine(
                          _dayLabel(slot.dayOfWeek, l10n),
                          slot.startTime,
                          slot.endTime,
                          _slotLocation(slot, l10n),
                        ),
                        style: TextStyle(
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                    ),
                  ),
              if (template.slots.length > 2)
                Text(
                  l10n.adminMoreSlots(template.slots.length - 2),
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
                  onPressed: () => _openApplyDialog(template),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.apply),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openBulkApplyDialog(template),
                  icon: const Icon(Icons.layers_rounded),
                  label: Text(l10n.adminBulkApply),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _openTemplateForm(template: template),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.edit),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _confirmDelete(template),
                  icon: Icon(Icons.delete_rounded, color: AdminColors.error),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(color: AdminColors.error),
                  ),
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
            l10n.adminScheduleTemplatesLoadErrorTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _loadTemplates,
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
        l10n.adminTemplatesEmptyState,
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
                      _loadTemplates();
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
                      _loadTemplates();
                    },
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(l10n.next),
            ),
          ),
        ],
      ),
    );
  }

  String _scheduleTypeLabel(String value, AppLocalizations l10n) {
    switch (value.toUpperCase()) {
      case 'LECTURE':
        return l10n.adminScheduleTypeLecture;
      case 'LAB':
        return l10n.adminScheduleTypeLab;
      case 'TUTORIAL':
        return l10n.adminScheduleTypeTutorial;
      case 'HYBRID':
        return l10n.hybrid;
      default:
        return value;
    }
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

  String _slotLocation(ScheduleTemplateSlotModel slot, AppLocalizations l10n) {
    final parts = <String>[];
    final building = slot.building?.trim() ?? '';
    final room = slot.room?.trim() ?? '';
    if (building.isNotEmpty) {
      parts.add(building);
    }
    if (room.isNotEmpty) {
      parts.add(room);
    }

    if (parts.isEmpty) {
      return l10n.adminTbd;
    }

    return parts.join(' • ');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
