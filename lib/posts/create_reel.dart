import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/components/custom_audio.dart';
import 'package:social_media_app/components/custom_video_player.dart';
import 'package:social_media_app/models/music_model.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/auth/posts_view_model.dart';

class CreateReel extends StatefulWidget {
  const CreateReel({Key? key}) : super(key: key);

  @override
  _CreateReelState createState() => _CreateReelState();
}

class _CreateReelState extends State<CreateReel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    return LoadingOverlay(
      isLoading: false,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.all(14.0),
              child: InkWell(
                onTap: () {},
                child: Text(
                  'upload',
                  style: TextStyle(
                    // fontSize: 14.0,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => viewModel.pickVideo(
                    context: context,
                    camera: false,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 30,
                    decoration: Theme.of(context).brightness == Brightness.dark
                        ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                offset: Offset(-6.0, -6.0),
                                blurRadius: 16.0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: Offset(6.0, 6.0),
                                blurRadius: 16.0,
                              ),
                            ],
                            color: Color(0xff2B2B2B),
                            borderRadius: BorderRadius.circular(12.0),
                          )
                        : BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: Offset(-6.0, -6.0),
                                blurRadius: 16.0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(6.0, 6.0),
                                blurRadius: 16.0,
                              ),
                            ],
                            color: Color(0xFFEFEEEE),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                    child: viewModel.video == null
                        ? Center(
                            child: Text(
                              'Pick a video',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                        : MiniVideoPlayer(
                            autoPlay: true,
                            videoUrl: viewModel.video?.path ?? "",
                            fromNetwork: false,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width - 30,
                          ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: 150.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        Colors.grey.withOpacity(0.3),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    onPressed: () => selectMusic(viewModel),
                    child: Row(
                      children: [
                        Text(
                          "Pick a song",
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Icon(CupertinoIcons.chevron_down_circle_fill),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Icon(Iconsax.music, size: 15.0),
                    SizedBox(width: 10.0),
                    Text(viewModel.selectedSong ?? 'M HUNCHO - TRANQUILTY'),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Caption Post',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'This is an amazing reel.',
                    focusedBorder: UnderlineInputBorder(),
                  ),
                  maxLines: null,
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectMusic(PostsViewModel viewModel) {
    int? selectedTileIndex;
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    'Select Music',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Divider(),
              ),
              Flexible(
                child: SizedBox(
                  child: StreamBuilder(
                    stream: musicRef.snapshots(),
                    builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var snap = snapshot.data;
                        List docs = snap!.docs;
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, right: 20),
                              child: Divider(),
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            MusicModel song = MusicModel.fromJson(
                              docs[index].data(),
                            );

                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return ListTile(
                                tileColor: selectedTileIndex == index
                                    ? Colors.blue
                                    : null,
                                // Change color when selected
                                onTap: () {
                                  if (selectedTileIndex == index) {
                                    setState(() {
                                      selectedTileIndex = null;
                                    });
                                  } else {
                                    setState(() {
                                      selectedTileIndex = index;
                                    });
                                    print('>>>>>>>>>>>>> ${song.name ?? ""}');
                                    viewModel.setSong(song.name!);
                                  }
                                },
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: CustomAudioPlayer(audioURL: song.url),
                                ),
                                title: Text(song.name ?? ""),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wooble Music',
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                        );
                      } else {
                        return ListView.separated(
                          itemCount: 5,
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, right: 20),
                              child: Divider(),
                            );
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey,
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: ListTile(
                                leading: Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child:
                                        Icon(CupertinoIcons.play, size: 30.0),
                                  ),
                                ),
                                title: Container(
                                  height: 15.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5.0),
                                    Container(
                                      height: 15.0,
                                      width: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.4),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Container(
                                      height: 15.0,
                                      width: 200.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.4),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
