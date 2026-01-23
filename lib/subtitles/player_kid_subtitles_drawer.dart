import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'player_kid_subtitle.dart';
import 'player_kid_subtitles_configuration.dart';

class PlayerKidSubtitlesDrawer extends StatelessWidget {
  final List<PlayerKidSubtitle> subtitles;
  final Duration? currentPosition;
  final double width;
  final double height;
  final RegExp htmlRegExp =
      // ignore: unnecessary_raw_strings
      RegExp(r"<[^>]*>", multiLine: true);
  final PlayerKidSubtitlesConfiguration configuration;
  final bool _playerVisible = true;

  PlayerKidSubtitlesDrawer({
    Key? key,
    required this.subtitles,
    required this.currentPosition,
    required this.width,
    required this.height,
    this.configuration = const PlayerKidSubtitlesConfiguration(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitleTexts = _getSubtitlesAtCurrentPosition();
    final List<Widget> textWidgets = subtitleTexts
        .map((text) => _buildSubtitleTextWidget(text))
        .toList();

    return SizedBox(
      height: height,
      width: width,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: _playerVisible
              ? configuration.bottomPadding + 30
              : configuration.bottomPadding,
          left: configuration.leftPadding,
          right: configuration.rightPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: textWidgets,
        ),
      ),
    );
  }

  List<String> _getSubtitlesAtCurrentPosition() {
    if (currentPosition == null) {
      return [];
    }

    final Duration position = currentPosition!;

    for (final PlayerKidSubtitle subtitle in subtitles) {
      if (subtitle.start! <= position && subtitle.end! >= position) {
        return subtitle.texts ?? [];
      }
    }
    return [];
  }

  Widget _buildSubtitleTextWidget(String subtitleText) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: configuration.alignment,
            child: _getTextWithStroke(subtitleText),
          ),
        ),
      ],
    );
  }

  Widget _getTextWithStroke(String subtitleText) {
    final outerTextStyle = TextStyle(
      fontSize: configuration.fontSize,
      fontFamily: configuration.fontFamily,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = configuration.outlineSize
        ..color = configuration.outlineColor,
    );
    final innerTextStyle = TextStyle(
      fontFamily: configuration.fontFamily,
      color: configuration.fontColor,
      fontSize: configuration.fontSize,
    );
    return Container(
      color: configuration.backgroundColor,
      child: Stack(
        children: [
          if (configuration.outlineEnabled)
            _buildHtmlWidget(subtitleText, outerTextStyle)
          else
            const SizedBox(),
          _buildHtmlWidget(subtitleText, innerTextStyle),
        ],
      ),
    );
  }

  Widget _buildHtmlWidget(String text, TextStyle textStyle) {
    return HtmlWidget(text, textStyle: textStyle);
  }

  PlayerKidSubtitlesConfiguration setupDefaultConfiguration() {
    return const PlayerKidSubtitlesConfiguration();
  }
}
