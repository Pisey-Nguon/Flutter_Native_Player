import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/component_widget_player.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';

class PlayerLoading extends StatelessWidget {
  final PlayerMethodManager playerMethodManager;

  final componentWidgetPlayer = ComponentWidgetPlayer();

  PlayerLoading({Key? key, required this.playerMethodManager}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final view = SizedBox(
      child: playerMethodManager.isShowLoading
          ? Align(
              child: componentWidgetPlayer.loadingWidget(),
              alignment: Alignment.center,
            )
          : const SizedBox(),
    );
    return view;
  }
}
