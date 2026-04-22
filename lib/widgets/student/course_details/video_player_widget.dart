import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_event.dart';
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
  YoutubePlayerController? _controller;
  bool _hasTrackedPlay = false;
  String? _playerError;

  String? get _videoId => widget.material.youtubeVideoId;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material.materialId != widget.material.materialId ||
        oldWidget.enableEmbeddedPlayer != widget.enableEmbeddedPlayer) {
      _controller?.dispose();
      _controller = null;
      _hasTrackedPlay = false;
      _playerError = null;
      _initializeController();
    }
  }

  void _initializeController() {
    final videoId = _videoId;
    if (!widget.enableEmbeddedPlayer || videoId == null || videoId.isEmpty) {
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;
    if (!_hasTrackedPlay && value.isPlaying) {
      _hasTrackedPlay = true;
      _recordView();
    }

    if (value.hasError && mounted) {
      setState(() {
        _playerError = 'Video unavailable — contact instructor';
      });
    }
  }

  void _recordView() {
    try {
      context.read<MaterialViewerBloc>().add(
        PlayVideo(courseId: widget.courseId, material: widget.material),
      );
    } catch (_) {
      // Allow rendering without a MaterialViewerBloc in edge previews.
    }
  }

  void _onEnterFullscreen() {
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _onExitFullscreen() {
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _onExitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.material.title, style: titleStyle),
        const SizedBox(height: 12),
        _buildPlayerBody(context),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () {
                _controller?.play();
                _recordView();
              },
              tooltip: 'Play',
            ),
            IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: _controller == null ? null : _controller!.pause,
              tooltip: 'Pause',
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen_rounded),
              onPressed: _controller == null
                  ? null
                  : _controller!.toggleFullScreenMode,
              tooltip: 'Fullscreen',
            ),
          ],
        ),
        if (_playerError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _playerError!,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_videoId == null || _videoId!.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Video unavailable — contact instructor',
              style: TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerBody(BuildContext context) {
    if (!widget.enableEmbeddedPlayer) {
      return _buildPlaceholder(
        context,
        'Embedded player disabled in test mode.',
      );
    }

    final controller = _controller;
    if (controller == null || _videoId == null || _videoId!.isEmpty) {
      return _buildPlaceholder(context, 'Video preview is not available.');
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: _onEnterFullscreen,
      onExitFullScreen: _onExitFullscreen,
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF155DFC),
      ),
      builder: (context, player) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(aspectRatio: 16 / 9, child: player),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1F2937)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.ondemand_video_rounded, size: 36),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
