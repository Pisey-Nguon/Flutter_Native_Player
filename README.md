# Flutter Native Player

A Flutter plugin for Android and iOS for playing back video on a Widget surface with **full customization support**. Build your own video player UI with complete control over the player, **OR** use our pre-built controls for instant integration!

![20220406_163756](https://user-images.githubusercontent.com/47247206/161946545-64355d36-aadb-4bef-9614-a2db19838a89.gif)

## Features

- ✅ Native video playback (ExoPlayer on Android, AVPlayer on iOS)
- ✅ HLS streaming support
- ✅ Subtitle support (SRT format)
- ✅ Quality selection
- ✅ Playback speed control
- ✅ **Pre-built controls** - Use ready-made UI in seconds ⚡
- ✅ **Full customization** - Build your own controls if needed
- ✅ External controller for programmatic control
- ✅ Custom loading indicators

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_player: ^2.0.0
```

*Note: iOS requires 9.0 or higher and Android requires SDK 16 or higher*

## Quick Start (NEW! 🎉)

### 1. Full Controls (11 lines - Everything included!)

The easiest way to get started! Includes play/pause, seek, progress bar, quality selector, speed control, and subtitle selector.

```dart
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';

FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(
    videoUrl: 'https://example.com/video.m3u8',
    playerSubtitleResources: subtitles, // Optional
  ),
  width: double.infinity,
  height: 250,
  primaryColor: Colors.blue,
  showQualitySelector: true,
  showSpeedSelector: true,
  showSubtitleSelector: true,
)
```

### 2. Basic Controls (7 lines - Simple & Clean)

Just play/pause and progress bar - perfect for most use cases.

```dart
FlutterNativePlayer.withBasicControls(
  playerResource: PlayerResource(
    videoUrl: 'https://example.com/video.m3u8',
  ),
  width: double.infinity,
  height: 250,
  primaryColor: Colors.blue,
)
```

### 3. Minimal Controls (5 lines - Ultra Simple)

Only a play/pause button - cleanest option.

```dart
FlutterNativePlayer.withMinimalControls(
  playerResource: PlayerResource(
    videoUrl: 'https://example.com/video.m3u8',
  ),
  width: double.infinity,
  height: 250,
)
```

**That's it! 🎉 You now have a fully functional video player with professional controls in just a few lines of code!**

---

## Advanced Usage

### No Controls (Bare Video)

If you want just the video without any controls:

```dart
FlutterNativePlayer(
  playerResource: PlayerResource(
    videoUrl: 'https://example.com/video.m3u8',
  ),
  playWhenReady: true,
  width: double.infinity,
  height: 250,
)
```

### Custom Controls with overlayBuilder

If you need completely custom UI, build your own using the `overlayBuilder`:

```dart
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/flutter_native_player_controller.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/model/duration_state.dart';

