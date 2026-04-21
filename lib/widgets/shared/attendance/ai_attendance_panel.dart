import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/attendance/ai_processing_result_model.dart';

class AiAttendancePanel extends StatelessWidget {
  final int? sessionId;
  final bool isReadOnly;
  final bool isLoading;
  final String? error;
  final AiProcessingResultModel? result;
  final File? selectedPhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback onRunAi;
  final VoidCallback onApplyResults;

  const AiAttendancePanel({
    super.key,
    required this.sessionId,
    required this.isReadOnly,
    required this.isLoading,
    required this.error,
    required this.result,
    required this.selectedPhoto,
    required this.onPickPhoto,
    required this.onRunAi,
    required this.onApplyResults,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sessionId == null
                ? 'Select a session first.'
                : 'Upload class photo and run AI matching.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: (isReadOnly || isLoading) ? null : onPickPhoto,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: selectedPhoto == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Pick Attendance Photo',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(selectedPhoto!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  (isReadOnly ||
                      isLoading ||
                      sessionId == null ||
                      selectedPhoto == null)
                  ? null
                  : onRunAi,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology_rounded),
              label: Text(isLoading ? 'Processing...' : 'Run AI Attendance'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB91C1C)),
              ),
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard('Detected', result!.detectedFacesCount ?? 0),
                const SizedBox(width: 8),
                _statCard('Matched', result!.matchedStudentsCount ?? 0),
                const SizedBox(width: 8),
                _statCard('Unknown', result!.unmatchedFacesCount ?? 0),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (isReadOnly || isLoading || !result!.isCompleted)
                    ? null
                    : onApplyResults,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: const Text('Apply AI Results'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
