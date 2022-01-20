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
  String url = "https://html5demos.com/assets/dizzy.mp4";
  final subtitles = [
    PlayerSubtitle(
      language: "English",
      urlSubtitle: "https://storage.googleapis.com/exoplayer-test-media-1/webvtt/numeric-lines.vtt",
    ),
    PlayerSubtitle(
      language: "Japanese",
      urlSubtitle: "https://storage.googleapis.com/exoplayer-test-media-1/webvtt/japanese.vtt",
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
            width: double.infinity,
            height: 400),
      ),
    );
  }
}
