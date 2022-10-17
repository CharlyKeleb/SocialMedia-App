import 'package:flutter/material.dart';
import 'package:social_media_app/models/story_model.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:story_view/story_view.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/status-screen';
  final Status status;

  const StatusScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(StoryItem.pageImage(
        url: widget.status.photoUrl[i],
        controller: controller,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? circularProgress(context)
          : StoryView(
              storyItems: storyItems,
              controller: controller,
              onStoryShow: (val) {
                print('COMPLETEEDDD');
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
