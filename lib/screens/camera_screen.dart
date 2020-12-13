import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recog/main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:recog/screens/detail_screen.dart';
import 'package:recog/widgets/drawer.dart';
import 'package:recog/widgets/menu_button.dart';
import 'package:page_transition/page_transition.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print('Controller is not initialized');
      return null;
    }

    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();
    String formattedDateTime = dateTime.replaceAll(' ', '');

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String recogDir = '${appDocDir.path}/Photos/Recog\ Images';
    await Directory(recogDir).create(recursive: true);
    final String imagePath = '$recogDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print('Processing is in progress');
      return null;
    }

    try {
      await _controller.takePicture(imagePath);
    } on CameraException catch (e) {
      print('Camera Exception: $e');
      return null;
    }
    return imagePath;
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: MainDrawer(),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? Stack(children: [
                  CameraPreview(_controller),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        padding: EdgeInsets.all(20),
                        child: Icon(Icons.photo_camera_outlined,
                            size: 30, color: Colors.white),
                        shape: CircleBorder(),
                        color: Colors.transparent,
                        elevation: 0,
                        onPressed: () async {
                          await _takePicture().then(
                            (String path) {
                              if (path != null) {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.scale,
                                    alignment: Alignment.bottomCenter,
                                    child: DetailScreen(path),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  )
                ])
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: menuButton,
                  onPressed: () => scaffoldKey.currentState.openDrawer(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