FlutterNativePlayer(
  playerResource: PlayerResource(videoUrl: videoUrl),
  width: double.infinity,
  height: 250,
  overlayBuilder: (context, controller, playbackState, durationState) {
    return Stack(
      children: [
        // Your custom UI here
        Center(
          child: IconButton(
            icon: Icon(
              playbackState == PlaybackState.play
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: () => controller.playOrPause(),
          ),
        ),
      ],
    );
  },
)
```

### External Controller

Control the player programmatically from anywhere in your app:

```dart
class MyPlayerScreen extends StatefulWidget {
  @override
  State<MyPlayerScreen> createState() => _MyPlayerScreenState();
}

class _MyPlayerScreenState extends State<MyPlayerScreen> {
  final _controller = FlutterNativePlayerController();

  @override
  void initState() {
    super.initState();
    
    // Listen to playback state
    _controller.playbackStateStream.listen((state) {
      print('Playback state: $state');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video player (use any of the factory constructors)
        FlutterNativePlayer.withBasicControls(
          playerResource: PlayerResource(videoUrl: videoUrl),
          controller: _controller,
          playWhenReady: true,
          width: double.infinity,
          height: 250,
        ),
        
        // External controls
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _controller.play(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _controller.pause(),
              child: Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () => _controller.seekForward(),
              child: Text('+10s'),
            ),
          ],
        ),
      ],
    );
  }
          width: double.infinity,
          height: 250,
        ),
        
        // External controls (anywhere in your widget tree)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay_10),
              onPressed: () => _controller.seekBackward(),
            ),
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _controller.play(),
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () => _controller.pause(),
            ),
            IconButton(
              icon: Icon(Icons.forward_10),
              onPressed: () => _controller.seekForward(),
            ),
          ],
        ),
      ],
    );
  }
}
```

## Controller API Reference

The `FlutterNativePlayerController` provides complete player control:

### Playback Control

```dart
controller.play();                              // Start playback
controller.pause();                             // Pause playback
controller.playOrPause();                       // Toggle play/pause
controller.restart();                           // Restart from beginning
controller.seekTo(Duration(seconds: 30));       // Seek to specific position
controller.seekForward();                       // Forward 10 seconds (default)
controller.seekBackward();                      // Backward 10 seconds (default)
```

### Speed Control

```dart
controller.setPlaybackSpeed(1.5);               // 0.25x to 2.0x speed
double speed = controller.currentSpeed;         // Get current speed
```

### Quality Selection

```dart
List<QualityModel> qualities = controller.getAvailableQualities();
controller.changeQuality(qualities[0]);         // Change quality
String url = controller.currentQualityUrl;      // Current quality URL
```

### Subtitle Control

```dart
List<PlayerKidSubtitlesSource> subs = controller.getAvailableSubtitles();
controller.changeSubtitle(subs[0]);             // Enable subtitle
controller.disableSubtitle();                   // Turn off subtitles
PlayerKidSubtitlesSource? current = controller.currentSubtitle;
```

### State Monitoring

```dart
// Listen to playback state changes
controller.playbackStateStream.listen((state) {
  // PlaybackState.play, .pause, .loading, .finish
});

// Listen to position updates
controller.durationStateStream.listen((state) {
  Duration progress = state.progress;
  Duration total = state.total;
  Duration buffered = state.buffered;
});

// Get current values
PlaybackState state = controller.playbackState;
DurationState? duration = controller.durationState;
Duration position = controller.currentPosition;
Duration total = controller.totalDuration;
bool loading = controller.isLoading;
```

## Customization Options

### Pre-built Controls Configuration

All factory constructors support customization:

```dart
FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
  primaryColor: Colors.purple,              // Accent color for controls
  controlsBackgroundColor: Colors.black54,  // Background overlay color
  autoHide: true,                           // Auto-hide controls
  autoHideDuration: Duration(seconds: 3),   // Hide after 3 seconds
  showQualitySelector: true,                // Show quality button
  showSpeedSelector: true,                  // Show speed button
  showSubtitleSelector: true,               // Show subtitle button
  backgroundColor: Colors.black,            // Player background
)
```

### Custom Loading Indicator

```dart
FlutterNativePlayer.withBasicControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
  loadingBuilder: (context, controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  },
)
```

### With Subtitles

```dart
import 'package:flutter_native_player/model/player_subtitle_resource.dart';

FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(
    videoUrl: url,
    playerSubtitleResources: [
      PlayerSubtitleResource(
        language: "English",
        subtitleUrl: "https://example.com/subtitles_en.srt",
      ),
      PlayerSubtitleResource(
        language: "Spanish",
        subtitleUrl: "https://example.com/subtitles_es.srt",
      ),
    ],
  ),
  width: double.infinity,
  height: 250,
  showSubtitleSelector: true,  // Show subtitle picker
  showSubtitles: true,          // Display subtitles
)
```

## Migration from Old API

If you have existing code using `overlayBuilder`, it continues to work! But consider migrating:

**Before (200+ lines):**
```dart
class MyPlayer extends StatefulWidget {
  // Complex state management
  // Custom control UI
  // Stream listeners
  // 200+ lines of code...
}
}
```

**After (11 lines):**
```dart
FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
)
```

**✨ Result: 95% less code, same features!**

---

## Why Use This Package?

### ⚡ Instant Integration
```dart
// From zero to fully-functional player in 30 seconds
FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
)
```

### 🎨 Flexible Design
- **Pre-built controls** - Ready to use out of the box
- **Customizable** - Change colors, hide features you don't need
- **Fully custom** - Build your own UI with `overlayBuilder`

### 🚀 Native Performance
- Uses **ExoPlayer** on Android
- Uses **AVPlayer** on iOS
- Hardware-accelerated video decoding
- Optimized for battery life

### 📦 Feature-Rich
- HLS streaming with automatic quality switching
- SRT subtitle support with multi-language
- Playback speed control (0.25x to 2.0x)
- Manual quality selection
- Programmatic control API

---

## Examples

Check out the [example folder](example/) for complete demonstrations:
- [`simple_examples.dart`](example/lib/simple_examples.dart) - Quick start examples (recommended!)
- [`main.dart`](example/lib/main.dart) - Advanced customization examples

---

## Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ SDK 16+ |
| iOS      | ✅ iOS 9.0+ |
| Web      | ❌ Not supported |
| Desktop  | ❌ Not supported |

---

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting a PR.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

If you find this package helpful, please give it a ⭐ on GitHub!
Duration total = controller.totalDuration;           // Total duration
Duration buffered = controller.bufferedDuration;     // Buffered amount
bool loading = controller.isLoading;                 // Loading state
```

### Streams (for reactive updates)

```dart
controller.playbackStateStream.listen((state) { });
controller.durationStateStream.listen((duration) { });
controller.loadingStream.listen((isLoading) { });
controller.downloadStateStream.listen((state) { });
controller.downloadProgressStream.listen((progress) { });
```

### Other

```dart
Future<bool> isPlaying = controller.isPlaying();
controller.showDevices();                       // Show available devices
controller.release();                           // Release player resources
controller.dispose();                           // Dispose controller
```

## Widget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `playerResource` | `PlayerResource` | required | Video URL and subtitle resources |
| `width` | `double` | required | Player width |
| `height` | `double` | required | Player height |
| `playWhenReady` | `bool` | `true` | Auto-play when ready |
| `controller` | `FlutterNativePlayerController?` | `null` | External controller |
| `overlayBuilder` | `PlayerOverlayBuilder?` | `null` | Custom controls builder |
| `loadingBuilder` | `PlayerLoadingBuilder?` | `null` | Custom loading indicator |
| `showSubtitles` | `bool` | `true` | Show/hide subtitles |
| `backgroundColor` | `Color` | `Colors.black` | Background color |

## Supported Formats

- **Android**: Backed by [ExoPlayer](https://google.github.io/ExoPlayer/). See [supported formats](https://google.github.io/ExoPlayer/supported-formats.html).
- **iOS**: Backed by [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer). Formats vary by iOS version.

## Migration from v1.x

Version 2.0 removes the predefined UI controls in favor of full customization. If you were using the default controls, you'll need to build your own using the `overlayBuilder` parameter.

**Before (v1.x):**
```dart
FlutterNativePlayer(
  playerResource: resource,
  progressColors: PlayerProgressColors(...),  // Removed
  playWhenReady: true,
  width: double.infinity,
  height: 250,
)
```

**After (v2.0):**
```dart
FlutterNativePlayer(
  playerResource: resource,
  playWhenReady: true,
  width: double.infinity,
  height: 250,
  overlayBuilder: (context, controller, playbackState, durationState) {
    return YourCustomControls(...);
  },
)
```

See the example project for complete implementations of custom controls.

## License

MIT License
