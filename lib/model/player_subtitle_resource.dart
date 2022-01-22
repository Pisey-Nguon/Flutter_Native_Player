import 'dart:convert';

String playerSubtitleToJson(PlayerSubtitleResource data) =>
    json.encode(data.toJson());
PlayerSubtitleResource playerSubtitleFromJson(String str) =>
    PlayerSubtitleResource.fromJson(json.decode(str));

class PlayerSubtitleResource {
  PlayerSubtitleResource({
    required this.subtitleUrl,
    required this.language,
  });

  String subtitleUrl;
  String language;

  factory PlayerSubtitleResource.fromJson(Map<String, dynamic> json) =>
      PlayerSubtitleResource(
        subtitleUrl: json["subtitleUrl"],
        language: json["language"],
      );

  Map<String, dynamic> toJson() => {
        "subtitleUrl": subtitleUrl,
        "language": language,
      };
}
