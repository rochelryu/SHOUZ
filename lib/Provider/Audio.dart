import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../Constant/Style.dart';

/*class Audio {
  String urlAudio = '';
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);
  AudioPlayer audioPlayer = AudioPlayer();
  bool isListenSound = false, firstListeen = true;
  //late AnimationController controller;

  Audio({required String url}) {
    this.urlAudio = url;
    initializeAudio();
  }


  Future initializeAudio() async {
    duration = await audioPlayer.setUrl(this.urlAudio) ?? Duration(seconds: 0);
    audioPlayer.bufferedPositionStream.listen((p) {
      position = p;

    });
    audioPlayer.playerStateStream.listen((event) {
      if(event.processingState == ProcessingState.completed) {
        isListenSound = false;
        firstListeen = true;
      }
    });

  }

  Future play() async {
    await audioPlayer.play();
      firstListeen = false;
  }
  Future pause() async {
    await audioPlayer.pause();
  }

  Future resume() async {
    await audioPlayer.play();
  }

  void changeToSecond(int millisecond) async {
    Duration duration = Duration(milliseconds: millisecond);
    await audioPlayer.seek(duration);
  }

}*/

class LoadAudioAsset extends StatefulWidget {
  String url;
  bool isMe;
  LoadAudioAsset({required Key key, required this.url, required this.isMe})
      : super(key: key);

  @override
  _LoadAudioAssetState createState() => _LoadAudioAssetState();
}

class _LoadAudioAssetState extends State<LoadAudioAsset>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isListenSound = false, firstListeen = true;
  Duration _duration = Duration();
  Duration _position = Duration();
  AudioPlayer audioPlayer = AudioPlayer();

  Future play() async {
    await audioPlayer.play(UrlSource(widget.url));
    controller.forward();
    setState(() {
      firstListeen = false;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    controller.reverse();
  }

  Future resume() async {
    await audioPlayer.resume();
    controller.forward();
  }

  void changeToSecond(int millisecond) async {
    Duration duration = Duration(milliseconds: millisecond);
    await audioPlayer.seek(duration);
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    audioPlayer.setSourceUrl(widget.url);
    audioPlayer.stop();
    audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isListenSound = false;
        firstListeen = true;
        _position = Duration(milliseconds: 0);
      });
      controller.reverse();
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isListenSound && !firstListeen) {
                await pause();
              } else if (firstListeen && !isListenSound) {
                await play();
              } else {
                await resume();
              }
              setState(() {
                isListenSound = !isListenSound;
              });
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: controller,
              color: widget.isMe ? Colors.white : colorText,
              size: 30,
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text(_position.toString().substring(2).split('.')[0],
                      style: widget.isMe
                          ? Style.chatIsMe(fontSize: 13.0)
                          : Style.chatOutMe(13.0)),
                ),
                Expanded(
                    child: Slider(
                      inactiveColor: widget.isMe
                          ? Colors.white.withOpacity(0.4)
                          : colorText.withOpacity(0.4),
                      activeColor: widget.isMe ? Colors.white : colorText,
                      value: _position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble(),
                      min: 0.0,
                      onChanged: (value) {
                        setState(() {
                          changeToSecond(value.toInt());
                          value = value;
                        });
                      },
                    )),
                SizedBox(
                  width: 50,
                  child: Text(_duration.toString().substring(2).split('.')[0],
                      style: widget.isMe
                          ? Style.chatIsMe(fontSize: 13.0)
                          : Style.chatOutMe(13.0),
                      textAlign: TextAlign.start),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}