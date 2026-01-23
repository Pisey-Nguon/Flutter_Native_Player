import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/flutter_native_player_controller.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle_resource.dart';
import 'package:flutter_native_player/model/quality_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Native Player Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Native Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BasicPlayerExample()),
              ),
              child: const Text('Basic Player (No Controls)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomControlsExample(),
                ),
              ),
              child: const Text('Custom Controls Example'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExternalControllerExample(),
                ),
              ),
              child: const Text('External Controller Example'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 1: Basic player with no controls (just the video)
class BasicPlayerExample extends StatelessWidget {
  const BasicPlayerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Player')),
      body: Center(
        child: FlutterNativePlayer(
          playerResource: PlayerResource(
            videoUrl:
                "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8",
          ),
          playWhenReady: true,
          width: double.infinity,
          height: 250,
        ),
      ),
    );
  }
}

/// Example 2: Player with custom overlay controls
class CustomControlsExample extends StatefulWidget {
  const CustomControlsExample({Key? key}) : super(key: key);

  @override
  State<CustomControlsExample> createState() => _CustomControlsExampleState();
}

class _CustomControlsExampleState extends State<CustomControlsExample> {
  String videoUrl =
      "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8";

  final playerSubtitleResource = [
    PlayerSubtitleResource(
      language: "English",
      subtitleUrl:
          "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BEnglish%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
    ),
    PlayerSubtitleResource(
      language: "Japanese",
      subtitleUrl:
          "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BJapanese%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
    ),
  ];

  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Controls')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FlutterNativePlayer(
              playerResource: PlayerResource(
                videoUrl: videoUrl,
                playerSubtitleResources: playerSubtitleResource,
              ),
              playWhenReady: true,
              width: double.infinity,
              height: 250,
              overlayBuilder:
                  (context, controller, playbackState, durationState) {
                    return CustomPlayerControls(
                      controller: controller,
                      playbackState: playbackState,
                      durationState: durationState,
                      showControls: _showControls,
                      onToggleControls: () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                      },
                    );
                  },
              loadingBuilder: (context, controller) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This example shows custom controls built using the overlayBuilder. '
                'Tap the video to toggle controls visibility.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom player controls widget
class CustomPlayerControls extends StatefulWidget {
  final FlutterNativePlayerController controller;
  final PlaybackState playbackState;
  final DurationState? durationState;
  final bool showControls;
  final VoidCallback onToggleControls;

  const CustomPlayerControls({
    Key? key,
    required this.controller,
    required this.playbackState,
    required this.durationState,
    required this.showControls,
    required this.onToggleControls,
  }) : super(key: key);

  @override
  State<CustomPlayerControls> createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  double? _lastSeekValue;

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

