import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/custom_controller/player_loading.dart';
import 'package:flutter_native_player/custom_controller/player_overlay_controller.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/model/subtitle_model.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_drawer.dart';
import 'package:get/get.dart';

import 'constant.dart';
import 'method_manager/player_method_manager.dart';


class FlutterNativePlayer extends StatelessWidget {
  final String url;
  final List<SubtitleModel>? subtitles;
  final double width;
  final double height;

  const FlutterNativePlayer({Key? key, required this.url, this.subtitles, required this.width, required this.height}) : super(key: key);


  Widget androidPlatform(Map<String,dynamic> creationParams) {
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

  Widget iOSPlatform(Map<String,dynamic> creationParams) {
    return UiKitView(
        viewType: Constant.MP_VIEW_TYPE,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec());
  }

  Widget crossPlatform({required PlayerMethodManager playerMethodManager}) {
    final creationParams = {
      Constant.MP_URL_STREAMING: url,
    };
    Widget platform;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platform = androidPlatform(creationParams);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = iOSPlatform(creationParams);
    } else {
      platform = const Text("Error no view type");
    }
    return Container(alignment: Alignment.topCenter,width: double.infinity,height: double.infinity,child: platform,color:Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FlutterNativeGetxController(url: url, subtitles: subtitles),
      builder: (FlutterNativeGetxController controller) {
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              crossPlatform(playerMethodManager: controller.playerMethodManager),
              BetterPlayerSubtitlesDrawer(
                subtitles: controller.fetchHlsMasterPlaylist.subtitlesLines,
                playerMethodManager: controller.playerMethodManager,
                width: double.infinity,
                height: double.infinity,
              ),
              PlayerOverlayController(controller: controller,playerMethodManager: controller.playerMethodManager, width: double.infinity, height: double.infinity),
              PlayerLoading(playerMethodManager: controller.playerMethodManager,)
            ],
          ),
        );
      },
    );
  }
}
