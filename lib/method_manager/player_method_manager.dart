
import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_native_player/hls/fetch_hls_master_playlist.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/model/subtitle_model.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_source.dart';
import '../constant.dart';
import 'download_state.dart';

class PlayerMethodManager{

  final methodChannel = MethodChannel(Constant.METHOD_CHANNEL_PLAYER);
  final eventChannel = EventChannel(Constant.EVENT_CHANNEL_PLAYER);
  FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  PlaybackState? _playbackState;
  int? _totalDuration;
  int? _currentPosition;
  List<QualityModel>? _listQuality;
  List<PlayerSubtitle>? _listSubtitle;
  double? _currentSpeed;
  Timer? _timer;
  int? _currentHeight;
  int? _currentWidth;
  bool isDownloadStarted = false;
  bool isShowController = true;
  bool isAbsorbing = false;
  bool isShowLoading = false;

  final StreamController<DurationState> _streamControllerDurationState = StreamController.broadcast();
  final StreamController<PlaybackState> _streamControllerPlaybackState = StreamController.broadcast();
  final StreamController<DownloadState> _streamControllerDownloadState = StreamController.broadcast();
  final StreamController<double> _streamControllerProgressDownloadState = StreamController.broadcast();

  Stream<DurationState> get streamDurationState => _streamControllerDurationState.stream;
  Stream<PlaybackState> get streamPlaybackState => _streamControllerPlaybackState.stream;
  Stream<DownloadState> get streamDownloadState => _streamControllerDownloadState.stream;
  Stream<double> get streamProgressDownloadState => _streamControllerProgressDownloadState.stream;

  Function(BetterPlayerSubtitlesSource source)? _subtitleSelectedListener;


  PlayerMethodManager({required this.fetchHlsMasterPlaylist}):super(){
    initPlayerListener();
  }

  void initPlayerListener(){
    _startPlayerStateListener();
    startListenerPosition();
  }


  Future<void>startDownload(QualityModel itemQualitySelected) async{
    final map = HashMap();
    map[Constant.KEY_URL_MOVIE] = itemQualitySelected.urlMovie;
    map[Constant.KEY_TITLE_MOVIE] = itemQualitySelected.titleMovie;
    map[Constant.KEY_TRACK_INDEX] = itemQualitySelected.trackIndex;
    map[Constant.KEY_BITRATE] = itemQualitySelected.bitrate;
    try{
      final String result = await methodChannel.invokeMethod(Constant.METHOD_START_DOWNLOAD,map);
      isDownloadStarted = true;
    }on PlatformException catch (e){
    }
  }

