import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';
import 'instructor_chat_models.dart';

class InstructorNewChatDialog extends StatefulWidget {
  final bool isDark;
  final Function(String name, InstructorConversationType type, String? course)? onCreate;

  const InstructorNewChatDialog({
    super.key,
    required this.isDark,
    this.onCreate,
  });

  @override
  State<InstructorNewChatDialog> createState() => _InstructorNewChatDialogState();
}

class _InstructorNewChatDialogState extends State<InstructorNewChatDialog> {
  final TextEditingController _searchController = TextEditingController();
  InstructorConversationType _selectedType = InstructorConversationType.student;

  // Mock contacts
  final List<_Contact> _students = [
    _Contact('John Smith', 'JS', 'CS 101', true),
    _Contact('Emily Johnson', 'EJ', 'CS 201', false),
    _Contact('Michael Brown', 'MB', 'CS 101', false),
    _Contact('Sarah Davis', 'SD', 'CS 301', true),
    _Contact('Ahmed Hassan', 'AH', 'CS 201', false),
    _Contact('Sara Ali', 'SA', 'CS 101', true),
    _Contact('Omar Khaled', 'OK', 'CS 301', false),
  ];

  final List<_Contact> _colleagues = [
    _Contact('Dr. Robert Williams', 'RW', null, false),
    _Contact('Dr. Lisa Anderson', 'LA', null, true),
    _Contact('Prof. James Wilson', 'JW', null, false),
    _Contact('Dr. Maria Garcia', 'MG', null, false),
  ];

  final List<_Contact> _groups = [
    _Contact('CS 101 - General', '101', 'CS 101', false, memberCount: 45),
    _Contact('CS 201 - Questions', '201', 'CS 201', false, memberCount: 38),
    _Contact('Department Faculty', 'DF', null, false, memberCount: 12),
    _Contact('Research Team', 'RT', null, false, memberCount: 8),
  ];

  List<_Contact> get _filteredContacts {
    List<_Contact> contacts;
    switch (_selectedType) {
      case InstructorConversationType.student:
        contacts = _students;
        break;
      case InstructorConversationType.colleague:
        contacts = _colleagues;
        break;
      case InstructorConversationType.group:
        contacts = _groups;
        break;
    }

    if (_searchController.text.isEmpty) return contacts;

    return contacts.where((c) =>
        c.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: InstructorColors.background(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: InstructorColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'New Conversation',
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: InstructorColors.textTertiaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
              ),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(
                  color: InstructorColors.textTertiaryColor(isDark),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: InstructorColors.textTertiaryColor(isDark),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTypeChip(l10n.students, InstructorConversationType.student, isDark),
                const SizedBox(width: 8),
                _buildTypeChip('Colleagues', InstructorConversationType.colleague, isDark),
                const SizedBox(width: 8),
                _buildTypeChip(l10n.groups, InstructorConversationType.group, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Contact list
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: TextStyle(
                        color: InstructorColors.textTertiaryColor(isDark),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return _buildContactTile(contact, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, InstructorConversationType type, bool isDark) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? InstructorColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? InstructorColors.primary
                  : InstructorColors.borderColor(isDark),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : InstructorColors.textSecondaryColor(isDark),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(_Contact contact, bool isDark) {
    return GestureDetector(
      onTap: () {
        widget.onCreate?.call(contact.name, _selectedType, contact.courseName);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _selectedType == InstructorConversationType.group
                    ? InstructorColors.accent.withValues(alpha: 0.1)
                    : InstructorColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _selectedType == InstructorConversationType.group
                    ? Icon(
                        Icons.group_outlined,
                        color: InstructorColors.accent,
                        size: 22,
                      )
                    : Text(
                        contact.initials,
                        style: TextStyle(
                          color: InstructorColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (contact.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: InstructorColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (contact.courseName != null)
                        Text(
                          contact.courseName!,
                          style: TextStyle(
                            color: InstructorColors.textTertiaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      if (contact.memberCount != null)
                        Text(
                          '${contact.memberCount} members',
                          style: TextStyle(
                            color: InstructorColors.textTertiaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  final String initials;
  final String? courseName;
  final bool isOnline;
  final int? memberCount;

  const _Contact(
    this.name,
    this.initials,
    this.courseName,
    this.isOnline, {
    this.memberCount,
  });
}
