// import 'package:flutter/material.dart';
// import '../../../bloc/chat/chat_models.dart';
// import 'chat_conversation_tile.dart';

// class ChatConversationList extends StatelessWidget {
//   final List<ConversationModel> conversations;
//   final bool isDark;
//   final ValueChanged<ConversationModel> onConversationTap;
//   final ValueChanged<ConversationModel> onConversationLongPress;
//   final ValueChanged<String>? onDelete;
//   final ValueChanged<String>? onArchive;
//   final ValueChanged<String>? onPin;
//   final ValueChanged<String>? onMute;
//   final ValueChanged<String>? onMarkRead;

//   const ChatConversationList({
//     super.key,
//     required this.conversations,
//     required this.isDark,
//     required this.onConversationTap,
//     required this.onConversationLongPress,
//     this.onDelete,
//     this.onArchive,
//     this.onPin,
//     this.onMute,
//     this.onMarkRead,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final sorted = [...conversations]
//       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       physics: const BouncingScrollPhysics(),
//       itemCount: sorted.isEmpty ? 1 : sorted.length + 1,
//       itemBuilder: (context, index) {
//         if (sorted.isEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 48),
//               child: Text(
//                 'No conversations yet',
//                 style: TextStyle(
//                   color: isDark
//                       ? const Color(0xFF94A3B8)
//                       : const Color(0xFF64748B),
//                 ),
//               ),
//             ),
//           );
//         }

//         if (index == 0) {
//           return _buildSectionHeader(
//             'Conversations',
//             Icons.forum_outlined,
//             isDark,
//           );
//         }

//         final conversation = sorted[index - 1];
//         return ChatConversationTile(
//           conversation: conversation,
//           isDark: isDark,
//           onTap: () => onConversationTap(conversation),
//           onLongPress: () => onConversationLongPress(conversation),
//           onDelete: onDelete != null ? () => onDelete!(conversation.id) : null,
//           onArchive: onArchive != null
//               ? () => onArchive!(conversation.id)
//               : null,
//           onPin: onPin != null ? () => onPin!(conversation.id) : null,
//           onMute: onMute != null ? () => onMute!(conversation.id) : null,
//           onMarkRead: onMarkRead != null
//               ? () => onMarkRead!(conversation.id)
//               : null,
//         );
//       },
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 14,
//             color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             title.toUpperCase(),
//             style: TextStyle(
//               color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 1.2,
//               fontFamily: 'Arimo',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
