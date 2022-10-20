import 'dart:async';

import 'package:flutter/material.dart';

class TextTime extends StatefulWidget {
  final Widget? child;

  const TextTime({this.child});

  @override
  _TextTimeState createState() => _TextTimeState();
}

class _TextTimeState extends State<TextTime> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
