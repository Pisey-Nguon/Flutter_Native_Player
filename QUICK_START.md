# Quick Start Guide - Flutter Native Player v2.0

## 🚀 The Easiest Way to Add Video to Your Flutter App

### Installation

```yaml
dependencies:
  flutter_native_player: ^2.0.0
```

Run: `flutter pub get`

---

## 🎬 Three Ways to Use (Choose Based on Your Needs)

### 1️⃣ Full Featured Player (Recommended for most apps)

**Use when:** You want everything - quality selection, speed control, subtitles

```dart
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';

FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: 'https://example.com/video.m3u8'),
  width: double.infinity,
  height: 250,
)
```

That's it! You now have:
- ✅ Play/Pause
- ✅ Seek forward/backward (10s)
- ✅ Progress bar with time labels
- ✅ Quality selector
- ✅ Speed control (0.25x - 2.0x)
- ✅ Subtitle support
- ✅ Auto-hide controls

---

### 2️⃣ Simple Player (For basic needs)

**Use when:** You just need play/pause and a progress bar

```dart
FlutterNativePlayer.withBasicControls(
  playerResource: PlayerResource(videoUrl: 'https://example.com/video.m3u8'),
  width: double.infinity,
  height: 250,
)
```

You get:
- ✅ Play/Pause
- ✅ Progress bar
- ✅ Time labels
- ✅ Auto-hide controls

---

### 3️⃣ Minimal Player (Ultra simple)

**Use when:** You want the cleanest possible UI

```dart
FlutterNativePlayer.withMinimalControls(
  playerResource: PlayerResource(videoUrl: 'https://example.com/video.m3u8'),
  width: double.infinity,
  height: 250,
)
```

You get:
- ✅ Just a play/pause button

---

## 🎨 Customization Examples

### Change Colors

```dart
FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
  primaryColor: Colors.purple,  // Your brand color!
)
```

### Add Subtitles

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
  showSubtitleSelector: true,  // Show subtitle picker button
)
```

### Hide Features You Don't Need

```dart
FlutterNativePlayer.withFullControls(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
  showQualitySelector: false,   // Hide quality button
  showSpeedSelector: false,      // Hide speed button
  showSubtitleSelector: false,   // Hide subtitle button
)
```

---

## 🎮 External Control (Advanced)

Control the player from anywhere in your app:

```dart
class MyVideoPlayer extends StatefulWidget {
  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  final _controller = FlutterNativePlayerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The player
        FlutterNativePlayer.withBasicControls(
          playerResource: PlayerResource(videoUrl: url),
          controller: _controller,  // Pass your controller
          width: double.infinity,
          height: 250,
        ),
        
        // Your custom controls anywhere!
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _controller.play(),
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () => _controller.pause(),
            ),
            TextButton(
              child: Text('Jump to 1:00'),
              onPressed: () => _controller.seekTo(Duration(minutes: 1)),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Controller Methods

```dart
// Playback
controller.play();
controller.pause();
controller.playOrPause();
controller.restart();

// Seeking
controller.seekTo(Duration(seconds: 30));
controller.seekForward();        // +10 seconds
controller.seekBackward();       // -10 seconds

// Speed
controller.setPlaybackSpeed(1.5);
double speed = controller.currentSpeed;

// Quality
List<QualityModel> qualities = controller.getAvailableQualities();
controller.changeQuality(qualities[0]);

// Subtitles
List<PlayerKidSubtitlesSource> subs = controller.getAvailableSubtitles();
controller.changeSubtitle(subs[0]);
controller.disableSubtitle();

// Monitoring
controller.playbackStateStream.listen((state) {
  print('State: $state');
});

controller.durationStateStream.listen((state) {
  print('Position: ${state.progress}');
  print('Total: ${state.total}');
});
```

---

## 📱 Complete Example App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My Video App')),
        body: Center(
          child: FlutterNativePlayer.withFullControls(
            playerResource: PlayerResource(
              videoUrl: 'https://p-events-delivery.akamaized.net/'
                  '2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8',
            ),
            width: double.infinity,
            height: 250,
            primaryColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
```

**That's it! Run it and you have a fully functional video player! 🎉**

---

## ⚙️ Advanced: Custom UI

If you need completely custom controls, use `overlayBuilder`:

```dart
FlutterNativePlayer(
  playerResource: PlayerResource(videoUrl: url),
  width: double.infinity,
  height: 250,
  overlayBuilder: (context, controller, playbackState, durationState) {
    // Build your completely custom UI here
    return YourCustomControlsWidget(
      controller: controller,
      state: playbackState,
      duration: durationState,
    );
  },
)
```

---

## 🆘 Troubleshooting

### Video not playing?
- Check that the URL is accessible
- For HLS: Make sure URL ends with `.m3u8`
- For MP4: Direct URL to video file

### Subtitles not showing?
- Ensure subtitle files are `.srt` format
- Check URLs are accessible
- Set `showSubtitles: true`

### Controls not appearing?
- Make sure you're using a factory constructor (`.withFullControls()`, etc.)
- Or provide your own `overlayBuilder`

---

## 🔗 More Resources

- **Full API Documentation**: See [README.md](../README.md)
- **Advanced Examples**: Check [example/lib/main.dart](../example/lib/main.dart)
- **Simple Examples**: See [example/lib/simple_examples.dart](../example/lib/simple_examples.dart)

---

## 💡 Tips

1. **Start simple**: Use `.withBasicControls()` first
2. **Need more?**: Upgrade to `.withFullControls()`
3. **Need customization?**: Add `primaryColor` and other options
4. **Need complete control?**: Use `overlayBuilder` for fully custom UI

---

**Enjoy building with Flutter Native Player! 🎬✨**

If you find this helpful, please ⭐ the package on pub.dev!
