import 'package:flutter/material.dart';

import '../../../models/materials/material_bundle_model.dart';

class BundleViewer extends StatelessWidget {
  final MaterialBundleModel bundle;
  final bool isDark;

  const BundleViewer({super.key, required this.bundle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.layers_outlined,
                size: 18,
                color: Color(0xFF155DFC),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bundle.baseTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${bundle.totalMaterials} materials',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (bundle.primaryVideo != null) ...[
            const SizedBox(height: 10),
            Text(
              'Primary video: ${bundle.primaryVideo!.title}',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF334155),
                fontSize: 12,
              ),
            ),
          ],
          if (bundle.companionDocs.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...bundle.companionDocs.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: Color(0xFF0369A1),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doc.title,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF475569),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
