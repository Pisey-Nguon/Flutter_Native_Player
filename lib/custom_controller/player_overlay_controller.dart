import 'package:flutter/cupertino.dart';
import 'package:flutter_native_player/custom_controller/player_controller.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';

class PlayerOverlayController extends StatefulWidget{
  final PlayerMethodManager playerMethodManager;
  final double width;
  final double height;
  const PlayerOverlayController({Key? key,required this.playerMethodManager,required this.width,required this.height}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerOverlayController();

}
class _PlayerOverlayController extends State<PlayerOverlayController>{

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedOpacity(
        opacity: widget.playerMethodManager.isShowController ? 1 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: PlayerController(
          playerMethodManager: widget.playerMethodManager,
          onTouchListener: () {
            setState(() {
              widget.playerMethodManager.isShowController = !widget.playerMethodManager.isShowController;
            });
          },
          onScaleStart: (details) {},
          onScaleUpdate: (details) {},
          onScaleEnd: (details) {},
          onLoadingListener: (isLoading) {
            setState(() {
              widget.playerMethodManager.isShowLoading = isLoading;
            });
          },
        ),
        onEnd: () {
          setState(() {
            widget.playerMethodManager.isAbsorbing = !widget.playerMethodManager.isAbsorbing;
          });
        },
      ),
    );
  }
}