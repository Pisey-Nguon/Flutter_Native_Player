import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle_resource.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitle.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_factory.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_source.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_source_type.dart';

import 'player_kid_data_holder.dart';
import 'player_kid_track.dart';
import 'player_kid_utils.dart';

class FetchHlsMasterPlaylist {
  PlayerResource playerResource;
  List<QualityModel>? listQuality;

  FetchHlsMasterPlaylist({required this.playerResource});

  Future<List<QualityModel>> getListQuality() async {
    final List<QualityModel> listQuality = [];
    final result =
        await PlayerAsmsUtils.getDataFromUrl(playerResource.videoUrl, null);
    if (result != null) {
      final PlayerKidDataHolder _response =
          await PlayerAsmsUtils.parse(result, playerResource.videoUrl);
      _response.tracks?.forEach((element) {
        listQuality.add(QualityModel(
            width: element.width ?? 0,
            height: element.height ?? 0,
            bitrate: element.bitrate ?? 0,
            urlQuality: element.urlQuality ?? playerResource.videoUrl,
            urlMovie: playerResource.videoUrl,
            titleMovie: "No title",
            trackIndex: element.id != "" ? int.parse(element.id!) : 0,
            isSelected: false));
      });
    }
    if (listQuality.isEmpty) {
      listQuality.add(QualityModel(
          width: 0,
          height: 0,
          bitrate: 0,
          urlQuality: playerResource.videoUrl,
          urlMovie: playerResource.videoUrl,
          titleMovie: "No title",
          trackIndex: 0,
          isSelected: true));
    }
    this.listQuality = listQuality;
    return listQuality;
  }

  List<PlayerSubtitleResource> getListSubtitle() {
    return playerResource.playerSubtitleResources ?? [];
  }

  PlayerKidSubtitlesSource? betterPlayerSubtitlesSource;

  ///Subtitles lines for current data source.
  List<PlayerKidSubtitle> subtitlesLines = [];

  ///List of tracks available for current data source. Used only for HLS / DASH.
  List<PlayerKidTrack> _betterPlayerAsmsTracks = [];

  ///List of loaded ASMS segments
  final List<String> _asmsSegmentsLoaded = [];

  ///Flag which determines whether are ASMS segments loading
  bool _asmsSegmentsLoading = false;

  ///Setup subtitles to be displayed from given subtitle source.
  ///If subtitles source is segmented then don't load videos at start. Videos
  ///will load with just in time policy.
  Future<void> setupSubtitleSource(PlayerKidSubtitlesSource subtitlesSource,
      {bool sourceInitialize = false}) async {
    betterPlayerSubtitlesSource = subtitlesSource;
    subtitlesLines.clear();
    _asmsSegmentsLoaded.clear();
    _asmsSegmentsLoading = false;

    if (subtitlesSource.type != PlayerKidSubtitlesSourceType.none) {
      if (subtitlesSource.asmsIsSegmented == true) {
        return;
      }
      final subtitlesParsed =
          await PlayerKidSubtitlesFactory.parseSubtitles(subtitlesSource);
      subtitlesLines.addAll(subtitlesParsed);
    }

    // _postEvent(BetterPlayerEvent(BetterPlayerEventType.changedSubtitles));
    // if (!_disposed && !sourceInitialize) {
    //   _postControllerEvent(BetterPlayerControllerEvent.changeSubtitles);
    // }
  }

  List<PlayerKidSubtitlesSource> getSubtitleDataSource(
      List<PlayerSubtitleResource>? listSubtitleVideo) {
    List<PlayerKidSubtitlesSource> listSubtitle = [];
    listSubtitleVideo?.forEach((element) {
      listSubtitle.add(PlayerKidSubtitlesSource(
          type: PlayerKidSubtitlesSourceType.network,
          name: element.language,
          urls: [element.subtitleUrl],
          selectedByDefault: false));
    });
    return listSubtitle;
  }
}
