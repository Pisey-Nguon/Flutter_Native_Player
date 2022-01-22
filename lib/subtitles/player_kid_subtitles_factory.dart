// Dart imports:
import 'dart:convert';
import 'dart:io';

import 'player_kid_subtitle.dart';
import 'player_kid_subtitles_source.dart';
import 'player_kid_subtitles_source_type.dart';

class PlayerKidSubtitlesFactory {
  static Future<List<PlayerKidSubtitle>> parseSubtitles(
      PlayerKidSubtitlesSource source) async {
    switch (source.type) {
      case PlayerKidSubtitlesSourceType.file:
        return _parseSubtitlesFromFile(source);
      case PlayerKidSubtitlesSourceType.network:
        return _parseSubtitlesFromNetwork(source);
      case PlayerKidSubtitlesSourceType.memory:
        return _parseSubtitlesFromMemory(source);
      default:
        return [];
    }
  }

  static Future<List<PlayerKidSubtitle>> _parseSubtitlesFromFile(
      PlayerKidSubtitlesSource source) async {
    try {
      final List<PlayerKidSubtitle> subtitles = [];
      for (final String? url in source.urls!) {
        final file = File(url!);
        if (file.existsSync()) {
          final String fileContent = await file.readAsString();
          final subtitlesCache = _parseString(fileContent);
          subtitles.addAll(subtitlesCache);
        } else {
          print("$url doesn't exist!");
        }
      }
      return subtitles;
    } catch (exception) {
      print("Failed to read subtitles from file: $exception");
    }
    return [];
  }

  static Future<List<PlayerKidSubtitle>> _parseSubtitlesFromNetwork(
      PlayerKidSubtitlesSource source) async {
    try {
      final client = HttpClient();
      final List<PlayerKidSubtitle> subtitles = [];
      for (final String? url in source.urls!) {
        final request = await client.getUrl(Uri.parse(url!));
        source.headers?.keys.forEach((key) {
          final value = source.headers![key];
          if (value != null) {
            request.headers.add(key, value);
          }
        });
        final response = await request.close();
        final data = await response.transform(const Utf8Decoder()).join();
        final cacheList = _parseString(data);
        subtitles.addAll(cacheList);
      }
      client.close();

      print("Parsed total subtitles: ${subtitles.length}");
      return subtitles;
    } catch (exception) {
      print("Failed to read subtitles from network: $exception");
    }
    return [];
  }

  static List<PlayerKidSubtitle> _parseSubtitlesFromMemory(
      PlayerKidSubtitlesSource source) {
    try {
      return _parseString(source.content!);
    } catch (exception) {
      print("Failed to read subtitles from memory: $exception");
    }
    return [];
  }

  static List<PlayerKidSubtitle> _parseString(String value) {
    List<String> components = value.split('\r\n\r\n');
    if (components.length == 1) {
      components = value.split('\n\n');
    }

    // Skip parsing files with no cues
    if (components.length == 1) {
      return [];
    }

    final List<PlayerKidSubtitle> subtitlesObj = [];

    final bool isWebVTT = components.contains("WEBVTT");
    for (final component in components) {
      if (component.isEmpty) {
        continue;
      }
      final subtitle = PlayerKidSubtitle(component, isWebVTT);
      if (subtitle.start != null &&
          subtitle.end != null &&
          subtitle.texts != null) {
        subtitlesObj.add(subtitle);
      }
    }

    return subtitlesObj;
  }
}
