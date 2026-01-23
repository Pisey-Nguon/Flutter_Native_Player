import 'package:flutter/material.dart';
import 'package:flutter_native_player/controls/player_controls_theme.dart';
import 'package:flutter_native_player/flutter_native_player_controller.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/quality_model.dart';

/// Pre-built minimal controls with just play/pause
class MinimalControls extends StatelessWidget {
  final FlutterNativePlayerController controller;
  final PlaybackState playbackState;
  final DurationState? durationState;
  final PlayerControlsTheme? theme;

  const MinimalControls({
    Key? key,
    required this.controller,
    required this.playbackState,
    required this.durationState,
    this.theme,
  }) : super(key: key);

  IconData _getIcon() {
    switch (playbackState) {
      case PlaybackState.play:
        return Icons.pause;
      case PlaybackState.finish:
        return Icons.replay;
      default:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? const PlayerControlsTheme();

    return GestureDetector(
      onTap: () => controller.playOrPause(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: effectiveTheme.backgroundColor.withValues(alpha: 0.3),
        child: Center(
          child: Icon(
            _getIcon(),
            color: effectiveTheme.iconColor,
            size: effectiveTheme.mainIconSize,
          ),
        ),
      ),
    );
  }
}

/// Pre-built basic controls with play/pause and progress bar
class BasicControls extends StatefulWidget {
  final FlutterNativePlayerController controller;
  final PlaybackState playbackState;
  final DurationState? durationState;
  final PlayerControlsTheme? theme;

  const BasicControls({
    Key? key,
    required this.controller,
    required this.playbackState,
    required this.durationState,
    this.theme,
  }) : super(key: key);

