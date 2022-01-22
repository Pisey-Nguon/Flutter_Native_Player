import 'package:flutter/material.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'player_kid_subtitle.dart';
import 'player_kid_subtitles_configuration.dart';

class PlayerKidSubtitlesDrawer extends StatelessWidget {
  final FlutterNativeGetxController controller;
  final List<PlayerKidSubtitle> subtitles;
  final double width;
  final double height;
  final RegExp htmlRegExp =
      // ignore: unnecessary_raw_strings
      RegExp(r"<[^>]*>", multiLine: true);
  final PlayerKidSubtitlesConfiguration configuration =
      const PlayerKidSubtitlesConfiguration();
  final bool _playerVisible = true;

  PlayerKidSubtitlesDrawer(
      {Key? key,
      required this.controller,
      required this.subtitles,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> subtitles = _getSubtitlesAtCurrentPosition()!;
    final List<Widget> textWidgets =
        subtitles.map((text) => _buildSubtitleTextWidget(text)).toList();

    return SizedBox(
      height: height,
      width: width,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: _playerVisible
                ? configuration.bottomPadding + 30
                : configuration.bottomPadding,
            left: configuration.leftPadding,
            right: configuration.rightPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: textWidgets,
        ),
      ),
    );
  }

  List<String>? _getSubtitlesAtCurrentPosition() {
    if (controller.currentPosition == null) {
      return [];
    }

    final Duration position = controller.currentPosition!;
    for (final PlayerKidSubtitle subtitle in subtitles) {
      if (subtitle.start! <= position && subtitle.end! >= position) {
        return subtitle.texts;
      }
    }
    return [];
  }

  Widget _buildSubtitleTextWidget(String subtitleText) {
    return Row(children: [
      Expanded(
        child: Align(
          alignment: configuration.alignment,
          child: _getTextWithStroke(subtitleText),
        ),
      ),
    ]);
  }

  Widget _getTextWithStroke(String subtitleText) {
    final outerTextStyle = TextStyle(
        fontSize: configuration.fontSize,
        fontFamily: configuration.fontFamily,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = configuration.outlineSize
          ..color = configuration.outlineColor);
    final innerTextStyle = TextStyle(
        fontFamily: configuration.fontFamily,
        color: configuration.fontColor,
        fontSize: configuration.fontSize);
    return Container(
      color: configuration.backgroundColor,
      child: Stack(
        children: [
          if (configuration.outlineEnabled)
            _buildHtmlWidget(subtitleText, outerTextStyle)
          else
            const SizedBox(),
          _buildHtmlWidget(subtitleText, innerTextStyle)
        ],
      ),
    );
  }

  Widget _buildHtmlWidget(String text, TextStyle textStyle) {
    return HtmlWidget(
      text,
      textStyle: textStyle,
    );
  }

  PlayerKidSubtitlesConfiguration setupDefaultConfiguration() {
    return const PlayerKidSubtitlesConfiguration();
  }
}
