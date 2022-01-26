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
  String videoUrl =
      "https://d2cqvl54b1gtkt.cloudfront.net/PRODUCTION/5d85da3fa81ada4c66211a07/post/media/video/1616987127933-bfc1a13a-49c6-4272-8ffd-dc04b05eed2c/1616987128057-740d153b431660cf976789c1901192a961f0fd5b2a2af43e2388f671fa03c2aa/1616987128057-740d153b431660cf976789c1901192a961f0fd5b2a2af43e2388f671fa03c2aa.m3u8";
  final playerSubtitleResource = [
    PlayerSubtitleResource(
      language: "English",
      subtitleUrl:
          "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/English_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
    ),
    PlayerSubtitleResource(
      language: "Khmer",
      subtitleUrl:
          "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/Khmer_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
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
              playerResource: PlayerResource(
                  videoUrl: videoUrl,
                  playerSubtitleResources: playerSubtitleResource),
              playWhenReady: true,
              width: double.infinity,
              height: 250),
        ),
      ),
    );
  }
}
