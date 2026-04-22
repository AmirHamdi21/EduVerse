import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';
import '../../../widgets/admin/ai_insights/ai_insights_barrel.dart';

class AdminAIInsightsScreen extends StatefulWidget {
  const AdminAIInsightsScreen({super.key});

  @override
  State<AdminAIInsightsScreen> createState() => _AdminAIInsightsScreenState();
}

class _AdminAIInsightsScreenState extends State<AdminAIInsightsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;

  String _selectedMode = 'general';
  bool _isTyping = false;

  final List<AIMessage> _messages = [];
  final List<AIRecommendation> _recommendations = [
    const AIRecommendation(
      id: '1',
      title: 'Low Attendance Alert',
      description:
          '15% of students have attendance below 75%. Consider sending reminders.',
      category: 'attendance',
      priority: 'high',
      icon: Icons.warning_rounded,
    ),
    const AIRecommendation(
      id: '2',
      title: 'Course Optimization',
      description:
          '3 courses have low engagement. Review content and scheduling.',
      category: 'courses',
      priority: 'medium',
      icon: Icons.school_rounded,
    ),
    const AIRecommendation(
      id: '3',
      title: 'Storage Cleanup',
      description: 'Unused files taking 15GB. Consider archiving old content.',
      category: 'system',
      priority: 'low',
      icon: Icons.storage_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      AIMessage(
        id: 'welcome',
        content:
            "Hello! I'm your Admin AI Assistant. I can help you with:\n\n"
            "📊 **Analytics & Reports** - Generate insights and reports\n"
            "🔍 **Data Analysis** - Analyze trends and patterns\n"
            "⚙️ **System Management** - Get help with configurations\n"
            "💡 **Recommendations** - Get AI-powered suggestions\n\n"
            "How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: ['Generate Report', 'Analyze Trends', 'System Status'],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage(String content) {
    if (content.isEmpty) return;

    setState(() {
      _messages.add(
        AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      String response;
      List<String>? suggestions;

      if (content.toLowerCase().contains('report')) {
        response =
            "I can generate several types of reports for you:\n\n"
            "• **Enrollment Report** - Student enrollment statistics\n"
            "• **Attendance Report** - Attendance trends and patterns\n"
            "• **Performance Report** - Academic performance analysis\n"
            "• **Financial Report** - Payment and subscription data\n\n"
            "Which report would you like me to generate?";
        suggestions = [
          'Enrollment Report',
          'Attendance Report',
          'Performance Report',
        ];
      } else if (content.toLowerCase().contains('analyze') ||
          content.toLowerCase().contains('trends')) {
        response =
            "Based on my analysis of the current data:\n\n"
            "📈 **Enrollment** is up 12% compared to last semester\n"
            "📉 **Attendance** has dropped 3% in the last week\n"
            "✅ **Course completion** rate is 78% (above average)\n"
            "⚠️ **3 courses** need attention due to low engagement\n\n"
            "Would you like me to dive deeper into any of these areas?";
        suggestions = [
          'More on Enrollment',
          'Attendance Details',
          'Low Engagement Courses',
        ];
      } else if (content.toLowerCase().contains('status') ||
          content.toLowerCase().contains('system')) {
        response =
            "System Status Overview:\n\n"
            "🟢 **Server Health**: All systems operational\n"
            "🟢 **Database**: Running smoothly (15ms avg response)\n"
            "🟡 **Storage**: 78% used (consider cleanup)\n"
            "🟢 **API**: 99.9% uptime this month\n\n"
            "No critical issues detected. Would you like more details?";
        suggestions = [
          'Storage Details',
          'Performance Logs',
          'Security Status',
        ];
      } else {
        response =
            "I understand you're asking about \"$content\". "
            "I can help you with analytics, reports, system management, and recommendations. "
            "Could you please be more specific about what you'd like me to do?";
        suggestions = ['Generate Report', 'Analyze Data', 'System Status'];
      }

      setState(() {
        _isTyping = false;
        _messages.add(
          AIMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response,
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: suggestions,
          ),
        );
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickAction(AIQuickAction action) {
    _sendMessage(action.prompt);
  }

  void _handleSuggestionTap(String suggestion) {
    _sendMessage(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            // drawer: const AdminDrawer(),
            body: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(isDark, l10n),
                    AdminAIModeSelector(
                      isDark: isDark,
                      selectedMode: _selectedMode,
                      onModeChanged: (mode) {
                        setState(() {
                          _selectedMode = mode;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _messages.length <= 1
                          ? _buildInitialState(isDark, l10n)
                          : _buildChatState(isDark, l10n),
                    ),
                    _buildInputBar(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AdminColors.purpleGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiInsights,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                  ),
                ),
                Text(
                  'Powered by AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          AdminAIStatsCard(
            isDark: isDark,
            queriesAnswered: 1256,
            reportsGenerated: 89,
            issuesDetected: 12,
            recommendationsMade: 45,
            satisfactionRate: 0.94,
          ),
          const SizedBox(height: 16),
          AdminAIQuickActions(isDark: isDark, onActionTap: _handleQuickAction),
          const SizedBox(height: 16),
          AdminAIRecommendations(
            isDark: isDark,
            recommendations: _recommendations,
            onRecommendationTap: (rec) {
              _sendMessage('Tell me more about: ${rec.title}');
            },
            onDismiss: (rec) {
              setState(() {
                _recommendations.removeWhere((r) => r.id == rec.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dismissed: ${rec.title}'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        _recommendations.add(rec);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatState(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: AdminAIChatSection(
            isDark: isDark,
            messages: _isTyping
                ? [
                    ..._messages,
                    AIMessage(
                      id: 'typing',
                      content: '',
                      isUser: false,
                      timestamp: DateTime.now(),
                      isTyping: true,
                    ),
                  ]
                : _messages,
            scrollController: _scrollController,
            onSuggestionTap: _handleSuggestionTap,
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask AI anything...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AdminColors.darkTextTertiary
                          : AdminColors.lightTextTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.auto_awesome_rounded,
                      color: AdminColors.secondary,
                      size: 20,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AdminColors.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AdminColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