  Future<void>setCancelDownload() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_CANCEL_DOWNLOAD);
      isDownloadStarted = false;
    }on PlatformException catch(e){

    }
  }


  Future<void> play() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_PLAY);
    }on PlatformException catch(e){}
  }

  Future<void> pause() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_PAUSE);
    }on PlatformException catch(e){}
  }

  Future<void> replay() async{
    int position = (_currentPosition ?? 0) - 10000;
    if(position < 0){
      position = 0;
    }
    try{
      await methodChannel.invokeMethod(Constant.METHOD_SEEK_TO,position);
    }on PlatformException catch(e){}
  }

  Future<void> forward() async{
    int position = (_currentPosition ?? 0) + 10000;
    if(_totalDuration != null){
      if(position > (_totalDuration ?? 0)){
        position  = _totalDuration!;
      }
    }
    try{
      await methodChannel.invokeMethod(Constant.METHOD_SEEK_TO,position);
    }on PlatformException catch(e){}
  }

  Future<void> seekTo(int position) async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_SEEK_TO,position);
    }on PlatformException catch(e){}
  }

  Future<void> setPlaybackSpeed(double speed) async{
    _currentSpeed = speed;
    try{
      await methodChannel.invokeMethod(Constant.METHOD_CHANGE_PLAYBACK_SPEED,speed);
    }on PlatformException catch(e){}
  }

  Future<void> releasePlayer() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_RELEASE_PLAYER);
    }on PlatformException catch(e){

    }
  }

  Future<void> initPlayer() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_INIT_PLAYER);
    }on PlatformException catch(e){

    }
  }

  Future<void> changeQuality(QualityModel itemQualitySelected) async{
    _currentHeight = itemQualitySelected.height;
    _currentWidth = itemQualitySelected.width;
    try{
      final HashMap<String,dynamic> itemQualitySelectedHashMap = HashMap();
      itemQualitySelectedHashMap[Constant.KEY_WIDTH] = itemQualitySelected.width;
      itemQualitySelectedHashMap[Constant.KEY_HEIGHT] = itemQualitySelected.height;
      itemQualitySelectedHashMap[Constant.KEY_BITRATE] = itemQualitySelected.bitrate;
      itemQualitySelectedHashMap[Constant.KEY_URL_QUALITY] = itemQualitySelected.urlQuality;
      await methodChannel.invokeMethod(Constant.METHOD_CHANGE_QUALITY,itemQualitySelectedHashMap);
    }on PlatformException catch(e){}
  }

  
  Future<void> changeSubtitle(BetterPlayerSubtitlesSource itemSubtitleSelected) async{
    try{
      final itemSubtitleSelectedHashMap = HashMap();
      itemSubtitleSelectedHashMap[Constant.KEY_SUBTITLE_LABEL] = itemSubtitleSelected.name;
      itemSubtitleSelectedHashMap[Constant.KEY_SUBTITLE_INDEX] = itemSubtitleSelected.type?.index;
      await methodChannel.invokeMethod(Constant.METHOD_CHANGE_SUBTITLE,itemSubtitleSelectedHashMap);
      _subtitleSelectedListener?.call(itemSubtitleSelected);
    }on PlatformException catch(e){}
  }

  Future<void> showDevices() async{
    try{
      await methodChannel.invokeMethod(Constant.METHOD_SHOW_DEVICES);
    }on PlatformException catch(e){}
  }

  bool isPlaying(){
    if(_playbackState == PlaybackState.play){
      return true;
    }else{
      return false;
    }
  }
  int totalDuration(){
    return _totalDuration ?? 0;
  }
  int currentPosition(){
    return _currentPosition ?? 0;
  }
  double currentSpeed(){
    return _currentSpeed ?? 1;
  }
  List<QualityModel> getListQuality(){
    return _listQuality ?? List.empty();
  }
  int getCurrentHeight(){
    return _currentHeight ?? 0;
  }
  int getCurrentWidth(){
    return _currentWidth ?? 0;
  }

  StreamController<DurationState> getStreamControllerDurationState(){
    return _streamControllerDurationState;
  }

  void pauseListenerPosition(){
    _timer?.cancel();
  }
  void startListenerPosition(){
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      _setPositionListener();
    });
  }

  Future<void> _startPlayerStateListener() async {
    _listQuality = await fetchHlsMasterPlaylist.getListQuality();
    _listSubtitle = fetchHlsMasterPlaylist.getListSubtitle();
    eventChannel.receiveBroadcastStream().listen((event) {
      final data = event as LinkedHashMap;
      final eventType = data[Constant.KEY_EVENT_TYPE] as String;
      switch (eventType){
        case (Constant.EVENT_READY_TO_PLAY):{
          final readyToPlay = PlaybackState.readyToPlay;
          _streamControllerPlaybackState.sink.add(readyToPlay);
          _playbackState = readyToPlay;
        }
        break;
        case (Constant.EVENT_PLAY):{
          final play = PlaybackState.play;
          _streamControllerPlaybackState.sink.add(play);
          _playbackState = play;
        }
        break;
        case (Constant.EVENT_PAUSE):{
          final pause = PlaybackState.pause;
          _streamControllerPlaybackState.sink.add(pause);
          _playbackState = pause;
        }
        break;
        case (Constant.EVENT_BUFFERING):{
          final buffering = PlaybackState.buffering;
          _streamControllerPlaybackState.sink.add(buffering);
          _playbackState = buffering;
        }
        break;
        case (Constant.EVENT_FINISH):{
          final finish = PlaybackState.finish;
          _streamControllerPlaybackState.sink.add(finish);
          _playbackState = finish;
        }
        break;
        case Constant.EVENT_TV_SHOW_BUTTON_CAST:
          final showButtonCast = PlaybackState.show_button_cast;
          _streamControllerPlaybackState.sink.add(showButtonCast);
          break;
        case Constant.EVENT_TV_HIDE_BUTTON_CAST:
          final hideButtonCast = PlaybackState.hide_button_cast;
          _streamControllerPlaybackState.sink.add(hideButtonCast);
          break;
        case Constant.EVENT_TV_CONNECTED:
          final tvConnected = PlaybackState.tv_connected;
          _streamControllerPlaybackState.sink.add(tvConnected);
        break;
        case Constant.EVENT_TV_DISCONNECTED:
          final tvDisconnected = PlaybackState.tv_disconnected;
          _streamControllerPlaybackState.sink.add(tvDisconnected);
          break;
        case (Constant.EVENT_PROGRESS_DOWNLOAD):{
          final value = data[Constant.KEY_VALUE_OF_EVENT] as double;
          _streamControllerProgressDownloadState.sink.add(value);
        }
        break;
        case Constant.EVENT_DOWNLOAD_STARTED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadStarted);
        }
        break;
        case Constant.EVENT_DOWNLOAD_CANCELED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadCanceled);
        }
        break;
        case Constant.EVENT_DOWNLOAD_COMPLETED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadCompleted);
        }
        break;
        case Constant.EVENT_DOWNLOAD_FAILED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadFailed);
        }
        break;
        case Constant.EVENT_DOWNLOAD_PAUSED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadPaused);
        }
        break;
        case Constant.EVENT_DOWNLOAD_RESUMED:{
          _streamControllerDownloadState.sink.add(DownloadState.downloadResumed);
        }
        break;
      }
    });
  }

  Future<void> _setPositionListener() async{
    try{
      final result = await methodChannel.invokeMethod(Constant.METHOD_GET_DURATION_STATE) as LinkedHashMap;
      _currentPosition = result[Constant.KEY_CURRENT_POSITION] as int;
      final totalDuration = result[Constant.KEY_TOTAL_DURATION] as int;
      if(totalDuration != -1){
        _totalDuration = totalDuration;
      }
      final bufferUpdate = result[Constant.KEY_BUFFER_UPDATE] as int;
      final DurationState durationState  = DurationState(progress: Duration(milliseconds: _currentPosition ?? 0), buffered: Duration(milliseconds: bufferUpdate),total: Duration(milliseconds: _totalDuration ?? 0));
      _streamControllerDurationState.sink.add(durationState);
    }on PlatformException catch(e){}
  }

  Future<void>isDownloadCompleted(String url,void onData(bool isDownloadCompleted)) async{
    try{
      final bool result = await methodChannel.invokeMethod(Constant.METHOD_CHECK_IS_DOWNLOAD,url);
      onData.call(result);
    }on PlatformException catch(e){}
  }

  void setSubtitleSelectedListener(void onData(BetterPlayerSubtitlesSource source)){
    _subtitleSelectedListener = onData;
  }

  void dispose(){
    _streamControllerDurationState.close();
    _streamControllerDownloadState.close();
    _streamControllerPlaybackState.close();
    _streamControllerProgressDownloadState.close();
  }
}