
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_native_player/hls/fetch_hls_master_playlist.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';
import 'package:flutter_native_player/model/playback_speed_model.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/model/subtitle_model.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_source.dart';
import 'better_player_clickable_widget.dart';
import 'package:collection/collection.dart' show IterableExtension;

class PlayerMaterialBottomSheet{
  final BuildContext context;

  final PlayerMethodManager playerMethodManager;
  final FetchHlsMasterPlaylist fetchHlsMasterPlaylist;

  PlayerMaterialBottomSheet({required this.context,required this.playerMethodManager,required this.fetchHlsMasterPlaylist});


  void _showModalBottomSheet(List<Widget> children) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          ),
        );
      },
    );
  }

  void _showTwoSingleScrollViewBottomSheet(List<Widget> children1,List<Widget> children2){
    Widget scrollView1 = SingleChildScrollView(
      child: Column(
        children: children1,
      ),
    );

    Widget scrollView2 = SingleChildScrollView(
      child: Column(
        children: children2,
      ),
    );
    Widget combineScrollView = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: scrollView1),
        Expanded(child: scrollView2)
      ],
    );
    Widget safeArea = SafeArea(child: combineScrollView,top: false,);
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      builder: (context){
        return safeArea;
      }
    );
  }


  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
    );
  }
  // Widget _buildResolutionSelectionRow(String name, String url) {
  //   final bool isSelected =
  //       url == _betterPlayerController.betterPlayerDataSource?.url;
  //   return BetterPlayerMaterialClickableWidget(
  //     onTap: () {
  //       Navigator.of(context).pop();
  //       // _betterPlayerController!.setResolution(url);
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  //       child: Row(
  //         children: [
  //           const SizedBox(width: 16),
  //           Text(
  //             name,
  //             style: _getOverflowMenuElementTextStyle(isSelected),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTrackRow(QualityModel itemQuality,String preferredName) {
    final bool isSelected = itemQuality.isSelected;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        playerMethodManager.changeQuality(itemQuality);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              preferredName,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
            Expanded(child: const SizedBox()),
            isSelected == true ? Icon(Icons.check) : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitlesSourceRow(BetterPlayerSubtitlesSource subtitlesSource) {
    final selectedSourceType = fetchHlsMasterPlaylist.betterPlayerSubtitlesSource;
    final bool isSelected = (subtitlesSource.name == selectedSourceType?.name);
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        fetchHlsMasterPlaylist.setupSubtitleSource(subtitlesSource);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              subtitlesSource.name ?? "",
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
            Expanded(child: const SizedBox()),
            isSelected == true ? Icon(Icons.check) : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedRow(PlaybackSpeedModel playbackSpeedModel) {
    final bool isSelected = playerMethodManager.currentSpeed() == playbackSpeedModel.speedValue;

    print("testSpeed currentSpeed ${playerMethodManager.currentSpeed()} buildspeed ${playbackSpeedModel.speedValue}");
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        // _betterPlayerController.setSpeed(playbackSpeedModel.speedValue);
        playerMethodManager.setPlaybackSpeed(playbackSpeedModel.speedValue);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              playbackSpeedModel.titleSpeed,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
            Expanded(child: const SizedBox()),
            isSelected == true ? Icon(Icons.check) : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildQualityDownloadRow(QualityModel itemQualitySelected, String preferredName) {

    final bool isSelected = false;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        playerMethodManager.startDownload(itemQualitySelected);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              preferredName,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
            Expanded(child: const SizedBox()),
            isSelected == true ? Icon(Icons.check) : SizedBox()
          ],
        ),
      ),
    );
  }

  // void showQualitiesSelectionWidget() {
  //   // HLS / DASH
  //   final List<String> asmsTrackNames = _betterPlayerController.betterPlayerDataSource!.asmsTrackNames ?? [];
  //   final List<BetterPlayerAsmsTrack> asmsTracks = _betterPlayerController.betterPlayerAsmsTracks;
  //   final List<Widget> children = [];
  //   for (var index = 0; index < asmsTracks.length; index++) {
  //     final track = asmsTracks[index];
  //
  //     String? preferredName;
  //     if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
  //       preferredName = _betterPlayerController.translations.qualityAuto;
  //     } else {
  //       preferredName = asmsTrackNames.length > index ? asmsTrackNames[index] : null;
  //     }
  //     children.add(_buildTrackRow(asmsTracks[index], preferredName));
  //   }
  //
  //   // // normal videos
  //   // final resolutions = _betterPlayerController.betterPlayerDataSource!.resolutions;
  //   // resolutions?.forEach((key, value) {
  //   //   children.add(_buildResolutionSelectionRow(key, value));
  //   // });
  //
  //   if (children.isEmpty) {
  //     children.add(
  //       _buildTrackRow(BetterPlayerAsmsTrack.defaultTrack(),
  //           _betterPlayerController.translations.qualityAuto),
  //     );
  //   }
  //
  //   _showModalBottomSheet(children);
  // }

  void showSubtitlesSelectionWidget(List<SubtitleModel> listSubtitle) {
    final subtitles = List.of(fetchHlsMasterPlaylist.getSubtitleDataSource(listSubtitle)).toList();
    // // final noneSubtitlesElementExists = subtitles.firstWhereOrNull(
    // //         (source) => source.type == BetterPlayerSubtitlesSourceType.none) != null;
    // // if (!noneSubtitlesElementExists) {
    // //   subtitles.add(BetterPlayerSubtitlesSource(type: BetterPlayerSubtitlesSourceType.none));
    // // }
    _showModalBottomSheet(
        subtitles.map((source) => _buildSubtitlesSourceRow(source)).toList());
  }


  void showMoreTypeSelectionWidget(List<QualityModel>? listQuality,int currentHeight){
    // HLS / DASH
    if(listQuality == null){
      return;
    }

    final List<Widget> childQuality = [];
    for (var index = 0; index < listQuality.length; index++) {
      final track = listQuality[index];

      String preferredName;
      if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
        preferredName = "Auto";
      } else {
        preferredName = "${track.height}p";
      }
      if(currentHeight == track.height){
        track.isSelected = true;
      }else{
        track.isSelected = false;
      }
      childQuality.add(_buildTrackRow(track, preferredName));
    }

    // // normal videos
    // final resolutions = _betterPlayerController.betterPlayerDataSource!.resolutions;
    // resolutions?.forEach((key, value) {
    //   childQuality.add(_buildResolutionSelectionRow(key, value));
    // });


    List<PlaybackSpeedModel> listSpeed = [];
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "0.25x", speedValue: 0.25));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "0.5x", speedValue: 0.5));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "0.75x", speedValue: 0.75));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "Normal",speedValue: 1));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "1.25x",speedValue: 1.25));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "1.5x",speedValue: 1.5));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "1.75x",speedValue: 1.75));
    listSpeed.add(PlaybackSpeedModel(titleSpeed: "2x", speedValue: 2));

    final childPlaybackSpeed = listSpeed.map((e) => _buildSpeedRow(e)).toList();

    _showTwoSingleScrollViewBottomSheet(childQuality, childPlaybackSpeed);

  }

  void showQualityDownloadSelectionWidget(List<QualityModel>? listQuality){
    if(listQuality == null){
      return;
    }

    final List<Widget> childQuality = [];
    for (var index = 0; index < listQuality.length; index++) {
      final track = listQuality[index];

      String preferredName;
      if (track.height != 0 && track.width != 0 && track.bitrate != 0) {
        preferredName = "${track.height}p";
        childQuality.add(_buildQualityDownloadRow(track, preferredName));
      }

    }

    _showModalBottomSheet(childQuality);
  }
}