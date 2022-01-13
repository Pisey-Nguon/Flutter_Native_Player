import 'package:flutter_native_player/subtitles/better_player_subtitles_configuration.dart';
import 'package:get/get.dart';

import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/player_method_manager.dart';
import 'model/subtitle_model.dart';

class FlutterNativeGetxController extends GetxController{
  final String url;
  final List<PlayerSubtitle>? subtitles;
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;

  FlutterNativeGetxController({required this.url,required this.subtitles});

  ///Duration for subtitle
  Duration? currentPosition;

  @override
  void onInit() {
    subtitles?.insert(0, PlayerSubtitle(language: "Off", urlSubtitle: ""));
    fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(titleMovie: "", urlMovie: url, listSubtitle: subtitles);
    playerMethodManager = PlayerMethodManager(fetchHlsMasterPlaylist: fetchHlsMasterPlaylist);

    ///Called when player subtitle has changed, i.e user change from english to khmer
    playerMethodManager.setSubtitleSelectedListener((source) {
      fetchHlsMasterPlaylist.setupSubtitleSource(source);
      update();
    });

    ///Called when player state has changed, i.e. new player position, etc.
    playerMethodManager.streamDurationState.listen((event) {
      currentPosition = Duration(milliseconds: event.progress.inMilliseconds);
      update();
    });
    super.onInit();
  }
}