import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recog/widgets/textdetectorpainter.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  final String imagePath;
  DetailScreen(this.imagePath);
  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path);

  final String path;
  Size _imageSize;
  String recognizedText = 'Recognizing email...';

  List<TextElement> _elements = [];

  void _initializeRecognition() async {
    final File imageFile = File(path);
    if (imageFile != null) {
      await _getImageSize(imageFile);
    }
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regEx = RegExp(pattern);
    String mailAddress = "";
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          mailAddress += line.text + '\n';
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
      }
    }
    if (this.mounted) {
      setState(() {
        recognizedText = mailAddress;
      });
    }
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {
    _initializeRecognition();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      body: _imageSize != null
          ? Stack(
              children: [
                Center(
                  child: Container(
                    width: double.maxFinite,
                    color: Colors.transparent,
                    child: CustomPaint(
                      foregroundPainter:
                          TextDetectorPainter(_imageSize, _elements),
                      child: AspectRatio(
                        aspectRatio: _imageSize.aspectRatio,
                        child: Image.file(
                          File(path),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 15,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Identified Emails',
                                  style: GoogleFonts.raleway(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy),
                                splashColor: Colors.white,
                                highlightColor: Colors.white,
                                onPressed: () {
                                  Clipboard.setData(
                                    new ClipboardData(text: recognizedText),
                                  );
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.black,
                                      content: Text(
                                        'Email copied',
                                        style: GoogleFonts.raleway(
                                            color: Colors.orange),
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.white,
                            height: 60,
                            child: SingleChildScrollView(
                              child: Text(
                                recognizedText,
                                style: GoogleFonts.raleway(
                                    fontSize: 17, fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
