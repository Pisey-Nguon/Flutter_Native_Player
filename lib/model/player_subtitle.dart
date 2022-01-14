import 'dart:convert';
String playerSubtitleToJson(PlayerSubtitle data) => json.encode(data.toJson());
PlayerSubtitle playerSubtitleFromJson(String str) => PlayerSubtitle.fromJson(json.decode(str));

class PlayerSubtitle {
  PlayerSubtitle({
    required this.urlSubtitle,
    required this.language,
  });

  String urlSubtitle;
  String language;

  factory PlayerSubtitle.fromJson(Map<String, dynamic> json) => PlayerSubtitle(
    urlSubtitle: json["urlSubtitle"],
    language: json["language"],
  );

  Map<String, dynamic> toJson() => {
    "urlSubtitle": urlSubtitle,
    "language": language,
  };
}
