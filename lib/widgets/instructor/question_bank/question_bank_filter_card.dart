import 'package:flutter/material.dart';

class QuestionBankFilterCard extends StatelessWidget {
  const QuestionBankFilterCard({
    super.key,
    required this.searchController,
    required this.searchLabel,
    required this.onSearchChanged,
    required this.children,
  });

  final TextEditingController searchController;
  final String searchLabel;
  final ValueChanged<String> onSearchChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              labelText: searchLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: children),
          ],
        ],
      ),
    );
  }
}
