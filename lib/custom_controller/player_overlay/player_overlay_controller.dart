import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/configuration/player_progress_colors.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_controller.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';

class PlayerOverlayController extends StatelessWidget {
  final FlutterNativeGetxController controller;
  final PlayerMethodManager playerMethodManager;
  final PlayerProgressColors? progressColors;
  final double width;
  final double height;

  const PlayerOverlayController(
      {Key? key,
      required this.controller,
      required this.playerMethodManager,
      this.progressColors,
      required this.width,
      required this.height})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: controller.isShowController
            ? PlayerController(
                controller: controller,
                onTap: () {
                  controller.isShowController = false;
                  controller.update();
                },
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.isShowController = true;
                  controller.handleControllerTimeout();
                  controller.update();
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}
