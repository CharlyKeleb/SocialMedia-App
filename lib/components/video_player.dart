import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isVisible = false;

  Duration? _currentPosition;
  Duration? _videoDuration;
  double? _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((value) {
        _videoPlayerController!.play();
        _videoPlayerController!.setVolume(1);
      });
    _currentPosition = _videoPlayerController!.value.position;
    _videoDuration = _videoPlayerController!.value.duration;
    _videoPlayerController!.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _videoPlayerController!.value.position;
          _sliderValue = _currentPosition!.inMilliseconds.toDouble();
        });
      }
    });
  }

  void _togglePlayback() {
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _isPlaying = false;
      } else {
        _videoPlayerController!.play();
        _isPlaying = true;
      }
    });
  }

  void _seekTo(Duration duration) {
    setState(() {
      _videoPlayerController!.seekTo(duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying == true) {
      _videoPlayerController!.play();
      if (_isMuted == false) {
        _videoPlayerController!.setVolume(1.0);
      } else if (_isMuted == true) {
        _videoPlayerController!.setVolume(0.0);
      }
    }
    String durationString = _videoDuration != null
        ? '${_videoDuration!.inMinutes.toString().padLeft(2, '0')}:${(_videoDuration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '';

    String positionString = _currentPosition != null
        ? '${_currentPosition!.inMinutes.toString().padLeft(2, '0')}:${(_currentPosition!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isVisible = !_isVisible;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: _videoPlayerController!.value.isInitialized
                        ? VideoPlayer(
                            _videoPlayerController!,
                          )
                        : const Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Ionicons.pause : Ionicons.play,
                    size: 50.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: Positioned(
                top: 50.0,
                left: 10.0,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isMuted = true;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Ionicons.chevron_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: Positioned(
                bottom: 40.0,
                left: 10.0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 17.0,
                      width: MediaQuery.of(context).size.width,
                      child: Slider(
                        value: _sliderValue!,
                        min: 0.0,
                        inactiveColor: Colors.white,
                        max: _videoDuration!.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _seekTo(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Text(
                              positionString,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                            const Spacer(),
                            Text(
                              durationString,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }
}
