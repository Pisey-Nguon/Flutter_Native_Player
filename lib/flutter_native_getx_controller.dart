import 'package:get/get.dart';

import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/player_method_manager.dart';
import 'model/subtitle_model.dart';

class FlutterNativeGetxController extends GetxController{
  final String url;
  final List<SubtitleModel>? subtitles;
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;

  FlutterNativeGetxController({required this.url,required this.subtitles});

  @override
  void onInit() {
    fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(titleMovie: "", urlMovie: url, listSubtitle: subtitles);
    playerMethodManager = PlayerMethodManager(fetchHlsMasterPlaylist: fetchHlsMasterPlaylist);
    playerMethodManager.setSubtitleSelectedListener((source) {
      fetchHlsMasterPlaylist.setupSubtitleSource(source);
      update();
    });
    super.onInit();
  }
}