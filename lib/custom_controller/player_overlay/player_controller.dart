import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';

class PlayerController extends StatelessWidget {
  final FlutterNativeGetxController controller;
  const PlayerController({
    Key? key,
    required this.controller,
  }) : super(key: key);

  Widget controllerTop() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      child: Row(
        children: [
          controller.playerWidget.buttonClick(
              const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              null,
              () {}),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ///This feature will release as soon as possible
              // controller.playerWidget.downloadWidget(
              //     downloadState: controller.downloadState,
              //     percentageDownloaded: controller.percentageDownloaded,
              //     openOptionQuality: () {
              //       controller.playerMaterialBottomSheet
              //           .showQualityDownloadSelectionWidget(
              //               controller.playerMethodManager.getListQuality(),
              //               controller.playerMethodManager
              //                   .fetchHlsMasterPlaylist.playerResource);
              //     },
              //     retryDownload: () {
              //       controller.playerMethodManager.setRetryDownload();
              //     },
              //     cancelDownload: () {
              //       controller.playerMethodManager.setCancelDownload();
              //     }),
              controller.playerWidget.buttonClick(
                  const Icon(
                    Icons.subtitles_outlined,
                    color: Colors.white,
                  ),
                  null, () {
                controller.playerMaterialBottomSheet
                    .showSubtitlesSelectionWidget(controller
                        .playerMethodManager.fetchHlsMasterPlaylist
                        .getListSubtitle());
              }),
              controller.playerWidget.buttonClick(
                  const Icon(
                    Icons.more_horiz_sharp,
                    color: Colors.white,
                  ),
                  null, () {
                controller.playerMaterialBottomSheet
                    .showMoreTypeSelectionWidget(
                        controller.playerMethodManager.getListQuality(),
                        controller.playerMethodManager.getCurrentHeight());
              }),
            ],
          ))
        ],
      ),
    );
  }

  Widget controllerCenter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        controller.playerWidget.buttonClick(
            const Icon(
              Icons.replay_10,
              color: Colors.white,
            ),
            50, () {
          controller.playerMethodManager.replay();
        }),
        Container(
          alignment: Alignment.center,
          width: 60,
          height: 60,
          child: controller.isVisibleButtonPlay
              ? controller.playerWidget
                  .buttonClick(controller.iconControlPlayer, 50, () {
                  if (controller.playerMethodManager.isPlaying()) {
                    controller.playerMethodManager.pause();
                    controller.iconControlPlayer = const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    );
                    controller.update();
                  } else {
                    controller.playerMethodManager.play();
                    controller.iconControlPlayer = const Icon(
                      Icons.pause,
                      color: Colors.white,
                    );
                    controller.update();
                  }
                })
              : const SizedBox(),
        ),
        controller.playerWidget.buttonClick(
            const Icon(Icons.forward_10, color: Colors.white), 50, () {
          controller.playerMethodManager.forward();
        })
      ],
    );
  }

  Widget controllerBottom() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.bottomCenter,
      height: 50,
      child: Row(
        children: [
          Expanded(
              child: controller.playerWidget.progressBar(
                  controller: controller,
                  onSeekListener: (duration) {
                    controller.playerMethodManager
                        .seekTo(duration.inMilliseconds);
                  })),
          controller.playerWidget.countDownWidget(controller.durationState)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        controllerTop(),
        Flexible(flex: 1, child: controllerCenter()),
        controllerBottom()
      ],
    );
  }
}
