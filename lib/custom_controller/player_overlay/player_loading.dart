import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';

class PlayerLoading extends StatelessWidget {
  final FlutterNativeGetxController controller;

  const PlayerLoading({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final view = SizedBox(
      child: controller.isShowLoading
          ? Align(
              child: controller.playerWidget.loadingWidget(),
              alignment: Alignment.center,
            )
          : const SizedBox(),
    );
    return view;
  }
}
