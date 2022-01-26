# Flutter Native Player for Flutter

A Flutter plugin for  Android, iOS for playing back video on a Widget surface.

![20220122_104448](https://user-images.githubusercontent.com/47247206/150627344-55faa680-7527-4054-bba5-ad78ef7f417f.gif)


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

      String videoUrl = "https://d2cqvl54b1gtkt.cloudfront.net/PRODUCTION/5d85da3fa81ada4c66211a07/post/media/video/1616987127933-bfc1a13a-49c6-4272-8ffd-dc04b05eed2c/1616987128057-740d153b431660cf976789c1901192a961f0fd5b2a2af43e2388f671fa03c2aa/1616987128057-740d153b431660cf976789c1901192a961f0fd5b2a2af43e2388f671fa03c2aa.m3u8";
     final playerSubtitleResource = [
        PlayerSubtitleResource(
          language: "English",
	      subtitleUrl: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/English_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
	      ),
      PlayerSubtitleResource(
          language: "Khmer",
	      subtitleUrl: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/Khmer_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
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
