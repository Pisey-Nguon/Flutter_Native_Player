import 'package:flutter/cupertino.dart';
import 'package:flutter_native_player/custom_controller/player_controller.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';

class PlayerOverlayController extends StatelessWidget{
  final FlutterNativeGetxController controller;
  final PlayerMethodManager playerMethodManager;
  final double width;
  final double height;

  const PlayerOverlayController({Key? key,required this.controller,required this.playerMethodManager,required this.width,required this.height}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AnimatedOpacity(
        opacity: playerMethodManager.isShowController ? 1 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: PlayerController(
          playerMethodManager: playerMethodManager,
          onTouchListener: () {
            playerMethodManager.isShowController = !playerMethodManager.isShowController;
            controller.update();
          },
          onScaleStart: (details) {},
          onScaleUpdate: (details) {},
          onScaleEnd: (details) {},
          onLoadingListener: (isLoading) {
            playerMethodManager.isShowLoading = isLoading;
            controller.update();
          },
        ),
        onEnd: () {
          playerMethodManager.isAbsorbing = !playerMethodManager.isAbsorbing;
          controller.update();
        },
      ),
    );
  }
}