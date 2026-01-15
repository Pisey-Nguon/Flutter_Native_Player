# Flutter Native Player for Flutter

A Flutter plugin for  Android, iOS for playing back video on a Widget surface.

![20220406_163756](https://user-images.githubusercontent.com/47247206/161946545-64355d36-aadb-4bef-9614-a2db19838a89.gif)


## Installation
Copy and paste to dependencies:

    flutter_native_player: ^2.0.0

## Requirements

### Version 2.0.0+
- **Flutter**: 3.0.0 or higher
- **Dart**: 3.0.0 or higher
- **iOS**: 12.0 or higher
- **Android**: SDK 21 (Android 5.0) or higher

### Previous versions (1.x.x)
- **iOS**: 9.0 or higher
- **Android**: SDK 16 or higher

**Example:**

    import 'package:flutter/material.dart';
    import 'package:flutter_native_player/flutter_native_player.dart';
    import 'package:flutter_native_player/model/player_resource.dart';
    import 'package:flutter_native_player/model/player_subtitle_resource.dart';

    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatefulWidget {
      const MyApp({Key? key}) : super(key: key);

      @override
      State<MyApp> createState() => _MyAppState();
    }

    class _MyAppState extends State<MyApp> {

      String videoUrl = "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8";
     final playerSubtitleResource = [
        PlayerSubtitleResource(
          language: "English",
	      subtitleUrl: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BEnglish%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
	      ),
      PlayerSubtitleResource(
          language: "Japanese",
	      subtitleUrl: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BJapanese%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
	      )
      ];

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter Native Player'),
	      ),
	      body: Center(
              child: FlutterNativePlayer(
	                  playerResource: PlayerResource(videoUrl: videoUrl, playerSubtitleResource: playerSubtitleResource),
				      playWhenReady: true,
				      width: double.infinity,
				      height: 250
				      ),
			      ),
		      ),
	      );
      }
    }

**Configuration:**

 1. **playWhenReady** if it's true it's going to play immediately after fetching data success but if it's false that after fetching data success it's not played.
 2. **playerSubtitleResource** if null or empty list it's going to hide subtitle button.

## Migration Guide

### Migrating from 1.x.x to 2.0.0

Version 2.0.0 includes several breaking changes to support the latest Flutter, Android, and iOS versions:

#### Minimum Requirements Updated
- **Flutter**: 3.0.0 or higher (was 2.5.0)
- **Dart**: 3.0.0 or higher (was 2.15.1)
- **Android**: SDK 21 (Android 5.0) or higher (was SDK 16)
- **iOS**: 12.0 or higher (was 9.0)

#### Android Changes
- Migrated from ExoPlayer2 to AndroidX Media3
- Updated to latest Kotlin (1.9.22) and Android Gradle Plugin (8.3.0)
- Added Android 13+ permissions support
- Removed deprecated kotlin-android-extensions

#### What You Need to Do
1. Update your Flutter SDK to 3.0.0 or higher
2. Update your app's minimum Android SDK version to 21 in `android/app/build.gradle`
3. Update your app's minimum iOS version to 12.0 in your Podfile
4. Run `flutter pub upgrade` to update dependencies
5. Test video playback in your app

## Supported Formats
-   For Android, the backing player is [AndroidX Media3](https://developer.android.com/media/media3), which uses ExoPlayer under the hood. Please refer [here](https://developer.android.com/media/media3/exoplayer/supported-formats) for list of supported formats.
-   For iOS, the backing player is  [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer). The supported formats vary depending on the version of iOS,  [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset)  class has  [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc)  that you can query for supported av formats.
