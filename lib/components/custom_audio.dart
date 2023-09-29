import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';

class CustomAudioPlayer extends StatefulWidget {
  const CustomAudioPlayer({
    Key? key,
    this.audioURL,
    this.autoplay,
  }) : super(key: key);

  final String? audioURL;
  final bool? autoplay;

  @override
  _CustomAudioPlayerState createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream
        .listen((event) {}, onError: (Object e, StackTrace stackTrace) {});
    // Try to load audio from a source and catch any errors.
    try {
      final audioSource = LockCachingAudioSource(Uri.parse(widget.audioURL!));
      await _player.setAudioSource(
        audioSource,
      );
      if (widget.autoplay!) {
        _player.play();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControlButtons(_player);
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 50.0,
            height: 50.0,
            child: CupertinoActivityIndicator(),
          );
        } else if (playing != true) {
          return _buildPlayerWidgets(Ionicons.play, player.play, context);
        } else if (processingState != ProcessingState.completed) {
          return _buildPlayerWidgets(Ionicons.pause, player.pause, context);
        } else {
          return _buildPlayerWidgets(Ionicons.reload_outline,
              () => player.seek(Duration.zero), context);
        }
      },
    );
  }

  _buildPlayerWidgets(
      IconData? icon, void Function()? function, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.primaries[Random().nextInt(16)].withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: new Offset(0.0, 0.0),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: function,
          child: Icon(
            icon,
            color: Colors.white,
            size: 35.0,
          ),
        ),
      ),
    );
  }
}
