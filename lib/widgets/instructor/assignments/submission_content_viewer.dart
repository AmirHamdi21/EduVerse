import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/assignments/assignment_submission_model.dart';

class SubmissionContentViewer extends StatelessWidget {
  const SubmissionContentViewer({super.key, required this.submission});

  final AssignmentSubmissionModel submission;

  @override
  Widget build(BuildContext context) {
    final hasText = submission.submissionText?.trim().isNotEmpty == true;
    final hasLink = submission.submissionLink?.trim().isNotEmpty == true;
    final hasFile = submission.driveFile != null;

    if (!hasText && !hasLink && !hasFile) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No content available for this submission.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Submission Content',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (hasText) ...<Widget>[
              const Text('Text', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              MarkdownBody(data: submission.submissionText!.trim()),
              const SizedBox(height: 10),
            ],
            if (hasLink) ...<Widget>[
              const Text('Link', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _openUrl(submission.submissionLink!),
                child: Text(
                  submission.submissionLink!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (hasFile) ...<Widget>[
              const Text('File', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(submission.driveFile!.fileName),
              const SizedBox(height: 8),
              _FileActions(file: submission.driveFile!),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _FileActions extends StatefulWidget {
  const _FileActions({required this.file});

  final dynamic file;

  @override
  State<_FileActions> createState() => _FileActionsState();
}

class _FileActionsState extends State<_FileActions> {
  bool _fallbackToDownload = false;

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final fileSize = file.fileSize;
    final isHeavy = fileSize != null && fileSize > 50 * 1024 * 1024;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () {
            if (isHeavy || _fallbackToDownload) {
              _openUrl(file.downloadUrl);
              return;
            }
            _showPreview(
              file.iframeUrl.toString().trim().isNotEmpty
                  ? file.iframeUrl
                  : file.webViewLink,
            );
          },
          icon: Icon(
            isHeavy ? Icons.download_rounded : Icons.visibility_rounded,
          ),
          label: Text(isHeavy ? 'Download' : 'Preview'),
        ),
        TextButton.icon(
          onPressed: () => _openUrl(file.downloadUrl),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download'),
        ),
      ],
    );
  }

  Future<void> _showPreview(String url) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 900,
          height: 620,
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Expanded(
                child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onWebResourceError: (_) {
                          if (mounted) {
                            setState(() => _fallbackToDownload = true);
                          }
                          Navigator.of(context).pop();
                          _openUrl(widget.file.downloadUrl);
                        },
                      ),
                    )
                    ..loadRequest(Uri.parse(url)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
