import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MyStoragePage2 extends StatefulWidget{

  Function _function;

  MyStoragePage2({@required Function function}) {
    _function = function;
  }

  @override
  _MyStoragePageState2 createState() => new _MyStoragePageState2();
}

class _MyStoragePageState2 extends State<MyStoragePage2>{
  String _path;

  //upload funkcia
  uploadFile(String filePath) async {
    print('funckia uploadFile $filePath');
    final ByteData bytes = await rootBundle.load(filePath);
    final Directory tempFile = Directory.systemTemp; // filePath dame do docasneho pricinku
    String extension = filePath.substring(filePath.length - 3); //vybratie poslednych 3 pismenok - urcenie pripony
    final String fileName = "${Uuid().v4()}.$extension"; // vytvorenie mena obrazka .. uuid radom cisla,pismenka
    final File imageFile = File('${tempFile.path}/$fileName'); //vytvorenie objektu-obrazka
    imageFile.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write); //ci dobry access

    //pridanie obrazka
    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask task = ref.putFile(imageFile);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    _path = downloadUrl.toString();
    widget._function(_path);
    print(_path); // url cesta pre Klaud
  }



  //funkcia na pridanie obrazku z galerie
  File sampleImage;
  Future getImage() async{
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );
    setState(() {
      sampleImage = tempImage;
    });
  }




  //funkcia na pridanie obrazku z camery
  File sampleImage2;
  Future getImage2() async{
    var tempImage2 = await ImagePicker.pickImage(
        source: ImageSource.camera
    );
    setState(() {
      sampleImage2 = tempImage2;
    });
  }



  //dizajn
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
         new Center(
            child: sampleImage == null && sampleImage2 == null
                ? Text('Select an Image')
                : sampleImage != null ? enableUpload() : enableUpload2(),
         ),
//          new Center(
//            child: sampleImage2 == null
//                ? Text('Select an Image')
//                : enableUpload2(),
//          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: new FloatingActionButton(
                  onPressed: getImage,
                  tooltip: 'Add Image',
                  child: new Icon(Icons.add_photo_alternate),
                  backgroundColor: Colors.pink,
                  mini: true,
                ),padding: EdgeInsets.all(15.0),
              ),
              Container(
                child: new FloatingActionButton(
                  onPressed: getImage2,
                  tooltip: 'Add Image',
                  child: new Icon(Icons.add_a_photo),
                  backgroundColor: Colors.pink,
                  mini: true,
                ),padding: EdgeInsets.all(15.0)
              ),
            ],
          )
        ]
    );
  }



  Widget enableUpload() {
    print('upload image from gallery');
    String filePath = sampleImage.path;
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width: 300.0,),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.pinkAccent,
            onPressed: () {
              uploadFile(filePath);
            },
            //onPressed: uploadFile(filePath),
          ),
        ],
      ),
    );
  }

  Widget enableUpload2() {
    print('upload image from camera');
    String filePath = sampleImage2.path;
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage2, height: 300.0, width: 300.0,),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.pinkAccent,
            onPressed: () {
              uploadFile(filePath);
            },
            //onPressed: uploadFile(filePath),
          ),
        ],
      ),
    );
  }
}
