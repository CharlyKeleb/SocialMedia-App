import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:social_media_app/utils/application.dart';

List<CameraDescription>? cameras;

class CreateStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CameraHome();
  }
}

class CameraHome extends StatefulWidget {
  @override
  _CameraHomeState createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CameraController? controller;
  int _cameraIndex = 0;
  bool isShowGallery = true;
  Future<List<String>>? _images;
  PanelController? _panelController;
  String? videoPath;

  // Permissions
  bool isPermissionsGranted = false;
  List<Permission> permissionsNeeded = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();

    initScreen();
    _panelController = new PanelController();
  }

  void initScreen() async {
    if (await allPermissionsGranted()) {
      setState(() {
        isPermissionsGranted = true;
      });
      startCamera();
    } else {
      requestPermission();
    }
  }

  void startCamera() {
    _initCamera(_cameraIndex);
    _getGalleryImages();
  }

  Future<bool> allPermissionsGranted() async {
    bool resVideo = await Permission.camera.isGranted;
    bool resAudio = await Permission.microphone.isGranted;
    return resVideo && resAudio;
  }

  void requestPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await permissionsNeeded.request();
    if (statuses.values.every((status) => status == PermissionStatus.granted)) {
      // Either the permission was already granted before or the user just granted it.
      setState(() {
        isPermissionsGranted = true;
      });
      startCamera();
    } else {
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text('Permission not granted'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void refreshGallery() {
    _getGalleryImages();
  }

  void _getGalleryImages() async {
    _images = ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DCIM)
        .then((path) {
      List<String> paths = <String>[];
      Directory dir2 = new Directory(path);
      // execute an action on each entry
      dir2.listSync(recursive: true).forEach((f) {
        if (f.path.contains('.jpg')) {
          paths.add(f.path);
        }
      });
      // Order files based on last modified
      // TODO: This is not good for many files. Need to find more efficient method.
      paths.sort((a, b) {
        File fileA = File(a);
        File fileB = File(b);
        return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
      });
      return paths;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _disposeCamera();
    super.dispose();
  }

  _disposeCamera() async {
    if (controller != null) {
      await controller!.dispose();
    }
  }

  _initCamera(int index) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameras![index], ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(
        child: Text(
          '',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            // _minHeight = 0;
            isShowGallery = !isShowGallery;
          });
        },
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
      );
    }
  }

  double _opacity = 0.0;
  double _minHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlidingUpPanel(
              controller: _panelController,
              maxHeight: MediaQuery.of(context).size.height,
              minHeight: _minHeight,
              panel: Opacity(
                opacity: _opacity,
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      color: Colors.blue,
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        _panelController!.close();
                      },
                    ),
                    actions: <Widget>[
                      IconButton(
                        color: Colors.blue,
                        icon: Icon(Icons.check_box),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  body: Container(
                    color: Colors.white,
                    child: FutureBuilder<List<String>>(
                        future: _images,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (!isPermissionsGranted) {
                            return Center(
                              child: Text('Permission not granted'),
                            );
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                              );
                            case ConnectionState.active:
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                              );
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              if (snapshot.data!.length <= 0)
                                return Container();
                              return CustomScrollView(
                                slivers: <Widget>[
                                  SliverPersistentHeader(
                                    pinned: true,
                                    floating: false,
                                    delegate:
                                        _SliverAppBarDelegate(text: 'RECENTLY'),
                                  ),
                                  SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 2.0,
                                      crossAxisSpacing: 2.0,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        return GalleryItemThumbnail(
                                          heroId: 'itemPanel-$index',
                                          height: 150,
                                          resource: snapshot.data![index],
                                          onTap: () {
                                            Application.router!.navigateTo(
                                              context,
                                              "/edit/image?resource=${Uri.encodeComponent(snapshot.data![index])}&id=itemPanel-$index",
                                              transition: TransitionType.fadeIn,
                                            );
                                          },
                                          margin: null,
                                        );
                                      },
                                      childCount: snapshot.data!.length,
                                    ),
                                  )
                                ],
                              );
                          }
                        }),
                  ),
                ),
              ),
              color: Color.fromARGB(0, 0, 0, 0),
              collapsed: isShowGallery ? _buildCollapsedPanel() : Container(),
              body: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        controller != null && controller!.value.isRecordingVideo
                            ? Colors.red
                            : Colors.black,
                    width: 2.0,
                  ),
                  color: Colors.black,
                ),
                child: _cameraPreviewWidget(),
              ),
              onPanelSlide: (double pos) {
                setState(() {
                  _opacity = pos;
                });
              },
            ),
            Positioned(
              bottom: 8.0,
              child: Opacity(
                  opacity: 1 - _opacity,
                  child: Column(
                    children: <Widget>[
                      _buildCameraControls(),
                      Container(
                          child: Text(
                        'Hold for video, tap for photo',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ))
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  void _toggleCamera() {
    setState(() {
      if (_cameraIndex == 0)
        _cameraIndex = 1;
      else
        _cameraIndex = 0;
    });
    _initCamera(_cameraIndex);
  }

  Widget _buildCollapsedPanel() {
    return Container(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.keyboard_arrow_up,
            color: Colors.white,
          ),
          _buildGalleryItems(),
        ],
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> _takePicture() async {
    if (!controller!.value.isInitialized) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Error: camera is not initialized')));
    }
//    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DCIM);
    //await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller!.value.isTakingPicture) {
      return '';
    }

    try {
      XFile picture = await controller!.takePicture();
      picture.saveTo(filePath);
    } on CameraException catch (e) {
      // TODO: Can't use this here.
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
    }
    return filePath;
  }

  Future<String> startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Error: camera is not initialized')));
      return '';
    }

    final String dirPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DCIM);
    //await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller!.value.isRecordingVideo) {
      return '';
    }

    try {
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
      return '';
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.stopVideoRecording();
    } on CameraException catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
      return null;
    }

    // await _startVideoPlayer();
  }

  void onTakePictureButtonPressed() {
    _takePicture().then((String filePath) {
      if (mounted) {
        setState(() {});
        if (filePath != null) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Picture saved to $filePath')));
          refreshGallery();
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) {
        setState(() {});
      }
      if (filePath != null) {
        refreshGallery();
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Video recorded to $videoPath')));
    });
  }

  Widget _buildCameraControls() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.flash_off),
            color: Colors.white,
            onPressed: isPermissionsGranted ? () {} : null,
          ),
          GestureDetector(
              child: Icon(
                Icons.panorama_fish_eye,
                size: 70.0,
                color: Colors.white,
              ),
              onTap: isPermissionsGranted
                  ? () {
                      if (controller == null ||
                          !controller!.value.isInitialized ||
                          controller!.value.isRecordingVideo) return;
                      onTakePictureButtonPressed();
                    }
                  : null,
              onLongPress: isPermissionsGranted
                  ? () {
                      if (controller == null ||
                          !controller!.value.isInitialized ||
                          controller!.value.isRecordingVideo) return;
                      onVideoRecordButtonPressed();
                    }
                  : null,
              onLongPressUp: isPermissionsGranted
                  ? () {
                      if (controller == null ||
                          !controller!.value.isInitialized ||
                          !controller!.value.isRecordingVideo) return;
                      onStopButtonPressed();
                    }
                  : null),
          IconButton(
            icon: Icon(Icons.switch_camera),
            color: Colors.white,
            highlightColor: Colors.green,
            splashColor: Colors.red,
            onPressed: isPermissionsGranted ? _toggleCamera : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItems() {
    return Container(
      height: 80.0,
      child: FutureBuilder<List<String>>(
          future: _images,
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (!isPermissionsGranted) {
              return Center(
                child: Text(
                  'Permission not granted',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                );
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.data!.length <= 0) return Container();
                List<String> displayedData = snapshot.data!.sublist(0, 10);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemCount: displayedData.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    //print(snapshot.data[i]);
                    return GalleryItemThumbnail(
                      heroId: 'item-$i',
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      height: 81,
                      resource: displayedData[i],
                      onTap: () {
                        Application.router!.navigateTo(
                          context,
                          "/edit/image?resource=${Uri.encodeComponent(displayedData[i])}&id=item-$i",
                          transition: TransitionType.fadeIn,
                        );
                      },
                    );
                  },
                );
            }
          }),
    );
  }
}

class GalleryItemThumbnail extends StatelessWidget {
  GalleryItemThumbnail({
    required this.heroId,
    required this.resource,
    required this.onTap,
    required this.height,
    required this.margin,
  });

  final String heroId;
  final double height;
  final String resource;
  final GestureTapCallback onTap;
  final margin;

  @override
  Widget build(BuildContext context) {
    //print('gallery: img-$id');
    return Container(
      margin: margin,
      color: Color.fromRGBO(255, 255, 255, 0.05),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Hero(
              tag: heroId,
              child: Image.file(
                new File(resource),
                width: height,
                height: height,
                cacheWidth: height.ceil(),
                cacheHeight: height.ceil(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.text,
  });

  final String text;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        color: Colors.white,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.bold),
        ));
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => 46.0;

  @override
  double get minExtent => 46.0;
}
