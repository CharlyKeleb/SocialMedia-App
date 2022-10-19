import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/story_model.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/status/status_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:story/story.dart';

class StatusScreen extends StatefulWidget {
  final initPage;
  final Status status;

  const StatusScreen({
    Key? key,
    required this.status,
    required this.initPage,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          delete(widget.status.statusId, widget.status.photoUrl[0], context);
        },
        child: FutureBuilder<List<Status>>(
            future: viewModel.getStatus(context),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? circularProgress(context)
                  : StoryPageView(
                      indicatorPadding: EdgeInsets.symmetric(vertical: 50.0),
                      indicatorHeight: 15.0,
                      initialPage: widget.initPage,
                      indicatorVisitedColor:
                          Theme.of(context).colorScheme.secondary,
                      indicatorDuration: Duration(seconds: 30),
                      onPageChanged: (val) {
                        print('changed');
                      },
                      itemBuilder: (context, pageIndex, storyIndex) {
                        var statusData = snapshot.data![pageIndex];
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 50.0),
                                child:
                                    getImage(statusData.photoUrl[storyIndex]),
                              ),
                              Positioned(
                                bottom: 0.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: MediaQuery.of(context).size.width,
                                      constraints:
                                          BoxConstraints(maxHeight: 50.0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                              child: Text(
                                                statusData
                                                    .description![storyIndex],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      label: Text(
                                        '20',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      storyLength: (int pageIndex) {
                        var statusData = snapshot.data![pageIndex];
                        return statusData.photoUrl.length;
                      },
                      pageLength: snapshot.data!.length,
                    );
            }),
      ),
    );
  }

  getImage(String url) {
    print('VIEWED');
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Image.network(url),
    );
  }

  delete(String statusId, String url, context) async {
    print('WAITTT');
    // statusRef.doc(statusId).update({
    //   'photoUrl': FieldValue.arrayRemove([url])
    // });
    await statusRef.doc(statusId).delete();
    Navigator.pop(context);
  }
}
