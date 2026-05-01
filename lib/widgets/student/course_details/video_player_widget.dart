import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/materials/course_material_model.dart';

class VideoPlayerWidget extends StatefulWidget {
  final dynamic courseId;
  final CourseMaterialModel material;
  final bool enableEmbeddedPlayer;

  const VideoPlayerWidget({
    super.key,
    required this.courseId,
    required this.material,
    this.enableEmbeddedPlayer = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _hasTrackedView = false;

  String? get _youtubeVideoId => widget.material.youtubeVideoId?.trim().isNotEmpty == true
      ? widget.material.youtubeVideoId!.trim()
      : null;

  String? get _fallbackUrl {
    final external = widget.material.externalUrl?.trim();
    if (external != null && external.isNotEmpty) {
      return external;
    }

    final directUrl = widget.material.url?.trim();
    if (directUrl != null && directUrl.isNotEmpty) {
      return directUrl;
    }

    return null;
  }

  String? get _browserUrl {
    final videoId = _youtubeVideoId;
    if (videoId != null) {
      return 'https://www.youtube.com/watch?v=$videoId';
    }
    return _fallbackUrl;
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material.materialId != widget.material.materialId) {
      _hasTrackedView = false;
    }
  }

  void _recordView() {
    if (_hasTrackedView) {
      return;
    }
    _hasTrackedView = true;

    try {
      context.read<MaterialViewerBloc>().add(
        PlayVideo(courseId: widget.courseId, material: widget.material),
      );
    } catch (_) {
      // Allow rendering without a MaterialViewerBloc in edge previews.
    }
  }

  Future<void> _openInBrowser() async {
    final browserUrl = _browserUrl;
    if (browserUrl == null || browserUrl.isEmpty) {
      return;
    }
    await launchUrl(
      Uri.parse(browserUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    late final Widget content;

    if (!widget.enableEmbeddedPlayer) {
      content = _buildUnavailableState(context, l10n);
    } else {
      final youtubeVideoId = _youtubeVideoId;
      if (youtubeVideoId != null) {
        content = _YoutubeInlinePlayer(
        key: ValueKey<String>('youtube_${widget.material.materialId}_$youtubeVideoId'),
        videoId: youtubeVideoId,
        onReady: _recordView,
        onOpenInBrowser: _openInBrowser,
        openLabel: l10n.open,
        unavailableBuilder: (_) => _buildUnavailableState(context, l10n),
        );
      } else {
        final fallbackUrl = _fallbackUrl;
        if (fallbackUrl != null) {
          content = _ExternalVideoWebView(
        key: ValueKey<String>('external_${widget.material.materialId}_$fallbackUrl'),
        url: fallbackUrl,
        onReady: _recordView,
        unavailableBuilder: (_) => _buildUnavailableState(context, l10n),
          );
        } else {
          content = _buildUnavailableState(context, l10n);
        }
      }
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: content,
    );
  }

  Widget _buildUnavailableState(BuildContext context, AppLocalizations l10n) {
    return ColoredBox(
      color: const Color(0xFF111827),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.ondemand_video_rounded,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.studentCourseDetailVideoPreviewUnavailable,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _buildActionChip(
                icon: Icons.open_in_new_rounded,
                label: l10n.open,
                onTap: _openInBrowser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YoutubeInlinePlayer extends StatefulWidget {
  final String videoId;
  final VoidCallback onReady;
  final VoidCallback onOpenInBrowser;
  final String openLabel;
  final WidgetBuilder unavailableBuilder;

  const _YoutubeInlinePlayer({
    super.key,
    required this.videoId,
    required this.onReady,
    required this.onOpenInBrowser,
    required this.openLabel,
    required this.unavailableBuilder,
  });

  @override
  State<_YoutubeInlinePlayer> createState() => _YoutubeInlinePlayerState();
}

class _YoutubeInlinePlayerState extends State<_YoutubeInlinePlayer> {
  late final YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFullscreenPlayer() async {
    final position = _controller.value.position;
    final wasPlaying = _controller.value.isPlaying;
    _controller.pause();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _YoutubeFullscreenPlayerScreen(
          videoId: widget.videoId,
          startAt: position,
          autoPlay: wasPlaying,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        bottomActions: <Widget>[
          const CurrentPosition(),
          const SizedBox(width: 8),
          Expanded(
            child: ProgressBar(
              isExpanded: true,
              colors: const ProgressBarColors(
                playedColor: Color(0xFF2563EB),
                handleColor: Color(0xFF60A5FA),
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
          const RemainingDuration(),
          const PlaybackSpeedButton(),
          IconButton(
            onPressed: _openFullscreenPlayer,
            icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
            tooltip: 'Fullscreen',
          ),
        ],
        progressIndicatorColor: Colors.white,
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF2563EB),
          handleColor: Color(0xFF60A5FA),
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
        onReady: () {
          if (!mounted) {
            return;
          }
          setState(() => _isReady = true);
          widget.onReady();
        },
      ),
      builder: (context, player) {
        if (_controller.value.hasError) {
          return Stack(
            fit: StackFit.expand,
            children: [
              widget.unavailableBuilder(context),
              Positioned(
                bottom: 18,
                right: 18,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onOpenInBrowser,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.openLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            player,
            if (!_isReady)
              const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _YoutubeFullscreenPlayerScreen extends StatefulWidget {
  final String videoId;
  final Duration startAt;
  final bool autoPlay;

  const _YoutubeFullscreenPlayerScreen({
    required this.videoId,
    required this.startAt,
    required this.autoPlay,
  });

  @override
  State<_YoutubeFullscreenPlayerScreen> createState() =>
      _YoutubeFullscreenPlayerScreenState();
}

class _YoutubeFullscreenPlayerScreenState
    extends State<_YoutubeFullscreenPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
        startAt: widget.startAt.inSeconds,
      ),
    );
    _enterFullscreenMode();
  }

  Future<void> _enterFullscreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitFullscreenMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        bottomActions: <Widget>[
          const CurrentPosition(),
          const SizedBox(width: 8),
          Expanded(
            child: ProgressBar(
              isExpanded: true,
              colors: const ProgressBarColors(
                playedColor: Color(0xFF2563EB),
                handleColor: Color(0xFF60A5FA),
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
          const RemainingDuration(),
          const PlaybackSpeedButton(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
            tooltip: 'Exit fullscreen',
          ),
        ],
        progressIndicatorColor: Colors.white,
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF2563EB),
          handleColor: Color(0xFF60A5FA),
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(child: Center(child: player)),
              Positioned(
                top: 18,
                left: 18,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(18),
                      child: Ink(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExternalVideoWebView extends StatefulWidget {
  final String url;
  final VoidCallback onReady;
  final WidgetBuilder unavailableBuilder;

  const _ExternalVideoWebView({
    super.key,
    required this.url,
    required this.onReady,
    required this.unavailableBuilder,
  });

  @override
  State<_ExternalVideoWebView> createState() => _ExternalVideoWebViewState();
}

class _ExternalVideoWebViewState extends State<_ExternalVideoWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasRecorded = false;

  @override
  void initState() {
    super.initState();
    _buildController();
  }

  void _buildController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!_hasRecorded) {
              _hasRecorded = true;
              widget.onReady();
            }
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _hasError) {
      return widget.unavailableBuilder(context);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
      ],
    );
  }
}
