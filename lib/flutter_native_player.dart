import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/controls/flutter_native_player_controls.dart';
import 'package:flutter_native_player/controls/player_controls_theme.dart';
import 'package:flutter_native_player/flutter_native_player_controller.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_drawer.dart';

import 'constant.dart';
import 'method_manager/playback_state.dart';

/// Signature for building custom overlay controls for the video player.
///
/// The [controller] provides full access to player functionality.
/// The [playbackState] indicates the current state (playing, paused, loading, etc.).
/// The [durationState] provides current position, buffered position, and total duration.
///
/// Example:
/// ```dart
/// FlutterNativePlayer(
///   playerResource: resource,
///   width: double.infinity,
///   height: 250,
///   overlayBuilder: (context, controller, playbackState, durationState) {
///     return Stack(
///       children: [
///         // Play/Pause button
///         Center(
///           child: IconButton(
///             icon: Icon(
///               playbackState == PlaybackState.play
///                   ? Icons.pause
///                   : Icons.play_arrow,
///               color: Colors.white,
///               size: 50,
///             ),
///             onPressed: () => controller.playOrPause(),
///           ),
///         ),
///         // Progress bar at bottom
///         Positioned(
///           bottom: 0,
///           left: 0,
///           right: 0,
///           child: LinearProgressIndicator(
///             value: durationState?.total?.inMilliseconds != 0
///               ? durationState?.progress.inMilliseconds /
///                 durationState!.total!.inMilliseconds
///               : 0,
///           ),
///         ),
///       ],
///     );
///   },
/// )
/// ```
typedef PlayerOverlayBuilder =
    Widget Function(
      BuildContext context,
      FlutterNativePlayerController controller,
      PlaybackState playbackState,
      DurationState? durationState,
    );

/// Signature for building a custom loading indicator.
typedef PlayerLoadingBuilder =
    Widget Function(
      BuildContext context,
      FlutterNativePlayerController controller,
    );

/// A widget that displays a native video player with full customization support.
///
/// This player uses platform-specific native video players (ExoPlayer on Android,
/// AVPlayer on iOS) for optimal performance.
///
/// ## Basic Usage
///
/// ```dart
/// FlutterNativePlayer(
///   playerResource: PlayerResource(videoUrl: 'https://example.com/video.m3u8'),
///   width: double.infinity,
///   height: 250,
/// )
/// ```
///
/// ## Custom Controls
///
/// You can provide your own UI controls using the [overlayBuilder] parameter:
///
/// ```dart
/// FlutterNativePlayer(
///   playerResource: resource,
///   width: double.infinity,
///   height: 250,
///   overlayBuilder: (context, controller, playbackState, durationState) {
///     return YourCustomControlsWidget(
///       controller: controller,
///       playbackState: playbackState,
///       durationState: durationState,
///     );
///   },
/// )
/// ```
///
/// ## Controller
///
/// Pass your own [FlutterNativePlayerController] to control the player externally:
///
/// ```dart
/// final controller = FlutterNativePlayerController();
///
/// // Later, control the player
/// controller.play();
/// controller.pause();
/// controller.seekTo(Duration(seconds: 30));
///
/// // In your widget tree
/// FlutterNativePlayer(
///   playerResource: resource,
///   controller: controller,
///   width: double.infinity,
///   height: 250,
/// )
/// ```
class FlutterNativePlayer extends StatefulWidget {
  /// The video resource containing URL and optional subtitles.
  final PlayerResource playerResource;

  /// Whether to start playing immediately when the video is ready.
  final bool playWhenReady;

  /// Width of the player widget.
  final double width;

  /// Height of the player widget.
  final double height;

  /// Optional controller for external player control.
  /// If not provided, an internal controller will be created.
  final FlutterNativePlayerController? controller;

  /// Builder for custom overlay controls.
  /// If not provided, no controls will be shown (bare video only).
  final PlayerOverlayBuilder? overlayBuilder;

