import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MiniVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final bool autoPlay;
  final double height;
  final double? width;
  final bool fromNetwork;

  const MiniVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.aspectRatio = 9 / 16,
    this.autoPlay = false,
    this.height = 160.0,
    this.width,
    this.fromNetwork = true,
  }) : super(key: key);

  @override
  State<MiniVideoPlayer> createState() => _MiniVideoPlayerState();
}

class _MiniVideoPlayerState extends State<MiniVideoPlayer> with RouteAware {
  VideoPlayerController? videoPlayerController;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    print('LOOOOOOOOAAADED');
    videoPlayerController = widget.fromNetwork == true
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.file(
            File(widget.videoUrl),
          );
    videoPlayerController!.initialize().then((_) {
      if (widget.autoPlay == true) {
        videoPlayerController!.play();
      }
      setState(() {
        videoPlayerController!.setVolume(_isMuted ? 0.0 : 1.0);
        videoPlayerController!.setLooping(true);
      });
    });
  }

  void _toggleVolume() {
    if (_isMuted) {
      setState(() {
        videoPlayerController!.setVolume(1.0);
        _isMuted = false;
      });
    } else {
      setState(() {
        videoPlayerController!.setVolume(0.0);
        _isMuted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMuted == true) {
      videoPlayerController!.setVolume(0.0);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width,
          height: widget.height, //Crop height
          child: FittedBox(
            // alignment: Alignment.center,
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: videoPlayerController!.value.size.width,
              height: videoPlayerController!.value.size.height,
              child: AspectRatio(
                aspectRatio: videoPlayerController!.value.aspectRatio,
                child: videoPlayerController!.value.isInitialized
                    ? VideoPlayer(
                        videoPlayerController!,
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
        Positioned(
          bottom: 10.0,
          right: 10.0,
          child: GestureDetector(
            onTap: _toggleVolume,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted
                    ? CupertinoIcons.volume_off
                    : CupertinoIcons.volume_down,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }
}