  IconData _getPlayPauseIcon() {
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
    final qualities = widget.controller.getAvailableQualities();
    if (qualities.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
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
                      ? const Icon(Icons.check, color: Colors.blue)
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
      ),
    );
  }

  String _getQualityLabel(QualityModel quality) {
    if (quality.height == 0) return 'Auto';
    return '${quality.height}p';
  }

  void _showSpeedSelector(BuildContext context) {
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
                    ? const Icon(Icons.check, color: Colors.blue)
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
    final subtitles = widget.controller.getAvailableSubtitles();
    if (subtitles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No subtitles available')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
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
              ...subtitles.map(
                (subtitle) => ListTile(
                  leading: subtitle.name == widget.controller.currentSubtitle?.name
                      ? const Icon(Icons.check, color: Colors.blue)
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggleControls,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: widget.showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !widget.showControls,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black54,
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top bar with settings
                    Padding(
                      padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.subtitles, color: Colors.white),
                          onPressed: () => _showSubtitleSelector(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.speed, color: Colors.white),
                          onPressed: () => _showSpeedSelector(context),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.high_quality,
                            color: Colors.white,
                          ),
                          onPressed: () => _showQualitySelector(context),
                        ),
                      ],
                    ),
                  ),
              
               
              
                  // Bottom bar with progress
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        // Progress slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blue,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.blue,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            trackHeight: 3,
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
                              // Only update if changed by at least 100ms to prevent jitter
                              if ((_dragValue - value).abs() > 100) {
                                setState(() {
                                  _dragValue = value;
                                });
                              }
                            },
                            onChangeEnd: (value) {
                              setState(() {
                                _isDragging = false;
                                _lastSeekValue = value;
                              });
                              widget.controller.seekTo(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                        ),
                        // Time labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_getCurrentProgress()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(widget.durationState?.total),
                              style: const TextStyle(
                                color: Colors.white,
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
                 // Center play/pause button
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: 40,
                        color: Colors.white,
                        onPressed: () => widget.controller.seekBackward(),
                      ),
                      Opacity(
                        opacity: widget.playbackState != PlaybackState.loading ? 1.0 : 0.0,
                        child: IconButton(
                          icon: Icon(_getPlayPauseIcon()),
                          iconSize: 60,
                          color: Colors.white,
                          onPressed: () => widget.controller.playOrPause(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        iconSize: 40,
                        color: Colors.white,
                        onPressed: () => widget.controller.seekForward(),
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  double _getSliderValue() {
    if (_isDragging) {
      return _dragValue;
    }
    // If we just seeked, keep showing that value until progress catches up
    if (_lastSeekValue != null) {
      final currentProgress = (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
      // Check if progress has caught up (within 500ms threshold)
      if ((currentProgress - _lastSeekValue!).abs() < 500) {
        _lastSeekValue = null;
      } else {
        return _lastSeekValue!;
      }
    }
    if((widget.durationState?.progress.inMilliseconds ?? 0) > (widget.durationState?.total?.inMilliseconds ?? 0)) {
      return (widget.durationState?.total?.inMilliseconds ?? 0).toDouble();
    }
    return (widget.durationState?.progress.inMilliseconds ?? 0).toDouble();
  }

  double _getSliderMax() {
    final max = (widget.durationState?.total?.inMilliseconds ?? 0).toDouble();
    return max > 0 ? max : 1.0;
  }

  Duration? _getCurrentProgress() {
    if (_isDragging) {
      return Duration(milliseconds: _dragValue.toInt());
    }
    if (_lastSeekValue != null) {
      return Duration(milliseconds: _lastSeekValue!.toInt());
    }
    return widget.durationState?.progress;
  }
}

/// Example 3: Using external controller
class ExternalControllerExample extends StatefulWidget {
  const ExternalControllerExample({Key? key}) : super(key: key);

  @override
  State<ExternalControllerExample> createState() =>
      _ExternalControllerExampleState();
}

class _ExternalControllerExampleState extends State<ExternalControllerExample> {
  final _controller = FlutterNativePlayerController();

  String videoUrl =
      "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8";

  PlaybackState _playbackState = PlaybackState.loading;
  DurationState? _durationState;

  @override
  void initState() {
    super.initState();

    // Listen to state changes
    _controller.playbackStateStream.listen((state) {
      if (mounted) {
        setState(() => _playbackState = state);
      }
    });

    _controller.durationStateStream.listen((state) {
      if (mounted) {
        setState(() => _durationState = state);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('External Controller')),
      body: Column(
        children: [
          // Video player without overlay (bare video)
          FlutterNativePlayer(
            playerResource: PlayerResource(videoUrl: videoUrl),
            controller: _controller,
            playWhenReady: true,
            width: double.infinity,
            height: 250,
          ),

          // External controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status display
                Text(
                  'Status: ${_playbackState.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDuration(_durationState?.progress)} / '
                  '${_formatDuration(_durationState?.total)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Progress bar
                LinearProgressIndicator(
                  value: _getProgress(),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 24),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _controller.seekBackward(),
                      icon: const Icon(Icons.replay_10),
                      label: const Text('-10s'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _controller.playOrPause(),
                      icon: Icon(
                        _playbackState == PlaybackState.play
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        _playbackState == PlaybackState.play ? 'Pause' : 'Play',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _controller.seekForward(),
                      icon: const Icon(Icons.forward_10),
                      label: const Text('+10s'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Speed controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => _controller.setPlaybackSpeed(0.5),
                      child: const Text('0.5x'),
                    ),
                    OutlinedButton(
                      onPressed: () => _controller.setPlaybackSpeed(1.0),
                      child: const Text('1x'),
                    ),
                    OutlinedButton(
                      onPressed: () => _controller.setPlaybackSpeed(1.5),
                      child: const Text('1.5x'),
                    ),
                    OutlinedButton(
                      onPressed: () => _controller.setPlaybackSpeed(2.0),
                      child: const Text('2x'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Seek controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _controller.seekTo(const Duration(seconds: 0)),
                      child: const Text('Start'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _controller.seekTo(const Duration(seconds: 30)),
                      child: const Text('0:30'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _controller.seekTo(const Duration(minutes: 1)),
                      child: const Text('1:00'),
                    ),
                    TextButton(
                      onPressed: () =>
                          _controller.seekTo(const Duration(minutes: 2)),
                      child: const Text('2:00'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getProgress() {
    if (_durationState == null) return 0.0;
    final total = _durationState!.total?.inMilliseconds ?? 0;
    if (total == 0) return 0.0;
    return _durationState!.progress.inMilliseconds / total;
  }
}
