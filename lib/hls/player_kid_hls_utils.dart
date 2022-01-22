import 'hls_parser/hls_master_playlist.dart';
import 'hls_parser/hls_playlist_parser.dart';
import 'player_kid_data_holder.dart';
import 'player_kid_track.dart';

///HLS helper class
class PlayerKidHlsUtils {
  static Future<PlayerKidDataHolder> parse(
      String data, String masterPlaylistUrl) async {
    List<PlayerKidTrack> tracks = [];
    // List<BetterPlayerAsmsSubtitle> subtitles = [];
    // List<BetterPlayerAsmsAudioTrack> audios = [];
    try {
      final List<List<dynamic>> list = await Future.wait([
        parseTracks(data, masterPlaylistUrl),
        // parseSubtitles(data, masterPlaylistUrl),
        // parseLanguages(data, masterPlaylistUrl)
      ]);
      tracks = list[0] as List<PlayerKidTrack>;
      // subtitles = list[1] as List<BetterPlayerAsmsSubtitle>;
      // audios = list[2] as List<BetterPlayerAsmsAudioTrack>;
    } catch (exception) {
      print("Exception on hls parse: $exception");
    }
    return PlayerKidDataHolder(tracks: tracks);
  }

  static Future<List<PlayerKidTrack>> parseTracks(
      String data, String masterPlaylistUrl) async {
    final List<PlayerKidTrack> tracks = [];
    try {
      final parsedPlaylist = await HlsPlaylistParser.create()
          .parseString(Uri.parse(masterPlaylistUrl), data);
      if (parsedPlaylist is HlsMasterPlaylist) {
        parsedPlaylist.variants.forEach(
          (variant) {
            tracks.add(PlayerKidTrack(
                variant.format.id,
                variant.format.width,
                variant.format.height,
                variant.format.bitrate,
                variant.url.toString(),
                0,
                '',
                ''));
          },
        );
      }

      //For auto quality
      if (tracks.isNotEmpty) {
        tracks.insert(
            0, PlayerKidTrack("0", 0, 0, 0, parsedPlaylist.baseUri, 0, '', ''));
      }
    } catch (exception) {
      print("Exception on parseSubtitles: $exception");
    }
    return tracks;
  }
  //
  // ///Parse subtitles from provided m3u8 url
  // static Future<List<BetterPlayerAsmsSubtitle>> parseSubtitles(
  //     String data, String masterPlaylistUrl) async {
  //   final List<BetterPlayerAsmsSubtitle> subtitles = [];
  //   try {
  //     final parsedPlaylist = await HlsPlaylistParser.create()
  //         .parseString(Uri.parse(masterPlaylistUrl), data);
  //
  //     if (parsedPlaylist is HlsMasterPlaylist) {
  //       for (final Rendition element in parsedPlaylist.subtitles) {
  //         final hlsSubtitle = await _parseSubtitlesPlaylist(element);
  //         if (hlsSubtitle != null) {
  //           subtitles.add(hlsSubtitle);
  //         }
  //       }
  //     }
  //   } catch (exception) {
  //     BetterPlayerUtils.log("Exception on parseSubtitles: $exception");
  //   }
  //
  //   return subtitles;
  // }

  ///Parse HLS subtitles playlist. If subtitles are segmented (more than 1
  ///segment is present in playlist), then setup subtitles as segmented.
  ///Segmented subtitles are loading with JIT policy, when video is playing
  ///to prevent massive load od video start. Segmented subtitles will have
  ///filled segments list which contains start, end and url of subtitles based
  ///on time in playlist.
  // static Future<BetterPlayerAsmsSubtitle?> _parseSubtitlesPlaylist(
  //     Rendition rendition) async {
  //   try {
  //     final HlsPlaylistParser _hlsPlaylistParser = HlsPlaylistParser.create();
  //     final subtitleData =
  //         await BetterPlayerAsmsUtils.getDataFromUrl(rendition.url.toString());
  //     if (subtitleData == null) {
  //       return null;
  //     }
  //
  //     final parsedSubtitle =
  //         await _hlsPlaylistParser.parseString(rendition.url, subtitleData);
  //     final hlsMediaPlaylist = parsedSubtitle as HlsMediaPlaylist;
  //     final hlsSubtitlesUrls = <String>[];
  //
  //     final List<BetterPlayerAsmsSubtitleSegment> asmsSegments = [];
  //     final bool isSegmented = hlsMediaPlaylist.segments.length > 1;
  //     int microSecondsFromStart = 0;
  //     for (final Segment segment in hlsMediaPlaylist.segments) {
  //       final split = rendition.url.toString().split("/");
  //       var realUrl = "";
  //       for (var index = 0; index < split.length - 1; index++) {
  //         // ignore: use_string_buffers
  //         realUrl += "${split[index]}/";
  //       }
  //       realUrl += segment.url!;
  //       hlsSubtitlesUrls.add(realUrl);
  //
  //       if (isSegmented) {
  //         final int nextMicroSecondsFromStart =
  //             microSecondsFromStart + segment.durationUs!;
  //         microSecondsFromStart = nextMicroSecondsFromStart;
  //         asmsSegments.add(
  //           BetterPlayerAsmsSubtitleSegment(
  //             Duration(microseconds: microSecondsFromStart),
  //             Duration(microseconds: nextMicroSecondsFromStart),
  //             realUrl,
  //           ),
  //         );
  //       }
  //     }
  //
  //     int targetDuration = 0;
  //     if (parsedSubtitle.targetDurationUs != null) {
  //       targetDuration = parsedSubtitle.targetDurationUs! ~/ 1000;
  //     }
  //
  //     return BetterPlayerAsmsSubtitle(
  //       name: rendition.format.label,
  //       language: rendition.format.language,
  //       url: rendition.url.toString(),
  //       realUrls: hlsSubtitlesUrls,
  //       isSegmented: isSegmented,
  //       segmentsTime: targetDuration,
  //       segments: asmsSegments,
  //     );
  //   } catch (exception) {
  //     BetterPlayerUtils.log("Failed to process subtitles playlist: $exception");
  //     return null;
  //   }
  // }

  // static Future<List<BetterPlayerAsmsAudioTrack>> parseLanguages(
  //     String data, String masterPlaylistUrl) async {
  //   final List<BetterPlayerAsmsAudioTrack> audios = [];
  //   final parsedPlaylist = await HlsPlaylistParser.create()
  //       .parseString(Uri.parse(masterPlaylistUrl), data);
  //   if (parsedPlaylist is HlsMasterPlaylist) {
  //     for (int index = 0; index < parsedPlaylist.audios.length; index++) {
  //       final Rendition audio = parsedPlaylist.audios[index];
  //       audios.add(BetterPlayerAsmsAudioTrack(
  //         id: index,
  //         label: audio.name,
  //         language: audio.format.language,
  //         url: audio.url.toString(),
  //       ));
  //     }
  //   }
  //
  //   return audios;
  // }
}
