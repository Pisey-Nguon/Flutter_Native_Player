import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/custom_controller/configuration/player_progress_colors.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_loading.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_overlay_controller.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_drawer.dart';
import 'package:get/get.dart';

import 'constant.dart';

class FlutterNativePlayer extends StatelessWidget {
  final PlayerResource playerResource;
  final PlayerProgressColors? progressColors;
  final bool playWhenReady;
  final double width;
  final double height;

  const FlutterNativePlayer(
      {Key? key,
      required this.playerResource,
      this.progressColors,
      this.playWhenReady = true,
      required this.width,
      required this.height})
      : super(key: key);

  Widget androidPlatform(Map<String, dynamic> creationParams) {
    return PlatformViewLink(
      viewType: Constant.MP_VIEW_TYPE,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: Constant.MP_VIEW_TYPE,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  Widget iOSPlatform(Map<String, dynamic> creationParams) {
    return UiKitView(
        viewType: Constant.MP_VIEW_TYPE,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec());
  }

  Widget crossPlatform() {
    final creationParams = {
      Constant.KEY_PLAYER_RESOURCE: playerResourceToJson(playerResource),
      Constant.KEY_PLAY_WHEN_READY: playWhenReady
    };
    Widget platform;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platform = androidPlatform(creationParams);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = iOSPlatform(creationParams);
    } else {
      platform = const Text("Error no view type");
    }
    return Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        child: platform,
        color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FlutterNativeGetxController(
          context: context,
          playerResource: playerResource,
          playWhenReady: playWhenReady),
      builder: (FlutterNativeGetxController controller) {
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              crossPlatform(),
              PlayerKidSubtitlesDrawer(
                controller: controller,
                subtitles: controller.fetchHlsMasterPlaylist.subtitlesLines,
                width: double.infinity,
                height: double.infinity,
              ),
              PlayerOverlayController(
                  controller: controller,
                  playerMethodManager: controller.playerMethodManager,
                  progressColors: progressColors,
                  width: double.infinity,
                  height: double.infinity),
              PlayerLoading(
                controller: controller,
              )
            ],
          ),
        );
      },
    );
  }
}
