import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';

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
          ///Will enable if configuration have be done
          // controller.playerWidget.buttonClick(
          //     const Icon(
          //       Icons.arrow_back,
          //       color: Colors.white,
          //     ),
          //     null,
          //     () {}),
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
              controller.playerResource.playerSubtitleResource != null
                  ? controller.playerWidget.buttonClick(
                      const Icon(
                        Icons.subtitles_outlined,
                        color: Colors.white,
                      ),
                      null, () {
                      controller.playerMaterialBottomSheet
                          .showSubtitlesSelectionWidget(controller
                              .playerMethodManager.fetchHlsMasterPlaylist
                              .getListSubtitle());
                    })
                  : const SizedBox(),
              controller.playerWidget.buttonClick(
                  const Icon(
                    Icons.more_horiz_sharp,
                    color: Colors.white,
                  ),
                  null, () {
                controller.playerMaterialBottomSheet
                    .showMoreTypeSelectionWidget(
                        controller.playerMethodManager.getListQuality(),
                        controller.playerMethodManager.getCurrentUrlQuality());
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  controller.playerMethodManager.playByState();
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.bottomCenter,
      height: 50,
      child: Row(
        children: [
          controller.playerWidget.currentTimeWidget(controller.durationState),
          Expanded(
              child: controller.playerWidget.progressBar(
                  controller: controller,
                  onSeekListener: (duration) {
                    controller.playerMethodManager
                        .seekTo(duration.inMilliseconds);
                  })),
          controller.playerWidget.totalTimeWidget(controller.durationState)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black38,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            controllerTop(),
            Flexible(flex: 1, child: controllerCenter()),
            controllerBottom()
          ],
        )
      ],
    );
  }
}
