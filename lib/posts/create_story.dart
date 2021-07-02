import 'package:flutter/material.dart';
import 'package:social_media_app/view_models/posts/story_view_model.dart';

class CreateStory extends StatelessWidget {
  final StoryViewModel viewModel;
  CreateStory({this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Center(
                child: Image.file(
                  viewModel.mediaUrl,
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Theme.of(context).textTheme.headline6.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintText: "Add a caption",
                          hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                        ),
                        maxLines: null,
                        onSaved: (String val) {
                          viewModel.setDescription(val);
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () async {
                        await viewModel.uploadStory(context);
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.send),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
