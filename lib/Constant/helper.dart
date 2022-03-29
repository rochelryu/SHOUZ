
String reformatTimerForDisplayOnChrono(int time) {
  final minute = (time / 60).floor();
  final second = (time % 60);
  return "${minute.toString().length>1 ? minute.toString():'0${minute.toString()}' }:${second.toString().length>1 ? second.toString():'0${second.toString()}' }";
}