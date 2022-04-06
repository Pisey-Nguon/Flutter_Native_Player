# Flutter Native Player for Flutter

A Flutter plugin for  Android, iOS for playing back video on a Widget surface.

![20220406_163756](https://user-images.githubusercontent.com/47247206/161946545-64355d36-aadb-4bef-9614-a2db19838a89.gif)


## Installation
Copy and paste to dependencies:

    flutter_native_player: ^1.0.4

*Note: iOS requires 9.0 or higher and Android requires SDK 16 or higher*

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

## Supported Formats
-   For Android, the backing player is  [ExoPlayer](https://google.github.io/ExoPlayer/), please refer  [here](https://google.github.io/ExoPlayer/supported-formats.html)  for list of supported formats.
-   For iOS, the backing player is  [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer). The supported formats vary depending on the version of iOS,  [AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset)  class has  [audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc)  that you can query for supported av formats.
