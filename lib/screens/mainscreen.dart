import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/components/fab_container.dart';
import 'package:social_media_app/pages/activities.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/pages/publication.dart';
import 'package:social_media_app/pages/search.dart';
import 'package:social_media_app/pages/timeline.dart';
import 'package:social_media_app/utils/firebase.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _page = 0;

  List pages = [
    {
      'title': 'Home',
      'icon': Feather.home,
      'page': Timeline(),
      'index': 0,
    },
    {
      'title': 'Search',
      'icon': Feather.search,
      'page': Search(),
      'index': 1,
    },
    {
      'title': 'unsee',
      'icon': Feather.plus_circle,
      'page': Text('nes'),
      'index': 2,
    },
    {
      'title': 'Activity',
      'icon': Feather.bell,
      'page': Activities(),
      'index': 3,
    },
    {
      'title': 'Profile',
      'icon': Feather.user,
      'page': Profile(profileId: firebaseAuth.currentUser.uid),
      'index': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_page]['page'],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 5),
            for (Map item in pages)
              item['index'] == 2
                  ? buildFab()
                  : Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: IconButton(
                        icon: Icon(
                          item['icon'],
                          color: item['index'] != _page
                              ? Colors.black
                              : Theme.of(context).accentColor,
                          size: 20.0,
                        ),
                        onPressed: () => navigationTapped(item['index']),
                      ),
                    ),
            SizedBox(width: 5),
          ],
        ),
        color: Colors.white,
      ),
    );
  }

  buildFab() {
    return Container(
      height: 45.0,
      width: 45.0,
      child: FabContainer(
        page: Publication(),
        icon: Feather.plus,
        mini: true,
      ),
    );
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }
}