  /// Builder for custom loading indicator.
  /// If not provided, a default circular progress indicator will be shown.
  final PlayerLoadingBuilder? loadingBuilder;

  /// Whether to show subtitles.
  final bool showSubtitles;

  /// Background color of the player.
  final Color backgroundColor;

  const FlutterNativePlayer({
    Key? key,
    required this.playerResource,
    this.playWhenReady = true,
    required this.width,
    required this.height,
    this.controller,
    this.overlayBuilder,
    this.loadingBuilder,
    this.showSubtitles = true,
    this.backgroundColor = Colors.black,
  }) : super(key: key);

  /// Factory constructor for minimal controls (just play/pause button).
  /// 
  /// This is the simplest way to add controls - perfect for basic use cases.
  /// 
  /// Example:
  /// ```dart
  /// FlutterNativePlayer.withMinimalControls(
  ///   playerResource: PlayerResource(videoUrl: url),
  ///   width: double.infinity,
  ///   height: 250,
  ///   theme: PlayerControlsTheme.dark(), // Easy theming!
  /// )
  /// ```
  factory FlutterNativePlayer.withMinimalControls({
    Key? key,
    required PlayerResource playerResource,
    bool playWhenReady = true,
    required double width,
    required double height,
    FlutterNativePlayerController? controller,
    PlayerControlsTheme? theme,
    bool showSubtitles = true,
    Color backgroundColor = Colors.black,
  }) {
    return FlutterNativePlayer(
      key: key,
      playerResource: playerResource,
      playWhenReady: playWhenReady,
      width: width,
      height: height,
      controller: controller,
      showSubtitles: showSubtitles,
      backgroundColor: backgroundColor,
      overlayBuilder: (context, controller, playbackState, durationState) {
        return MinimalControls(
          controller: controller,
          playbackState: playbackState,
          durationState: durationState,
          theme: theme,
        );
      },
    );
  }

  /// Factory constructor for basic controls (play/pause + progress bar).
  /// 
  /// Includes play/pause button and a progress slider with time labels.
  /// Perfect for most common video player needs.
  /// 
  /// Example:
  /// ```dart
  /// FlutterNativePlayer.withBasicControls(
  ///   playerResource: PlayerResource(videoUrl: url),
  ///   width: double.infinity,
  ///   height: 250,
  ///   theme: PlayerControlsTheme.brand(
  ///     primaryColor: Colors.purple,
  ///   ),
  /// )
  /// ```
  factory FlutterNativePlayer.withBasicControls({
    Key? key,
    required PlayerResource playerResource,
    bool playWhenReady = true,
    required double width,
    required double height,
    FlutterNativePlayerController? controller,
    PlayerControlsTheme? theme,
    bool showSubtitles = true,
    Color backgroundColor = Colors.black,
  }) {
    return FlutterNativePlayer(
      key: key,
      playerResource: playerResource,
      playWhenReady: playWhenReady,
      width: width,
      height: height,
      controller: controller,
      showSubtitles: showSubtitles,
      backgroundColor: backgroundColor,
      overlayBuilder: (context, controller, playbackState, durationState) {
        return BasicControls(
          controller: controller,
          playbackState: playbackState,
          durationState: durationState,
          theme: theme,
        );
      },
    );
  }

