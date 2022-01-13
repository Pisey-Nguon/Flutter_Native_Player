// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'better_player_subtitle.dart';
import 'better_player_subtitles_configuration.dart';

class BetterPlayerSubtitlesDrawer extends StatefulWidget {
  final List<BetterPlayerSubtitle> subtitles;
  final PlayerMethodManager playerMethodManager;
  final BetterPlayerSubtitlesConfiguration? betterPlayerSubtitlesConfiguration;
  final double width;
  final double height;

  const BetterPlayerSubtitlesDrawer({
    Key? key,
    required this.subtitles,
    required this.playerMethodManager,
    this.betterPlayerSubtitlesConfiguration,
    required this.width,
    required this.height
  }) : super(key: key);

  @override
  _BetterPlayerSubtitlesDrawerState createState() =>
      _BetterPlayerSubtitlesDrawerState();
}

class _BetterPlayerSubtitlesDrawerState
    extends State<BetterPlayerSubtitlesDrawer> {
  final RegExp htmlRegExp =
      // ignore: unnecessary_raw_strings
      RegExp(r"<[^>]*>", multiLine: true);
  late TextStyle _innerTextStyle;
  late TextStyle _outerTextStyle;

  Duration? _currentPosition;
  BetterPlayerSubtitlesConfiguration? _configuration;
  bool _playerVisible = true;

  ///Stream used to detect if play controls are visible or not
  // late StreamSubscription _visibilityStreamSubscription;

  @override
  void initState() {
    // _visibilityStreamSubscription =
    //     widget.playerVisibilityStream.listen((state) {
    //   setState(() {
    //     _playerVisible = state;
    //   });
    // });

    if (widget.betterPlayerSubtitlesConfiguration != null) {
      _configuration = widget.betterPlayerSubtitlesConfiguration;
    } else {
      _configuration = setupDefaultConfiguration();
    }

    widget.playerMethodManager.streamDurationState.listen((event) {
      _updateState(event.progress.inMilliseconds);
    });

    _outerTextStyle = TextStyle(
        fontSize: _configuration!.fontSize,
        fontFamily: _configuration!.fontFamily,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _configuration!.outlineSize
          ..color = _configuration!.outlineColor);

    _innerTextStyle = TextStyle(
        fontFamily: _configuration!.fontFamily,
        color: _configuration!.fontColor,
        fontSize: _configuration!.fontSize);

    super.initState();
  }

  @override
  void dispose() {
    // _visibilityStreamSubscription.cancel();
    super.dispose();
  }

  ///Called when player state has changed, i.e. new player position, etc.
  void _updateState(int currentPosition) {
    if (mounted) {
      setState(() {
        _currentPosition = Duration(milliseconds: (currentPosition));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> subtitles = _getSubtitlesAtCurrentPosition()!;
    final List<Widget> textWidgets =
        subtitles.map((text) => _buildSubtitleTextWidget(text)).toList();

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: _playerVisible
                ? _configuration!.bottomPadding + 30
                : _configuration!.bottomPadding,
            left: _configuration!.leftPadding,
            right: _configuration!.rightPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: textWidgets,
        ),
      ),
    );
  }

  List<String>? _getSubtitlesAtCurrentPosition() {
    if (_currentPosition == null) {
      return [];
    }

    final Duration position = _currentPosition!;
    for (final BetterPlayerSubtitle subtitle in widget.subtitles) {
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
          alignment: _configuration!.alignment,
          child: _getTextWithStroke(subtitleText),
        ),
      ),
    ]);
  }

  Widget _getTextWithStroke(String subtitleText) {
    return Container(
      color: _configuration!.backgroundColor,
      child: Stack(
        children: [
          if (_configuration!.outlineEnabled)
            _buildHtmlWidget(subtitleText, _outerTextStyle)
          else
            const SizedBox(),
          _buildHtmlWidget(subtitleText, _innerTextStyle)
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

  BetterPlayerSubtitlesConfiguration setupDefaultConfiguration() {
    return const BetterPlayerSubtitlesConfiguration();
  }
}
