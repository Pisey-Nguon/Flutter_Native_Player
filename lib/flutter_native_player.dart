import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/custom_controller/player_loading.dart';
import 'package:flutter_native_player/custom_controller/player_overlay_controller.dart';
import 'package:flutter_native_player/model/subtitle_model.dart';
import 'package:flutter_native_player/subtitles/better_player_subtitles_drawer.dart';

import 'constant.dart';
import 'custom_controller/component_widget_player.dart';
import 'custom_controller/player_controller.dart';
import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/player_method_manager.dart';

class FlutterNativePlayer extends StatefulWidget {
  final String url;
  final List<SubtitleModel>? subtitles;
  final double width;
  final double height;

  const FlutterNativePlayer(
      {Key? key,
      required this.url,
      this.subtitles,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlutterNativePlayer();
}

class _FlutterNativePlayer extends State<FlutterNativePlayer> {
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;
  final componentWidgetPlayer = ComponentWidgetPlayer();

  @override
  void initState() {
    final listSubtitle = [
      SubtitleModel(language: "Off", urlSubtitle: "", index: "0"),
      SubtitleModel(
          language: "English",
          urlSubtitle:
              "https://pharim-transcoder-milio.s3-ap-southeast-1.amazonaws.com/English_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
          index: "1"),
      SubtitleModel(
          language: "Khmer",
          urlSubtitle:
              "https://pharim-transcoder-milio.s3-ap-southeast-1.amazonaws.com/Khmer_Transformers_The_Last_Knight_Official_Trailer_1_2017_Michael.srt",
          index: "2")
    ];
    fetchHlsMasterPlaylist = FetchHlsMasterPlaylist(
        titleMovie: "", urlMovie: widget.url, listSubtitle: listSubtitle);
    playerMethodManager =
        PlayerMethodManager(fetchHlsMasterPlaylist: fetchHlsMasterPlaylist);
    playerMethodManager.setSubtitleSelectedListener((source) {
      setState(() {
        fetchHlsMasterPlaylist.setupSubtitleSource(source);
      });
    });
    super.initState();
  }

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
      Constant.MP_URL_STREAMING: widget.url,
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
    // TODO: implement build

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          crossPlatform(playerMethodManager: playerMethodManager),
          BetterPlayerSubtitlesDrawer(
            subtitles: fetchHlsMasterPlaylist.subtitlesLines,
            playerMethodManager: playerMethodManager,
            width: double.infinity,
            height: double.infinity,
          ),
          PlayerOverlayController(playerMethodManager: playerMethodManager, width: double.infinity, height: double.infinity),
          PlayerLoading(playerMethodManager: playerMethodManager,)
        ],
      ),
    );
  }
}
