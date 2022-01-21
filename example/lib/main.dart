import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PlayerResource playerResource;
  String url = "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8";
  final subtitles = [
    PlayerSubtitle(
      language: "English",
      urlSubtitle: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BEnglish%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
    ),
    PlayerSubtitle(
      language: "Japanese",
      urlSubtitle: "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BJapanese%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
    )
  ];

  @override
  void initState() {
    playerResource = PlayerResource(mediaName: "Tranformer", mediaUrl: url, subtitles: subtitles);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Native Player'),
        ),
        body: FlutterNativePlayer(
            playerResource: playerResource,
            playWhenReady: false,
            width: double.infinity,
            height: 400),
      ),
    );
  }
}
