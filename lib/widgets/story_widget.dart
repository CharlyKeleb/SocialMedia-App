import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/story_model.dart';
import 'package:social_media_app/posts/story/status_view.dart';
import 'package:social_media_app/view_models/status/status_view_model.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Container(
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: FutureBuilder<List<Status>>(
          future: viewModel.getStatus(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  var statusData = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) =>
                                    StatusScreen(status: statusData),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
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
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 35.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  statusData.profilePic,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          statusData.username,
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              return Text('No Stories');
            }
          },
        ),
      ),
    );
  }
}
