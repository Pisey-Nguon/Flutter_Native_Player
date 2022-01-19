// To parse this JSON data, do
//
//     final playerResource = playerResourceFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_native_player/model/player_subtitle.dart';

PlayerResource playerResourceFromJson(String str) => PlayerResource.fromJson(json.decode(str));

String playerResourceToJson(PlayerResource data) => json.encode(data.toJson());

class PlayerResource {
  PlayerResource({
    required this.mediaName,
    required this.mediaUrl,
    required this.subtitles,
  });

  String mediaName;
  String mediaUrl;
  List<PlayerSubtitle>? subtitles;

  factory PlayerResource.fromJson(Map<String, dynamic> json) => PlayerResource(
    mediaName: json["mediaName"],
    mediaUrl: json["mediaUrl"],
    subtitles: List<PlayerSubtitle>.from(json["subtitles"].map((x) => PlayerSubtitle.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "mediaName": mediaName,
    "mediaUrl": mediaUrl,
    "subtitles": subtitles != null ? List<dynamic>.from(subtitles!.map((x) => x.toJson())): null,
  };
}

