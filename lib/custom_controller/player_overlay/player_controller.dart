import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/material/dialog/player_material_bottom_sheet.dart';
import 'package:flutter_native_player/method_manager/download_state.dart';
import 'package:flutter_native_player/method_manager/playback_state.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';

import 'component_widget_player.dart';

class PlayerController extends StatefulWidget {
  final PlayerMethodManager playerMethodManager;
  final VoidCallback onTouchListener;
  final Function(ScaleUpdateDetails details) onScaleUpdate;
  final Function(ScaleStartDetails details) onScaleStart;
  final Function(ScaleEndDetails details) onScaleEnd;
  final Function(bool isLoading) onLoadingListener;
  const PlayerController(
      {Key? key,
      required this.playerMethodManager,
      required this.onTouchListener,
      required this.onLoadingListener,
      required this.onScaleUpdate,
      required this.onScaleStart,
      required this.onScaleEnd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerController();
}

class _PlayerController extends State<PlayerController> {
  late ComponentWidgetPlayer componentWidgetPlayer;
  late PlayerMaterialBottomSheet playerMaterialBottomSheet;
  Icon iconControlPlayer = const Icon(
    Icons.pause_outlined,
    color: Colors.white,
  );
  Icon iconDownloader = const Icon(
    Icons.arrow_downward,
    color: Colors.white,
  );
  bool isVisibleButtonPlay = true;
  bool isVisibleButtonCast = false;
  bool isShowController = true;
  bool isShowProgressDownload = true;
  double percentageDownloaded = 0;

  void _updateEventTypePlay() {
    setState(() {
      iconControlPlayer = const Icon(
        Icons.pause_outlined,
        color: Colors.white,
      );
    });
  }

  void _updateEventTypePause() {
    setState(() {
      iconControlPlayer = const Icon(
        Icons.play_arrow,
        color: Colors.white,
      );
    });
  }

  void _updateEventTypeFinished() {
    setState(() {
      iconControlPlayer = const Icon(
        Icons.replay,
        color: Colors.white,
      );
    });
  }

  void _handlePlaybackStateEvent() {
    widget.playerMethodManager.streamPlaybackState.listen((event) {
      switch (event) {
        case PlaybackState.readyToPlay:
          {
            widget.onLoadingListener.call(false);
            isVisibleButtonPlay = true;
          }
          break;
        case PlaybackState.play:
          {
            _updateEventTypePlay();
          }
          break;
        case PlaybackState.pause:
          {
            _updateEventTypePause();
          }
          break;
        case PlaybackState.buffering:
          {
            widget.onLoadingListener.call(true);
            isVisibleButtonPlay = false;
          }
          break;
        case PlaybackState.finish:
          {
            _updateEventTypeFinished();
          }
          break;
        case PlaybackState.tv_connected:
          widget.playerMethodManager.releasePlayer();
          break;
        case PlaybackState.tv_disconnected:
          widget.playerMethodManager.initPlayer();
          break;
        case PlaybackState.show_button_cast:
          setState(() {
            isVisibleButtonCast = true;
          });
          break;

        case PlaybackState.hide_button_cast:
          setState(() {
            isVisibleButtonCast = false;
          });
          break;
      }
    });
  }

  void _handleDownloadEvent() {
    widget.playerMethodManager.streamProgressDownloadState.listen((event) {
      setState(() {
        percentageDownloaded = event;
      });
    });
    widget.playerMethodManager.streamDownloadState.listen((event) {
      switch (event) {
        case DownloadState.downloadStarted:
          setState(() {
            iconDownloader = const Icon(
              Icons.stop,
              color: Colors.white,
            );
            isShowProgressDownload = true;
          });
          break;
        case DownloadState.downloadCompleted:
          setState(() {
            iconDownloader = const Icon(
              Icons.assignment_turned_in_outlined,
              color: Colors.white,
            );
            isShowProgressDownload = false;
            percentageDownloaded = 100;
          });
          break;
        case DownloadState.downloadFailed:
          setState(() {
            iconDownloader = const Icon(
              Icons.refresh,
              color: Colors.white,
            );
            isShowProgressDownload = false;
          });
          break;

        case DownloadState.downloadCanceled:
          setState(() {
            iconDownloader = const Icon(
              Icons.arrow_downward,
              color: Colors.white,
            );
            isShowProgressDownload = false;
          });
          break;
        case DownloadState.downloadPaused:
          // TODO: Handle this case.
          break;
        case DownloadState.downloadResumed:
          // TODO: Handle this case.
          break;
      }
    });
  }

  @override
  void initState() {
    componentWidgetPlayer = ComponentWidgetPlayer();
    playerMaterialBottomSheet = PlayerMaterialBottomSheet(
        context: context,
        fetchHlsMasterPlaylist:
            widget.playerMethodManager.fetchHlsMasterPlaylist,
        playerMethodManager: widget.playerMethodManager);
    _handleDownloadEvent();
    _handlePlaybackStateEvent();
    super.initState();
  }

  @override
  void dispose() {
    widget.playerMethodManager.dispose();
    super.dispose();
  }

  Widget controllerTop() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      child: Row(
        children: [
          componentWidgetPlayer.buttonClick(
              const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              true,
              widget.playerMethodManager.isAbsorbing,
              null,
              () {}),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    componentWidgetPlayer.buttonClick(iconDownloader, true,
                        widget.playerMethodManager.isAbsorbing, null, () {}),
                    isShowProgressDownload
                        ? componentWidgetPlayer
                            .circleProgressBar(percentageDownloaded)
                        : const SizedBox()
                  ],
                ),
                onTap: () {
                  if (widget.playerMethodManager.isDownloadStarted) {
                    //cancel download
                    widget.playerMethodManager.setCancelDownload();
                  } else {
                    playerMaterialBottomSheet.showQualityDownloadSelectionWidget(widget.playerMethodManager.getListQuality(),widget.playerMethodManager.fetchHlsMasterPlaylist.playerResource);
                  }
                },
              ),
              componentWidgetPlayer.buttonClick(
                  const Icon(
                    Icons.subtitles_outlined,
                    color: Colors.white,
                  ),
                  true,
                  widget.playerMethodManager.isAbsorbing,
                  null, () {
                playerMaterialBottomSheet.showSubtitlesSelectionWidget(widget
                    .playerMethodManager.fetchHlsMasterPlaylist
                    .getListSubtitle());
              }),
              isVisibleButtonCast
                  ? componentWidgetPlayer.buttonClick(
                      const Icon(
                        Icons.cast,
                        color: Colors.white,
                      ),
                      true,
                      widget.playerMethodManager.isAbsorbing,
                      null, () {
                      widget.playerMethodManager.showDevices();
                    })
                  : const SizedBox(),
              componentWidgetPlayer.buttonClick(
                  const Icon(
                    Icons.more_horiz_sharp,
                    color: Colors.white,
                  ),
                  true,
                  widget.playerMethodManager.isAbsorbing,
                  null, () {
                playerMaterialBottomSheet.showMoreTypeSelectionWidget(
                    widget.playerMethodManager.getListQuality(),
                    widget.playerMethodManager.getCurrentHeight());
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
        componentWidgetPlayer.buttonClick(
            const Icon(
              Icons.replay_10,
              color: Colors.white,
            ),
            true,
            widget.playerMethodManager.isAbsorbing,
            50, () {
          widget.playerMethodManager.replay();
        }),
        componentWidgetPlayer.buttonClick(
            iconControlPlayer,
            isVisibleButtonPlay,
            widget.playerMethodManager.isAbsorbing,
            50, () {
          if (widget.playerMethodManager.isPlaying()) {
            widget.playerMethodManager.pause();
            setState(() {
              iconControlPlayer = const Icon(
                Icons.play_arrow,
                color: Colors.white,
              );
            });
          } else {
            widget.playerMethodManager.play();
            setState(() {
              iconControlPlayer = const Icon(
                Icons.pause,
                color: Colors.white,
              );
            });
          }
        }),
        componentWidgetPlayer.buttonClick(
            const Icon(Icons.forward_10, color: Colors.white),
            true,
            widget.playerMethodManager.isAbsorbing,
            50, () {
          widget.playerMethodManager.forward();
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
              child: componentWidgetPlayer.progressBar(
                  playerMethodManager: widget.playerMethodManager,
                  isAbsorbing: widget.playerMethodManager.isAbsorbing,
                  onSeekListener: (duration) {
                    widget.playerMethodManager.seekTo(duration.inMilliseconds);
                  })),
          componentWidgetPlayer
              .countDownWidget(widget.playerMethodManager.streamDurationState)
        ],
      ),
    );
  }

  Widget containerController() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.onTouchListener.call();
      },
      onScaleStart: (details) {
        widget.onScaleStart(details);
      },
      onScaleUpdate: (details) {
        widget.onScaleUpdate(details);
      },
      onScaleEnd: (details) {
        widget.onScaleEnd(details);
      },
      child: Wrap(
        runAlignment: WrapAlignment.spaceBetween,
        children: [controllerTop(), controllerCenter(), controllerBottom()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return containerController();
  }
}