  /// Factory constructor for full controls (all features).
  /// 
  /// Includes play/pause, seek forward/backward, progress bar, quality selector,
  /// speed selector, and subtitle selector.
  /// 
  /// Example:
  /// ```dart
  /// FlutterNativePlayer.withFullControls(
  ///   playerResource: PlayerResource(
  ///     videoUrl: url,
  ///     playerSubtitleResources: subtitles,
  ///   ),
  ///   width: double.infinity,
  ///   height: 250,
  ///   showQualitySelector: true,
  ///   showSpeedSelector: true,
  ///   showSubtitleSelector: true,
  /// )
  /// ``theme: PlayerControlsTheme.brand(primaryColor: Colors.green),
  ///   showQualitySelector: true,
  ///   showSpeedSelector: true,
  ///   showSubtitleSelector: true,
  /// )
  /// ```
  factory FlutterNativePlayer.withFullControls({
    Key? key,
    required PlayerResource playerResource,
    bool playWhenReady = true,
    required double width,
    required double height,
    FlutterNativePlayerController? controller,
    PlayerControlsTheme? theme,
    bool showQualitySelector = true,
    bool showSpeedSelector = true,
    bool showSubtitleSelector = true,
    bool showSubtitles = true,
    Color backgroundColor = Colors.black,
  }) {
    return FlutterNativePlayer(
      key: key,
      playerResource: playerResource,
      playWhenReady: playWhenReady,
      width: width,
      height: height,
      controller: controller,
      showSubtitles: showSubtitles,
      backgroundColor: backgroundColor,
      overlayBuilder: (context, controller, playbackState, durationState) {
        return FullControls(
          controller: controller,
          playbackState: playbackState,
          durationState: durationState,
          theme: theme,
          showQualitySelector: showQualitySelector,
          showSpeedSelector: showSpeedSelector,
          showSubtitleSelector: showSubtitleSelector,
        );
      },
    );
  }

  @override
  State<FlutterNativePlayer> createState() => _FlutterNativePlayerState();
}

class _FlutterNativePlayerState extends State<FlutterNativePlayer>
    with WidgetsBindingObserver {
  late FlutterNativePlayerController _controller;
  bool _isInternalController = false;

  PlaybackState _playbackState = PlaybackState.loading;
  DurationState? _durationState;
  bool _isLoading = true;
  int _subtitleKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use provided controller or create internal one
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = FlutterNativePlayerController();
      _isInternalController = true;
    }

    // Initialize the controller
    _controller.initialize(
      playerResource: widget.playerResource,
      playWhenReady: widget.playWhenReady,
    );

    // Listen to state changes
    _controller.playbackStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _playbackState = state;
          _isLoading = state == PlaybackState.loading;
        });
      }
    });

    _controller.durationStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _durationState = state;
        });
      }
    });

    // Listen to subtitle changes to rebuild UI when subtitles are loaded
    _controller.subtitleStream.listen((subtitle) {
      if (mounted) {
        setState(() {
          _subtitleKey++;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAndroidPlatform(Map<String, dynamic> creationParams) {
    return PlatformViewLink(
      viewType: Constant.MP_VIEW_TYPE,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: Constant.MP_VIEW_TYPE,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  Widget _buildIOSPlatform(Map<String, dynamic> creationParams) {
    return UiKitView(
      viewType: Constant.MP_VIEW_TYPE,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _buildPlatformView() {
    final creationParams = {
      Constant.KEY_PLAYER_RESOURCE: playerResourceToJson(widget.playerResource),
      Constant.KEY_PLAY_WHEN_READY: widget.playWhenReady,
    };

    Widget platform;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platform = _buildAndroidPlatform(creationParams);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = _buildIOSPlatform(creationParams);
    } else {
      platform = const Center(
        child: Text(
          'Platform not supported',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      alignment: Alignment.topCenter,
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: platform,
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();

    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _controller);
    }

    // Default loading indicator
    return const Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubtitles() {
    if (!widget.showSubtitles) return const SizedBox.shrink();

    return PlayerKidSubtitlesDrawer(
      key: ValueKey('subtitle_$_subtitleKey'),
      subtitles: _controller.fetchHlsMasterPlaylist.subtitlesLines,
      currentPosition: _durationState?.progress,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildOverlay() {
    if (widget.overlayBuilder == null) return const SizedBox.shrink();

    return widget.overlayBuilder!(
      context,
      _controller,
      _playbackState,
      _durationState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          _buildPlatformView(),
          _buildSubtitles(),
          _buildOverlay(),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }
}
