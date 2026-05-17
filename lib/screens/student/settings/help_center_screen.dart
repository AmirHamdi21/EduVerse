import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<_FAQItem> _filteredFaqItems = [];
  late List<_FAQItem> _allFaqItems;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _allFaqItems = [
      _FAQItem(
        question: l10n.faqQuestion1,
        answer: l10n.faqAnswer1,
        icon: Icons.lock_rounded,
        category: 'account',
      ),
      _FAQItem(
        question: l10n.faqQuestion2,
        answer: l10n.faqAnswer2,
        icon: Icons.security_rounded,
        category: 'account',
      ),
      _FAQItem(
        question: l10n.faqQuestion3,
        answer: l10n.faqAnswer3,
        icon: Icons.download_rounded,
        category: 'courses',
      ),
      _FAQItem(
        question: l10n.faqQuestion4,
        answer: l10n.faqAnswer4,
        icon: Icons.chat_rounded,
        category: 'courses',
      ),
      _FAQItem(
        question: l10n.faqQuestion5,
        answer: l10n.faqAnswer5,
        icon: Icons.notifications_rounded,
        category: 'getting_started',
      ),
    ];
    _filteredFaqItems = _allFaqItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFaqItems = _allFaqItems;
      } else {
        _filteredFaqItems = _allFaqItems
            .where(
              (item) =>
                  item.question.toLowerCase().contains(query.toLowerCase()) ||
                  item.answer.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      if (category == 'all') {
        _filteredFaqItems = _allFaqItems;
      } else {
        _filteredFaqItems = _allFaqItems
            .where((item) => item.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.helpCenter,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Search Card
          _buildSearchCard(isDark, l10n),
          const SizedBox(height: 24),

          // Quick Help
          _buildSectionTitle(l10n.quickHelp, isDark),
          const SizedBox(height: 12),
          _buildQuickHelpGrid(isDark, l10n),
          const SizedBox(height: 24),

          // FAQ
          _buildSectionTitle(l10n.frequentlyAsked, isDark),
          const SizedBox(height: 12),
          if (_filteredFaqItems.isEmpty)
            _buildNoResults(isDark, l10n)
          else
            ..._filteredFaqItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFAQItem(isDark, item),
              ),
            ),
          const SizedBox(height: 24),

          // Contact Support
          _buildContactCard(isDark, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _filterFAQs('');
            },
            child: Text(l10n.clearSearch),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howCanWeHelp,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.searchHelpDesc,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _searchController,
              onChanged: _filterFAQs,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: const Color(0xFF2563EB),
              decoration: InputDecoration(
                hintText: l10n.searchHelp,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterFAQs('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuickHelpGrid(bool isDark, AppLocalizations l10n) {
    final items = [
      (
        Icons.book_rounded,
        l10n.gettingStarted,
        const Color(0xFF3B82F6),
        'getting_started',
      ),
      (
        Icons.account_circle_rounded,
        l10n.accountHelp,
        const Color(0xFF8B5CF6),
        'account',
      ),
      (
        Icons.school_rounded,
        l10n.coursesHelp,
        const Color(0xFF10B981),
        'courses',
      ),
      (
        Icons.payment_rounded,
        l10n.billingHelp,
        const Color(0xFFF59E0B),
        'billing',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((item) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _filterByCategory(item.$4);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.showingResultsFor} ${item.$2}'),
                backgroundColor: item.$3,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.$3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.$1, size: 24, color: item.$3),
                ),
                const SizedBox(height: 12),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFAQItem(bool isDark, _FAQItem item) {
    return _ExpandableFAQCard(isDark: isDark, item: item);
  }

  Widget _buildContactCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 32,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.stillNeedHelp,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.contactSupportDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  isDark: isDark,
                  icon: Icons.chat_bubble_rounded,
                  label: l10n.liveChat,
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showLiveChatDialog(isDark, l10n),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  isDark: isDark,
                  icon: Icons.email_rounded,
                  label: l10n.emailUs,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'support@eduverse.com'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${l10n.emailCopied}: support@eduverse.com',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _LiveChatDialog(isDark: isDark, l10n: l10n),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  final IconData icon;
  final String category;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.icon,
    required this.category,
  });
}

class _ExpandableFAQCard extends StatefulWidget {
  final bool isDark;
  final _FAQItem item;

  const _ExpandableFAQCard({required this.isDark, required this.item});

  @override
  State<_ExpandableFAQCard> createState() => _ExpandableFAQCardState();
}

class _ExpandableFAQCardState extends State<_ExpandableFAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 20,
                      color: widget.isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.item.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveChatDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _LiveChatDialog({required this.isDark, required this.l10n});

  @override
  State<_LiveChatDialog> createState() => _LiveChatDialogState();
}

class _LiveChatDialogState extends State<_LiveChatDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Simulate connecting to support
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _messages.add(
            _ChatMessage(
              message: widget.l10n.supportGreeting,
              isUser: false,
              time: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          message: _messageController.text,
          isUser: true,
          time: DateTime.now(),
        ),
      );
    });
    _messageController.clear();

    // Simulate support response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              message: widget.l10n.supportAutoReply,
              isUser: false,
              time: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 400,
            ),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                // Messages
                Flexible(
                  child: _isConnecting
                      ? _buildConnectingState()
                      : _buildMessagesList(),
                ),
                // Input
                if (!_isConnecting) _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.l10n.liveSupport,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.l10n.online,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.l10n.connectingToSupport,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.l10n.pleaseWait,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      reverse: false,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 18,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xFF3B82F6)
                  : (widget.isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: message.isUser ? const Radius.circular(4) : null,
                bottomLeft: !message.isUser ? const Radius.circular(4) : null,
              ),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 14,
                color: message.isUser
                    ? Colors.white
                    : (widget.isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: widget.l10n.typeMessage,
                  hintStyle: TextStyle(
                    color: widget.isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String message;
  final bool isUser;
  final DateTime time;

  _ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}
