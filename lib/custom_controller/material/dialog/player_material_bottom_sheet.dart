import 'package:flutter/material.dart';
import 'package:flutter_native_player/hls/fetch_hls_master_playlist.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';
import 'package:flutter_native_player/model/playback_speed.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle_resource.dart';
import 'package:flutter_native_player/model/quality_model.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_source.dart';

import 'player_clickable_widget.dart';

class PlayerMaterialBottomSheet {
  final BuildContext context;

  final PlayerMethodManager playerMethodManager;
  final FetchHlsMasterPlaylist fetchHlsMasterPlaylist;

  PlayerMaterialBottomSheet(
      {required this.context,
      required this.playerMethodManager,
      required this.fetchHlsMasterPlaylist});

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

  void _showTwoSingleScrollViewBottomSheet(
      List<Widget> children1, List<Widget> children2) {
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
        children1.isNotEmpty ? Expanded(child: scrollView1) : const SizedBox(),
        Expanded(child: scrollView2)
      ],
    );
    Widget safeArea = SafeArea(
      child: combineScrollView,
      top: false,
    );
    showModalBottomSheet<void>(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return safeArea;
        });
  }

  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
    );
  }

  Widget _buildTrackRow(QualityModel itemQuality, String preferredName) {
    final bool isSelected = itemQuality.isSelected;

    return PlayerMaterialClickableWidget(
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
            const Expanded(child: SizedBox()),
            isSelected == true ? const Icon(Icons.check) : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitlesSourceRow(PlayerKidSubtitlesSource subtitlesSource) {
    final selectedSourceType =
        fetchHlsMasterPlaylist.betterPlayerSubtitlesSource;
    final bool isSelected = (subtitlesSource.name == selectedSourceType?.name);
    return PlayerMaterialClickableWidget(
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
            const Expanded(child: SizedBox()),
            isSelected == true ? const Icon(Icons.check) : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedRow(PlaybackSpeed playbackSpeedModel) {
    final bool isSelected =
        playerMethodManager.currentSpeed() == playbackSpeedModel.speedValue;
    return PlayerMaterialClickableWidget(
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
            const Expanded(child: SizedBox()),
            isSelected == true ? const Icon(Icons.check) : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildQualityDownloadRow(QualityModel itemQualitySelected,
      PlayerResource playerResource, String preferredName) {
    bool isSelected = false;

    return PlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        playerMethodManager.startDownload(
            playerResource, itemQualitySelected.trackIndex);
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
            const Expanded(child: SizedBox()),
            isSelected == true ? const Icon(Icons.check) : const SizedBox()
          ],
        ),
      ),
    );
  }

  void showSubtitlesSelectionWidget(List<PlayerSubtitleResource> listSubtitle) {
    final subtitles =
        List.of(fetchHlsMasterPlaylist.getSubtitleDataSource(listSubtitle))
            .toList();
    subtitles.insert(0, PlayerKidSubtitlesSource(name: "Off"));
    _showModalBottomSheet(
        subtitles.map((source) => _buildSubtitlesSourceRow(source)).toList());
  }

  void showMoreTypeSelectionWidget(
      List<QualityModel> listQuality, String currentUrlQuality) {
    final List<Widget> childQuality = [];
    // HLS / DASH
    if (listQuality.length > 1) {
      for (var index = 0; index < listQuality.length; index++) {
        final track = listQuality[index];

        String preferredName;
        if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
          preferredName = "Auto";
        } else {
          preferredName = "${track.height}p";
        }
        if (currentUrlQuality == track.urlQuality) {
          track.isSelected = true;
        } else {
          track.isSelected = false;
        }
        childQuality.add(_buildTrackRow(track, preferredName));
      }
    }

    List<PlaybackSpeed> listSpeed = [];
    listSpeed.add(PlaybackSpeed(titleSpeed: "0.25x", speedValue: 0.25));
    listSpeed.add(PlaybackSpeed(titleSpeed: "0.5x", speedValue: 0.5));
    listSpeed.add(PlaybackSpeed(titleSpeed: "0.75x", speedValue: 0.75));
    listSpeed.add(PlaybackSpeed(titleSpeed: "Normal", speedValue: 1));
    listSpeed.add(PlaybackSpeed(titleSpeed: "1.25x", speedValue: 1.25));
    listSpeed.add(PlaybackSpeed(titleSpeed: "1.5x", speedValue: 1.5));
    listSpeed.add(PlaybackSpeed(titleSpeed: "1.75x", speedValue: 1.75));
    listSpeed.add(PlaybackSpeed(titleSpeed: "2x", speedValue: 2));

    final childPlaybackSpeed = listSpeed.map((e) => _buildSpeedRow(e)).toList();

    _showTwoSingleScrollViewBottomSheet(childQuality, childPlaybackSpeed);
  }

  void showQualityDownloadSelectionWidget(
      List<QualityModel>? listQuality, PlayerResource playerResource) {
    if (listQuality == null) {
      return;
    }

    final List<Widget> childQuality = [];
    for (var index = 0; index < listQuality.length; index++) {
      final track = listQuality[index];

      String preferredName;
      if (track.height != 0 && track.width != 0 && track.bitrate != 0) {
        preferredName = "${track.height}p";
        childQuality.add(
            _buildQualityDownloadRow(track, playerResource, preferredName));
      }
    }

    _showModalBottomSheet(childQuality);
  }
}
