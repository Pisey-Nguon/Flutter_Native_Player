import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/material/dialog/player_material_bottom_sheet.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_widget.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:get/get.dart';

import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/download_state.dart';
import 'method_manager/playback_state.dart';
import 'method_manager/player_method_manager.dart';
import 'model/player_subtitle.dart';

class FlutterNativeGetxController extends GetxController{
  final BuildContext context;
  final PlayerResource playerResource;
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;
  late PlayerMaterialBottomSheet playerMaterialBottomSheet;

  FlutterNativeGetxController({required this.context,required this.playerResource});

  ///Duration for subtitle
  Duration? currentPosition;

  ///Duration state for count down time
  DurationState? durationState;

  ///Download state for validate widget
  DownloadState? downloadState;

  ///Timer count for showing controller timeout
  Timer? controllerTimeout;

  ///State for player overlay controller
  bool isShowController = true;

  ///State for loading widget that on over player and overlay controller
  bool isShowLoading = false;

  ///Component widget like button, progress bar, etc as singleton
  final playerWidget = PlayerWidget();

  Icon iconControlPlayer = const Icon(Icons.pause_outlined, color: Colors.white,);
  Icon iconDownloader = const Icon(Icons.arrow_downward, color: Colors.white,);
  bool isVisibleButtonPlay = true;
  bool isShowProgressDownload = true;
  double percentageDownloaded = 0;
  bool isIndicatermateCircularProgress = false;


  @override
  void onInit() {
    fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(playerResource: playerResource);
    playerMethodManager = PlayerMethodManager(fetchHlsMasterPlaylist: fetchHlsMasterPlaylist);
    playerMaterialBottomSheet = PlayerMaterialBottomSheet(
        context: context,
        fetchHlsMasterPlaylist: playerMethodManager.fetchHlsMasterPlaylist,
        playerMethodManager: playerMethodManager);

    ///Called when player subtitle has changed, i.e user change from english to khmer
    playerMethodManager.setSubtitleSelectedListener((source) {
      fetchHlsMasterPlaylist.setupSubtitleSource(source);
      update();
    });

    ///Called when player state has changed, i.e. new player position, etc.
    playerMethodManager.streamDurationState.listen((event) {
      currentPosition = Duration(milliseconds: event.progress.inMilliseconds);
      durationState = event;
      update();
    });

    _handleDownloadEvent();
    _handlePlaybackStateEvent();
    handleControllerTimeout();
    super.onInit();
  }

  void _updateEventTypePlay() {
    iconControlPlayer = const Icon(
      Icons.pause_outlined,
      color: Colors.white,
    );
  }

  void _updateEventTypePause() {
    iconControlPlayer = const Icon(
      Icons.play_arrow,
      color: Colors.white,
    );
    update();
  }

  void _updateEventTypeFinished() {
    iconControlPlayer = const Icon(
      Icons.replay,
      color: Colors.white,
    );
  }

  void _handlePlaybackStateEvent() {
    playerMethodManager.streamPlaybackState.listen((event) {
      switch (event) {
        case PlaybackState.readyToPlay:{
            isShowLoading = false;
            isVisibleButtonPlay = true;
          }
          break;
        case PlaybackState.play:{
            handleControllerTimeout();
            _updateEventTypePlay();
          }
          break;
        case PlaybackState.pause:{
            controllerTimeout?.cancel();
            _updateEventTypePause();
          }
          break;
        case PlaybackState.buffering:{
            isShowLoading = true;
            isVisibleButtonPlay = false;
          }
          break;
        case PlaybackState.finish:{
            _updateEventTypeFinished();
          }
          break;
      }
      update();
    });
  }

  void _handleDownloadEvent() {
    playerMethodManager.streamProgressDownloadState.listen((event) {
      percentageDownloaded = event;
      update();
    });
    playerMethodManager.streamDownloadState.listen((event) {
      downloadState = event;
      if(event == DownloadState.downloadCompleted){
        playerMethodManager.fetchHlsMasterPlaylist.listQuality?.clear();
      }
      update();
    });
  }

  void handleControllerTimeout(){
    controllerTimeout?.cancel();
    controllerTimeout = Timer.periodic(const Duration(seconds: 8), (timer) {
      // isShowController = false;
      update();
    });
  }
}