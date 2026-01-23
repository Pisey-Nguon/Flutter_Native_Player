import 'dart:async';

import 'package:flutter_native_player/hls/fetch_hls_master_playlist.dart';
import 'package:flutter_native_player/method_manager/download_state.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_source.dart';

/// A controller that provides full control over the native video player.
///
/// Use this controller to interact with the player programmatically:
/// - Play, pause, seek
/// - Change playback speed
/// - Change video quality
/// - Control subtitles
/// - Monitor playback state and duration
///
/// Example:
/// ```dart
/// final controller = FlutterNativePlayerController();
///
/// // Listen to playback state changes
/// controller.playbackStateStream.listen((state) {
///   if (state == PlaybackState.play) {
///     print('Video is playing');
///   }
/// });
///
/// // Control playback
/// controller.play();
/// controller.pause();
/// controller.seekTo(Duration(seconds: 30));
/// ```
class FlutterNativePlayerController {
  late PlayerMethodManager _playerMethodManager;
  late FetchHlsMasterPlaylist _fetchHlsMasterPlaylist;
  bool _isInitialized = false;
  bool _isDisposed = false;

  final List<StreamSubscription> _subscriptions = [];

  final StreamController<PlaybackState> _playbackStateController =
      StreamController<PlaybackState>.broadcast();
  final StreamController<DurationState> _durationStateController =
      StreamController<DurationState>.broadcast();
  final StreamController<DownloadState> _downloadStateController =
      StreamController<DownloadState>.broadcast();
  final StreamController<double> _downloadProgressController =
      StreamController<double>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  final StreamController<PlayerKidSubtitlesSource?> _subtitleController =
      StreamController<PlayerKidSubtitlesSource?>.broadcast();

  PlaybackState _currentPlaybackState = PlaybackState.loading;
  DurationState? _currentDurationState;
  bool _isLoading = true;

  /// Stream of playback state changes (play, pause, loading, finish, etc.)
  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  /// Stream of duration state changes (current position, buffered, total duration)
  Stream<DurationState> get durationStateStream =>
      _durationStateController.stream;

  /// Stream of download state changes
  Stream<DownloadState> get downloadStateStream =>
      _downloadStateController.stream;

  /// Stream of download progress (0.0 to 100.0)
  Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  /// Stream of loading state changes
  Stream<bool> get loadingStream => _loadingController.stream;

  /// Stream of subtitle changes
  Stream<PlayerKidSubtitlesSource?> get subtitleStream =>
      _subtitleController.stream;

  /// Current playback state
  PlaybackState get playbackState => _currentPlaybackState;

  /// Current duration state (position, buffered, total)
  DurationState? get durationState => _currentDurationState;

  /// Whether the player is currently loading
  bool get isLoading => _isLoading;

  /// Whether the controller has been initialized
  bool get isInitialized => _isInitialized;

  /// Current playback position
  Duration get currentPosition =>
      _currentDurationState?.progress ?? Duration.zero;

  /// Total duration of the video
  Duration get totalDuration => _currentDurationState?.total ?? Duration.zero;

  /// Buffered duration
  Duration get bufferedDuration =>
      _currentDurationState?.buffered ?? Duration.zero;

  /// Initialize the controller (called internally by FlutterNativePlayer)
  void initialize({
    required PlayerResource playerResource,
    required bool playWhenReady,
  }) {
    _fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(
      playerResource: playerResource,
    );
    _playerMethodManager = PlayerMethodManager(
      fetchHlsMasterPlaylist: _fetchHlsMasterPlaylist,
      playWhenReady: playWhenReady,
    );

    _setupListeners();
    _isInitialized = true;
  }

  void _setupListeners() {
    // Listen to playback state
    _subscriptions.add(
      _playerMethodManager.streamPlaybackState.listen((state) {
        if (_isDisposed) return;
        _currentPlaybackState = state;
        _playbackStateController.add(state);

        // Update loading state
        final wasLoading = _isLoading;
        _isLoading = state == PlaybackState.loading;
        if (wasLoading != _isLoading) {
          _loadingController.add(_isLoading);
        }
      }),
    );

    // Listen to duration state
    _subscriptions.add(
      _playerMethodManager.streamDurationState.listen((state) {
        if (_isDisposed) return;
        _currentDurationState = state;
        _durationStateController.add(state);
      }),
    );

    // Listen to download state
    _subscriptions.add(
      _playerMethodManager.streamDownloadState.listen((state) {
        if (_isDisposed) return;
        _downloadStateController.add(state);
      }),
    );

    // Listen to download progress
    _subscriptions.add(
      _playerMethodManager.streamProgressDownloadState.listen((progress) {
        if (_isDisposed) return;
        _downloadProgressController.add(progress);
      }),
    );
  }

  /// Start or resume video playback
  Future<void> play() async {
    _checkInitialized();
    await _playerMethodManager.play();
  }

  /// Pause video playback
  Future<void> pause() async {
    _checkInitialized();
    await _playerMethodManager.pause();
  }

  /// Toggle between play and pause based on current state
  Future<void> playOrPause() async {
    _checkInitialized();
    _playerMethodManager.playByState();
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    _checkInitialized();
    // Emit loading state immediately when seeking starts
    if (!_isDisposed) {
      _playbackStateController.add(PlaybackState.loading);
    }
    await _playerMethodManager.seekTo(position.inMilliseconds);
  }