  @override
  State<BasicControls> createState() => _BasicControlsState();
}

class _BasicControlsState extends State<BasicControls> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;
  double? _seekTarget;

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  void didUpdateWidget(BasicControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the controller has caught up to our seek target
    if (_seekTarget != null && !_isDragging) {
      final currentProgress = (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
      // If we're within 500ms of the target, consider the seek complete
      if ((currentProgress - _seekTarget!).abs() < 500) {
        _seekTarget = null;
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  IconData _getIcon() {
    switch (widget.playbackState) {
      case PlaybackState.play:
        return Icons.pause;
      case PlaybackState.finish:
        return Icons.replay;
      default:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? const PlayerControlsTheme();

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: effectiveTheme.animationDuration,
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  effectiveTheme.backgroundColor,
                  Colors.transparent,
                  Colors.transparent,
                  effectiveTheme.backgroundColor,
                ],
              ),
            ),
            child: Stack(
              children: [
    
                // Center play/pause button
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(_getIcon()),
                    iconSize: effectiveTheme.mainIconSize,
                    color: effectiveTheme.iconColor,
                    onPressed: () => widget.controller.playOrPause(),
                  ),
                ),
    
                // Bottom progress bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: effectiveTheme.primaryColor,
                              inactiveTrackColor: effectiveTheme.progressBarBackgroundColor,
                              thumbColor: effectiveTheme.primaryColor,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              trackHeight: effectiveTheme.progressBarHeight,
                            ),
                            child: Slider(
                              value: _getSliderValue(),
                              min: 0,
                              max: _getSliderMax(),
                              onChangeStart: (value) {
                                setState(() {
                                  _isDragging = true;
                                  _dragValue = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() => _dragValue = value);
                              },
                              onChangeEnd: (value) {
                                setState(() {
                                  _isDragging = false;
                                  _seekTarget = value;
                                });
                                widget.controller.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_getCurrentProgress()),
                                style: effectiveTheme.timeTextStyle ??
                                    TextStyle(
                                      color: effectiveTheme.textColor,
                                      fontSize: 12,
                                    ),
                              ),
                              Text(
                                _formatDuration(widget.durationState?.total),
                                style: effectiveTheme.timeTextStyle ??
                                    TextStyle(
                                      color: effectiveTheme.textColor,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getSliderValue() {
    final max = _getSliderMax();
    double value;
    if (_isDragging) {
      value = _dragValue;
    } else if (_seekTarget != null) {
      value = _seekTarget!;
    } else {
      value = (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
    }
    return value.clamp(0.0, max);
  }

  double _getSliderMax() {
    final max = (widget.durationState?.total?.inMilliseconds ?? 0).toDouble();
    return max > 0 ? max : 1.0;
  }

  Duration? _getCurrentProgress() {
    if (_isDragging) {
      return Duration(milliseconds: _dragValue.toInt());
    }
    if (_seekTarget != null) {
      return Duration(milliseconds: _seekTarget!.toInt());
    }
    return widget.durationState?.progress;
  }
}

/// Pre-built full controls with all features: play/pause, seek, speed, quality, subtitles
class FullControls extends StatefulWidget {
  final FlutterNativePlayerController controller;
  final PlaybackState playbackState;
  final DurationState? durationState;
  final PlayerControlsTheme? theme;
  final bool showQualitySelector;
  final bool showSpeedSelector;
  final bool showSubtitleSelector;

  const FullControls({
    Key? key,
    required this.controller,
    required this.playbackState,
    required this.durationState,
    this.theme,
    this.showQualitySelector = true,
    this.showSpeedSelector = true,
    this.showSubtitleSelector = true,
  }) : super(key: key);

  @override
  State<FullControls> createState() => _FullControlsState();
}

class _FullControlsState extends State<FullControls> {
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;
  double? _seekTarget;

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  void didUpdateWidget(FullControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the controller has caught up to our seek target
    if (_seekTarget != null && !_isDragging) {
      final currentProgress = (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
      // If we're within 500ms of the target, consider the seek complete
      if ((currentProgress - _seekTarget!).abs() < 500) {
        _seekTarget = null;
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  IconData _getIcon() {
    switch (widget.playbackState) {
      case PlaybackState.play:
        return Icons.pause;
      case PlaybackState.finish:
        return Icons.replay;
      default:
        return Icons.play_arrow;
    }
  }

  void _showQualitySelector(BuildContext context) {
    final effectiveTheme = widget.theme ?? const PlayerControlsTheme();
    final qualities = widget.controller.getAvailableQualities();
    if (qualities.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Quality',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...qualities.map(
              (quality) => ListTile(
                leading: quality.urlQuality == widget.controller.currentQualityUrl
                    ? Icon(Icons.check, color: effectiveTheme.primaryColor)
                    : const SizedBox(width: 24),
                title: Text(_getQualityLabel(quality)),
                onTap: () {
                  widget.controller.changeQuality(quality);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQualityLabel(QualityModel quality) {
    if (quality.height == 0) return 'Auto';
    return '${quality.height}p';
  }

  void _showSpeedSelector(BuildContext context) {
    final effectiveTheme = widget.theme ?? const PlayerControlsTheme();
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Playback Speed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...speeds.map(
              (speed) => ListTile(
                leading: speed == widget.controller.currentSpeed
                    ? Icon(Icons.check, color: effectiveTheme.primaryColor)
                    : const SizedBox(width: 24),
                title: Text('${speed}x'),
                onTap: () {
                  widget.controller.setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubtitleSelector(BuildContext context) {
    final effectiveTheme = widget.theme ?? const PlayerControlsTheme();
    final subtitles = widget.controller.getAvailableSubtitles();
    if (subtitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subtitles available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Subtitle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: widget.controller.currentSubtitle == null
                  ? Icon(Icons.check, color: effectiveTheme.primaryColor)
                  : const SizedBox(width: 24),
              title: const Text('Off'),
              onTap: () {
                widget.controller.disableSubtitle();
                Navigator.pop(context);
              },
            ),
            ...subtitles.map(
              (subtitle) => ListTile(
                leading: subtitle.name == widget.controller.currentSubtitle?.name
                    ? Icon(Icons.check, color: effectiveTheme.primaryColor)
                    : const SizedBox(width: 24),
                title: Text(subtitle.name ?? 'Unknown'),
                onTap: () {
                  widget.controller.changeSubtitle(subtitle);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? const PlayerControlsTheme();

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: effectiveTheme.animationDuration,
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  effectiveTheme.backgroundColor,
                  Colors.transparent,
                  Colors.transparent,
                  effectiveTheme.backgroundColor,
                ],
              ),
            ),
            child: Column(
              children: [
                // Top bar with settings
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.showSubtitleSelector)
                        IconButton(
                          icon: Icon(Icons.subtitles, color: effectiveTheme.iconColor),
                          onPressed: () => _showSubtitleSelector(context),
                        ),
                      if (widget.showSpeedSelector)
                        IconButton(
                          icon: Icon(Icons.speed, color: effectiveTheme.iconColor),
                          onPressed: () => _showSpeedSelector(context),
                        ),
                      if (widget.showQualitySelector)
                        IconButton(
                          icon: Icon(Icons.high_quality, color: effectiveTheme.iconColor),
                          onPressed: () => _showQualitySelector(context),
                        ),
                    ],
                  ),
                ),
                // Center controls
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: effectiveTheme.secondaryIconSize,
                        color: effectiveTheme.iconColor,
                        onPressed: () => widget.controller.seekBackward(),
                      ),
                      IconButton(
                        icon: Icon(_getIcon()),
                        iconSize: effectiveTheme.mainIconSize,
                        color: effectiveTheme.iconColor,
                        onPressed: () => widget.controller.playOrPause(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        iconSize: effectiveTheme.secondaryIconSize,
                        color: effectiveTheme.iconColor,
                        onPressed: () => widget.controller.seekForward(),
                      ),
                    ],
                  ),
                ),
                // Bottom progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: effectiveTheme.primaryColor,
                          inactiveTrackColor: effectiveTheme.progressBarBackgroundColor,
                          thumbColor: effectiveTheme.primaryColor,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          trackHeight: effectiveTheme.progressBarHeight,
                        ),
                        child: Slider(
                          value: _getSliderValue(),
                          min: 0,
                          max: _getSliderMax(),
                          onChangeStart: (value) {
                            setState(() {
                              _isDragging = true;
                              _dragValue = value;
                            });
                          },
                          onChanged: (value) {
                            setState(() => _dragValue = value);
                          },
                          onChangeEnd: (value) {
                            setState(() {
                              _isDragging = false;
                              _seekTarget = value;
                            });
                            widget.controller.seekTo(
                              Duration(milliseconds: value.toInt()),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_getCurrentProgress()),
                            style: effectiveTheme.timeTextStyle ??
                                TextStyle(
                                  color: effectiveTheme.textColor,
                                  fontSize: 12,
                                ),
                          ),
                          Text(
                            _formatDuration(widget.durationState?.total),
                            style: effectiveTheme.timeTextStyle ??
                                TextStyle(
                                  color: effectiveTheme.textColor,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getSliderValue() {
    final max = _getSliderMax();
    double value;
    if (_isDragging) {
      value = _dragValue;
    } else if (_seekTarget != null) {
      value = _seekTarget!;
    } else {
      value = (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
    }
    return value.clamp(0.0, max);
  }

  double _getSliderMax() {
    final max = (widget.durationState?.total?.inMilliseconds ?? 0).toDouble();
    return max > 0 ? max : 1.0;
  }

  Duration? _getCurrentProgress() {
    if (_isDragging) {
      return Duration(milliseconds: _dragValue.toInt());
    }
    if (_seekTarget != null) {
      return Duration(milliseconds: _seekTarget!.toInt());
    }
    return widget.durationState?.progress;
  }
}
