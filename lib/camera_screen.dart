import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'done_created.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _imageFile;
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initDatabase();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fdo_database.db');
    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE fdo(id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT, color TEXT, size TEXT)",
      );
    });
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      _imageFile = await _cameraController!.takePicture();
      if (_imageFile != null) {
        await GallerySaver.saveImage(_imageFile!.path);
        setState(() {});
      }
    } on CameraException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.description}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _saveFDO(BuildContext context) async {
    if (_imageFile != null && _colorController.text.isNotEmpty && _sizeController.text.isNotEmpty) {
      final directory = await getApplicationDocumentsDirectory();
      final newImagePath = join(directory.path, _imageFile!.name);
      await _imageFile!.saveTo(newImagePath);


      await _database.insert('fdo', {
        'imagePath': newImagePath,
        'color': _colorController.text,
        'size': _sizeController.text,
      });

      final int lastInsertedId = await _getLastInsertedId();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DoneCreatedScreen(
            imageFile: File(newImagePath),
            fdoId: lastInsertedId.toString(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
    }
  }

  Future<int> _getLastInsertedId() async {
    final List<Map<String, dynamic>> results = await _database.rawQuery('SELECT last_insert_rowid()');
    return results.first['last_insert_rowid()'] as int;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        backgroundColor: Colors.blue,
        actions: [
          if (_imageFile != null)
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () {
                _saveFDO(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? CameraPreview(_cameraController!)
                : Image.file(File(_imageFile!.path)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Take a Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(Icons.photo, color: Colors.white),
                  label: Text(
                    'Select from Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _colorController,
                    decoration: InputDecoration(labelText: 'Color'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),//Only letters and spaces
                    ],
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextField(
                    controller: _sizeController,
                    decoration: InputDecoration(labelText: 'Size'),
                    keyboardType: TextInputType.number, //Only numbers
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, //Only digits
                    ],
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
