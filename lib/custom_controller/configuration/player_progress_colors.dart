// Flutter imports:
import 'package:flutter/rendering.dart';

///Representation of colors used in progress bar.
class PlayerProgressColors {
  PlayerProgressColors({
    Color played = const Color.fromARGB(255, 255, 56, 56),
    Color buffered = const Color.fromARGB(255, 199, 199, 199),
    Color baseBar = const Color.fromARGB(255, 238, 238, 238),
    Color thumb = const Color.fromARGB(255, 255, 56, 56),
  })  : playedColor = played,
        bufferedColor = buffered,
        baseBarColor = baseBar,
        thumbColor = thumb;

  final Color playedColor;
  final Color bufferedColor;
  final Color baseBarColor;
  final Color thumbColor;
}
