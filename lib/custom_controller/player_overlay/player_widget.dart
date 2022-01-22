import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/configuration/player_progress_colors.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/method_manager/download_state.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/utils/time_utils.dart';

import '../material/progress_bar/audio_video_progress_bar.dart';

class PlayerWidget {
  static final PlayerWidget _singleton = PlayerWidget._internal();

  factory PlayerWidget() {
    return _singleton;
  }

  PlayerWidget._internal();

  Widget textView(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget countDownWidget(DurationState? durationState) {
    final int timeCountDownMs = (durationState?.total?.inMilliseconds ?? 0) -
        (durationState?.progress.inMilliseconds ?? 0);
    final String remainTime = TimeUtils.formatDurationCount(timeCountDownMs);
    return Container(
      alignment: Alignment.centerRight,
      width: 70,
      height: 70,
      child: textView(remainTime),
    );
  }

  Widget currentTimeWidget(DurationState? durationState) {
    final time = TimeUtils.formatDurationCount(
        durationState?.progress.inMilliseconds ?? 0);
    return Container(
      padding: const EdgeInsets.only(right: 10),
      alignment: Alignment.centerLeft,
      height: 50,
      constraints: const BoxConstraints(
        minWidth: 45,
      ),
      child: textView(time),
    );
  }

  Widget totalTimeWidget(DurationState? durationState) {
    final time = TimeUtils.formatDurationCount(
        durationState?.total?.inMilliseconds ?? 0);
    return Container(
      padding: const EdgeInsets.only(left: 10),
      alignment: Alignment.centerRight,
      height: 50,
      constraints: const BoxConstraints(minWidth: 45),
      child: textView(time),
    );
  }

  Widget buttonClick(Icon icon, double? iconSize, VoidCallback press) {
    return IconButton(
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      onPressed: press,
      icon: icon,
      iconSize: iconSize ?? 24,
    );
  }

  Widget button(Icon icon, double? iconSize) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
      iconSize: iconSize ?? 24,
    );
  }

  Widget circleProgressBar(double progress, bool isIndicatermate) {
    return SizedBox(
      height: 27,
      width: 27,
      child: isIndicatermate
          ? const CircularProgressIndicator()
          : CircularProgressIndicator(
              value: progress / 100,
            ),
    );
  }

  ProgressBar progressBar(
      {required FlutterNativeGetxController controller,
      PlayerProgressColors? progressColors,
      required void Function(Duration duration) onSeekListener}) {
    PlayerProgressColors _progressColors;
    if (progressColors != null) {
      _progressColors = progressColors;
    } else {
      _progressColors = PlayerProgressColors();
    }

    Duration progress = controller.durationState?.progress ?? Duration.zero;
    Duration buffered = controller.durationState?.buffered ?? Duration.zero;
    Duration total = controller.durationState?.total ?? Duration.zero;
    return ProgressBar(
      progress: progress,
      buffered: buffered,
      total: total,
      onSeek: (duration) {
        progress = duration;
        onSeekListener.call(duration);
        controller.playerMethodManager
            .getStreamControllerDurationState()
            .sink
            .add(DurationState(
                progress: progress, buffered: buffered, total: total));
      },
      onDragStart: (_) {
        controller.playerMethodManager.pauseListenerPosition();
      },
      onDragEnd: () {
        controller.playerMethodManager.startListenerPosition();
      },
      baseBarColor: _progressColors.baseBarColor,
      progressBarColor: _progressColors.playedColor,
      bufferedBarColor: _progressColors.bufferedColor,
      barHeight: 4,
      thumbRadius: 6,
      thumbGlowRadius: 12,
      thumbGlowColor: _progressColors.thumbColor,
      thumbColor: _progressColors.thumbColor,
      timeLabelLocation: TimeLabelLocation.none,
    );
  }

  Widget downloadWidget(
      {DownloadState? downloadState,
      required double percentageDownloaded,
      required VoidCallback openOptionQuality,
      required VoidCallback retryDownload,
      required VoidCallback cancelDownload}) {
    switch (downloadState) {
      case DownloadState.downloadQueued:
        return Stack(alignment: Alignment.center, children: [
          circleProgressBar(0, true),
          buttonClick(
              const Icon(
                Icons.stop,
                color: Colors.transparent,
              ),
              24, () {
            cancelDownload.call();
          })
        ]);
      case DownloadState.downloadStarted:
        return Stack(alignment: Alignment.center, children: [
          circleProgressBar(percentageDownloaded, false),
          buttonClick(
              const Icon(
                Icons.stop,
                color: Colors.white,
              ),
              24, () {
            cancelDownload.call();
          })
        ]);
      case DownloadState.downloadPaused:
        return Stack(
          alignment: Alignment.center,
          children: [
            circleProgressBar(percentageDownloaded, false),
            buttonClick(
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ),
                24,
                () {})
          ],
        );
      case DownloadState.downloadResumed:
        return Stack(
          alignment: Alignment.center,
          children: [
            circleProgressBar(percentageDownloaded, false),
            buttonClick(
                const Icon(
                  Icons.stop,
                  color: Colors.white,
                ),
                24, () {
              cancelDownload.call();
            })
          ],
        );
      case DownloadState.downloadCanceled:
        return Stack(
          alignment: Alignment.center,
          children: [
            buttonClick(
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ),
                24, () {
              openOptionQuality.call();
            })
          ],
        );
      case DownloadState.downloadFailed:
        return Stack(
          alignment: Alignment.center,
          children: [
            buttonClick(
                const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                24, () {
              retryDownload.call();
            })
          ],
        );
      case DownloadState.downloadCompleted:
        return Stack(
          alignment: Alignment.center,
          children: [
            buttonClick(
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                24,
                () {})
          ],
        );
      case DownloadState.downloadNotYet:
        return Stack(
          alignment: Alignment.center,
          children: [
            buttonClick(
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                ),
                24, () {
              openOptionQuality.call();
            })
          ],
        );
      case null:
        {
          return const SizedBox();
        }
    }
  }

  Widget loadingWidget() {
    return const SizedBox(
      width: 70,
      height: 70,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