  /// Seek forward by the specified duration (default: 10 seconds)
  Future<void> seekForward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    _checkInitialized();
    final newPosition = currentPosition + duration;
    final clampedPosition = newPosition > totalDuration
        ? totalDuration
        : newPosition;
    await seekTo(clampedPosition);
  }

  /// Seek backward by the specified duration (default: 10 seconds)
  Future<void> seekBackward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    _checkInitialized();
    final newPosition = currentPosition - duration;
    final clampedPosition = newPosition < Duration.zero
        ? Duration.zero
        : newPosition;
    await seekTo(clampedPosition);
  }

  /// Restart the video from the beginning
  Future<void> restart() async {
    _checkInitialized();
    await _playerMethodManager.restart();
  }

  /// Set playback speed (e.g., 0.5, 1.0, 1.5, 2.0)
  Future<void> setPlaybackSpeed(double speed) async {
    _checkInitialized();
    await _playerMethodManager.setPlaybackSpeed(speed);
  }

  /// Get current playback speed
  double get currentSpeed {
    _checkInitialized();
    return _playerMethodManager.currentSpeed();
  }

  /// Get available video qualities
  List<QualityModel> getAvailableQualities() {
    _checkInitialized();
    return _playerMethodManager.getListQuality();
  }

  /// Change video quality
  Future<void> changeQuality(QualityModel quality) async {
    _checkInitialized();
    await _playerMethodManager.changeQuality(quality);
  }

  /// Get current video quality width
  int get currentQualityWidth {
    _checkInitialized();
    return _playerMethodManager.getCurrentWidth();
  }

  /// Get current video quality height
  int get currentQualityHeight {
    _checkInitialized();
    return _playerMethodManager.getCurrentHeight();
  }

  /// Get current quality URL
  String get currentQualityUrl {
    _checkInitialized();
    return _playerMethodManager.getCurrentUrlQuality();
  }

  /// Get available subtitles
  List<PlayerKidSubtitlesSource> getAvailableSubtitles() {
    _checkInitialized();
    return _fetchHlsMasterPlaylist.getSubtitleSources();
  }

  /// Change subtitle
  Future<void> changeSubtitle(PlayerKidSubtitlesSource subtitle) async {
    _checkInitialized();

    // Don't wait for native method - subtitles are handled on Flutter side
    _playerMethodManager.changeSubtitle(subtitle);

    await _fetchHlsMasterPlaylist.setupSubtitleSource(subtitle);

    if (!_isDisposed) {
      _subtitleController.add(subtitle);
    }
  }

  /// Disable/turn off subtitle
  Future<void> disableSubtitle() async {
    _checkInitialized();
    _fetchHlsMasterPlaylist.betterPlayerSubtitlesSource = null;
    _fetchHlsMasterPlaylist.subtitlesLines.clear();
    if (!_isDisposed) {
      _subtitleController.add(null);
    }
  }

  /// Get current selected subtitle
  PlayerKidSubtitlesSource? get currentSubtitle {
    _checkInitialized();
    return _fetchHlsMasterPlaylist.betterPlayerSubtitlesSource;
  }

  /// Check if the video is currently playing
  Future<bool> isPlaying() async {
    _checkInitialized();
    return await _playerMethodManager.isPlaying();
  }

  /// Start downloading the video at specified quality
  Future<void> startDownload(
    PlayerResource playerResource,
    int trackIndex,
  ) async {
    _checkInitialized();
    await _playerMethodManager.startDownload(playerResource, trackIndex);
  }

  /// Cancel current download
  Future<void> cancelDownload() async {
    _checkInitialized();
    await _playerMethodManager.setCancelDownload();
  }

  /// Retry failed download
  Future<void> retryDownload() async {
    _checkInitialized();
    await _playerMethodManager.setRetryDownload();
  }

  /// Check if video is downloaded
  Future<void> isDownloadCompleted(
    String url,
    void Function(bool) callback,
  ) async {
    _checkInitialized();
    await _playerMethodManager.isDownloadCompleted(url, callback);
  }

  /// Show available audio/video devices (platform specific)
  Future<void> showDevices() async {
    _checkInitialized();
    await _playerMethodManager.showDevices();
  }

  /// Release the player resources
  Future<void> release() async {
    _checkInitialized();
    await _playerMethodManager.releasePlayer();
  }

  /// Reinitialize the player
  Future<void> reinitialize() async {
    _checkInitialized();
    await _playerMethodManager.initPlayer();
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'FlutterNativePlayerController is not initialized. '
        'Make sure to use it after the FlutterNativePlayer widget is built.',
      );
    }
  }

  /// Get the internal FetchHlsMasterPlaylist for subtitle handling
  FetchHlsMasterPlaylist get fetchHlsMasterPlaylist {
    _checkInitialized();
    return _fetchHlsMasterPlaylist;
  }

  /// Get the internal PlayerMethodManager for advanced usage
  PlayerMethodManager get playerMethodManager {
    _checkInitialized();
    return _playerMethodManager;
  }

  /// Dispose the controller and release resources
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // Cancel all subscriptions first
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Then close the controllers
    _playbackStateController.close();
    _durationStateController.close();
    _downloadStateController.close();
    _downloadProgressController.close();
    _loadingController.close();
    _subtitleController.close();

    if (_isInitialized) {
      _playerMethodManager.dispose();
    }
  }
}
