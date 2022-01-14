import 'package:flutter_native_player/model/player_resource.dart';
import 'package:get/get.dart';

import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/player_method_manager.dart';
import 'model/player_subtitle.dart';

class FlutterNativeGetxController extends GetxController{
  final PlayerResource playerResource;
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;

  FlutterNativeGetxController({required this.playerResource});

  ///Duration for subtitle
  Duration? currentPosition;

  @override
  void onInit() {
    playerResource.subtitles.insert(0, PlayerSubtitle(language: "Off", urlSubtitle: ""));
    fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(playerResource: playerResource);
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