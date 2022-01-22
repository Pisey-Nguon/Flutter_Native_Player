// To parse this JSON data, do
//
//     final playerResource = playerResourceFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_native_player/model/player_subtitle_resource.dart';

PlayerResource playerResourceFromJson(String str) =>
    PlayerResource.fromJson(json.decode(str));

String playerResourceToJson(PlayerResource data) => json.encode(data.toJson());

class PlayerResource {
  PlayerResource({
    required this.videoUrl,
    required this.playerSubtitleResource,
  });

  String videoUrl;
  List<PlayerSubtitleResource>? playerSubtitleResource;

  factory PlayerResource.fromJson(Map<String, dynamic> json) => PlayerResource(
        videoUrl: json["videoUrl"],
        playerSubtitleResource: List<PlayerSubtitleResource>.from(
            json["playerSubtitleResource"]
                .map((x) => PlayerSubtitleResource.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "videoUrl": videoUrl,
        "playerSubtitleResource": playerSubtitleResource != null
            ? List<dynamic>.from(playerSubtitleResource!.map((x) => x.toJson()))
            : null,
      };
}
