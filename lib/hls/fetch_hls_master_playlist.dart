

import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitle.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_factory.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_source.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_source_type.dart';

import 'better_player_asms_data_holder.dart';
import 'better_player_asms_track.dart';
import 'better_player_asms_utils.dart';

class FetchHlsMasterPlaylist{

  PlayerResource playerResource;
  List<QualityModel>? listQuality;


  FetchHlsMasterPlaylist({required this.playerResource});

  Future<List<QualityModel>> getListQuality() async{
    final List<QualityModel> listQuality = [];
    final result = await BetterPlayerAsmsUtils.getDataFromUrl(playerResource.mediaUrl,null);
    if (result != null){

      final BetterPlayerAsmsDataHolder _response = await BetterPlayerAsmsUtils.parse(result, playerResource.mediaUrl);
      _response.tracks?.forEach((element) {
        listQuality.add(QualityModel(width: element.width ?? 0, height: element.height ?? 0, bitrate: element.bitrate ?? 0,urlQuality: element.urlQuality ?? playerResource.mediaUrl,urlMovie: playerResource.mediaUrl,titleMovie: playerResource.mediaName, trackIndex:element.id != "" ? int.parse(element.id!):0,isSelected: false));
      });
    }
    if(listQuality.isEmpty){
      listQuality.add(QualityModel(width: 0, height: 0, bitrate: 0,urlQuality: playerResource.mediaUrl,urlMovie: playerResource.mediaUrl,titleMovie: playerResource.mediaName, trackIndex:0,isSelected: true));
    }
    this.listQuality = listQuality;
    return listQuality;
  }

  List<PlayerSubtitle> getListSubtitle(){
    return playerResource.subtitles ?? [];
  }



  BetterPlayerSubtitlesSource? betterPlayerSubtitlesSource;

  ///Subtitles lines for current data source.
  List<BetterPlayerSubtitle> subtitlesLines = [];

  ///List of tracks available for current data source. Used only for HLS / DASH.
  List<BetterPlayerAsmsTrack> _betterPlayerAsmsTracks = [];

  ///List of loaded ASMS segments
  final List<String> _asmsSegmentsLoaded = [];

  ///Flag which determines whether are ASMS segments loading
  bool _asmsSegmentsLoading = false;

  ///Setup subtitles to be displayed from given subtitle source.
  ///If subtitles source is segmented then don't load videos at start. Videos
  ///will load with just in time policy.
  Future<void> setupSubtitleSource(BetterPlayerSubtitlesSource subtitlesSource,
      {bool sourceInitialize = false}) async {
    betterPlayerSubtitlesSource = subtitlesSource;
    subtitlesLines.clear();
    _asmsSegmentsLoaded.clear();
    _asmsSegmentsLoading = false;

    if (subtitlesSource.type != BetterPlayerSubtitlesSourceType.none) {
      if (subtitlesSource.asmsIsSegmented == true) {
        return;
      }
      final subtitlesParsed =
      await BetterPlayerSubtitlesFactory.parseSubtitles(subtitlesSource);
      subtitlesLines.addAll(subtitlesParsed);
    }

    // _postEvent(BetterPlayerEvent(BetterPlayerEventType.changedSubtitles));
    // if (!_disposed && !sourceInitialize) {
    //   _postControllerEvent(BetterPlayerControllerEvent.changeSubtitles);
    // }
  }

  List<BetterPlayerSubtitlesSource> getSubtitleDataSource(List<PlayerSubtitle>? listSubtitleVideo){
    List<BetterPlayerSubtitlesSource> listSubtitle = [];
    listSubtitleVideo?.forEach((element) {
      listSubtitle.add(BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: element.language,
          urls: [element.urlSubtitle],
          selectedByDefault: false
      ));
    });
    return listSubtitle;
  }
}