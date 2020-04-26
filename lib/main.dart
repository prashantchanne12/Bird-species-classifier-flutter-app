import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        print('Loaded Successfully!!');
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff6c5ce7),
        title: Text(
          'Bird Species',
          style: TextStyle(
            fontFamily: 'Monst',
            letterSpacing: 1.0,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _image == null
                        ? Text('No Image Selected')
                        : Container(
                            height: 350,
                            width: 300,
                            child: Material(
                              elevation: 2.0,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 350,
                                    width: 300,
                                    child: (Image.file(
                                      _image,
                                      fit: BoxFit.fitWidth,
                                    )),
                                  )
                                ],
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    _outputs != null
                        ? Container(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              "${_outputs[0]['label'].toString().toLowerCase()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                                fontFamily: "Monst",
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
      floatingActionButton: BoomMenu(
        backgroundColor: const Color(0xff6c5ce7),
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        children: [
          MenuItem(
            child: Icon(
              Icons.camera,
              color: Colors.white,
            ),
            title: "Picture",
            titleColor: Colors.white,
            subtitle: "Take a Picture",
            subTitleColor: Colors.white,
            backgroundColor: const Color(0xff0984e3),
            onTap: () => takePicture(),
          ),
          MenuItem(
            child: Icon(
              Icons.image,
              color: Colors.black,
            ),
            title: "Gallery",
            titleColor: Colors.black,
            subtitle: "Open a Gallery",
            subTitleColor: Colors.black,
            backgroundColor: Colors.white,
            onTap: () => pickImage(),
          ),
        ],
      ),
    );
  }

  takePicture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 180,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      print(output);
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/fullmodel_2.tflite",
      labels: "assets/labels_2.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
