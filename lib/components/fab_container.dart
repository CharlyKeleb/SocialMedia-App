import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../posts/create_post.dart';

class FabContainer extends StatelessWidget {
  final Widget page;
  final IconData icon;
  final bool mini;

  FabContainer({@required this.page, @required this.icon, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return page;
      },
      closedElevation: 4.0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(56 / 2),
        ),
      ),
      closedColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            icon,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            chooseUpload(context);
          },
          mini: mini,
        );
      },
    );
  }

  chooseUpload(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    'Create Post',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  CupertinoIcons.camera_on_rectangle,
                  size: 25.0,
                ),
                title: Text('Make a Post'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => CreatePost(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
