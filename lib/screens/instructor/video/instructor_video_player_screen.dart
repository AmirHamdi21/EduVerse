import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/instructor/course_management/course_management_colors.dart';

class InstructorVideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String courseName;
  final String videoTitle;

  const InstructorVideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.courseName,
    this.videoTitle = 'Course Video',
  });

  @override
  State<InstructorVideoPlayerScreen> createState() =>
      _InstructorVideoPlayerScreenState();
}

class _InstructorVideoPlayerScreenState
    extends State<InstructorVideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  bool _isEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );
    _controller.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    final state = _controller.value.playerState;
    final ended = state == PlayerState.ended;
    if (ended != _isEnded) {
      if (mounted) {
        setState(() {
          _isEnded = ended;
        });
      }
    }
  }

  void _replay() {
    _controller.seekTo(Duration.zero);
    _controller.play();
  }

  Future<void> _restoreSystemUi() async {
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
    _controller.removeListener(_onPlayerStateChanged);
    _controller.dispose();
    _restoreSystemUi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: CMColors.primaryLight,
            progressColors: const ProgressBarColors(
              playedColor: CMColors.primary,
              handleColor: CMColors.accent,
              bufferedColor: CMColors.primaryLighter,
              backgroundColor: Colors.black26,
            ),
            onEnded: (meta) {
              if (mounted) {
                setState(() {
                  _isEnded = true;
                });
              }
            },
          ),
          builder: (context, player) {
            return Scaffold(
              backgroundColor: CMColors.bg(isDark),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: CMColors.cardColor(isDark),
                surfaceTintColor: Colors.transparent,
                foregroundColor: CMColors.text(isDark),
                titleSpacing: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CMColors.text(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CMColors.textSub(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Stack(
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: CMColors.cardColor(isDark),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: CMColors.borderColor(isDark),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.24 : 0.08,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AspectRatio(aspectRatio: 16 / 9, child: player),
                      ),
                      if (_isEnded)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _replay,
                                      borderRadius: BorderRadius.circular(32),
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        child: const Icon(
                                          Icons.replay_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to replay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CMColors.cardColor(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CMColors.borderColor(isDark)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: CMColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Now playing from ${widget.courseName}',
                            style: TextStyle(
                              color: CMColors.text(isDark),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
