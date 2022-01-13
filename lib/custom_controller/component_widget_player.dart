
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_player/method_manager/player_method_manager.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/utils/time_utils.dart';
import 'material/audio_video_progress_bar.dart';


class ComponentWidgetPlayer {

  static final ComponentWidgetPlayer _singleton = ComponentWidgetPlayer._internal();

  factory ComponentWidgetPlayer() {
    return _singleton;
  }

  ComponentWidgetPlayer._internal();

  Widget textView(String text){
    return Text(text,style: const TextStyle(color: Colors.white),);
  }
  StreamBuilder<DurationState> countDownWidget(Stream<DurationState> streamDurationState){
    return StreamBuilder<DurationState>(
        stream:streamDurationState,
        builder:(context,snapshot) {
          if(snapshot.hasData){
            final int timeCountDownMs = snapshot.data!.total!.inMilliseconds - snapshot.data!.progress.inMilliseconds;
            final String remainTime = TimeUtils.formatDurationCount(timeCountDownMs);
            return Container(
              alignment: Alignment.centerRight,
              width: 70,
              height: 70,
              child: textView(remainTime),
            );
          }else{
            return Container(
              alignment: Alignment.centerRight,
              width: 70,
              height: 70,
              child: textView("--:--"),
            );
          }
        }
    );
  }

  Widget buttonClick(Icon icon,bool visible,bool? isAbsorbing ,double? iconSize, VoidCallback press){
    return AbsorbPointer(
      absorbing: isAbsorbing ?? false,
      child: Visibility(visible: visible,child: IconButton(onPressed: press, icon: icon,iconSize: iconSize ?? 24,),
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
    ));
  }
  Widget circleProgressBar(double progress){
    return SizedBox(
      height: 27,
      width: 27,
      child: CircularProgressIndicator(
        value: progress / 100,

      ),
    );
  }

  StreamBuilder<DurationState> progressBar(PlayerMethodManager playerMethodManager,bool isAbsorbing,void onSeekListener(Duration duration)) {
    return StreamBuilder<DurationState>(
      stream: playerMethodManager.streamDurationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        Duration progress = durationState?.progress ?? Duration.zero;
        Duration buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return AbsorbPointer(
          absorbing: isAbsorbing,
          child: ProgressBar(
            progress: progress,
            buffered: buffered,
            total: total,
            onSeek: (duration) {
              progress = duration;
              onSeekListener.call(duration);
              playerMethodManager.getStreamControllerDurationState().sink.add(DurationState(progress: progress, buffered: buffered,total: total));
            },
            onDragStart: (_){
              playerMethodManager.pauseListenerPosition();
            },
            onDragEnd: (){
              playerMethodManager.startListenerPosition();
            },
            barHeight: 5,

            thumbRadius: 6,
            thumbGlowRadius: 12,
            thumbGlowColor: Colors.blue,
            thumbColor: Colors.blue,
            timeLabelLocation: TimeLabelLocation.none,
          ),
        );
      },
    );
  }


  Widget loadingWidget(){
    return const SizedBox(
      width: 70,
      height: 70,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}