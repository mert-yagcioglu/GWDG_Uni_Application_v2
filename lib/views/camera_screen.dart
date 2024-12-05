import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _imageFile;
  String? _predictedObject = '';
  bool _isLoading = false;
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _initDatabase();
  }

  // Kamera başlatma
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print("Kamera başlatılırken hata: $e");
    }
  }

  // Model yükleme
  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
  }

  // Veritabanı başlatma
  Future<void> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fdo_database.db');
    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE fdo(id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT)",
      );
    });
  }

  // Fotoğraf çekme
  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _imageFile = await _cameraController!.takePicture();
      if (_imageFile != null) {
        await GallerySaver.saveImage(_imageFile!.path);
        setState(() {});

        _runObjectDetection(_imageFile!.path);
      }
    } on CameraException catch (e) {
      print('Hata: ${e.code}\nHata Mesajı: ${e.description}');
      setState(() {
        _isLoading = false;
        _predictedObject = 'Kamera hatası: ${e.description}';
      });
    }
  }

  // Galeriden fotoğraf seçme
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });

      _runObjectDetection(image.path);
    }
  }

  // Fotoğrafı iyileştirme ve nesne tespiti
  Future<void> _runObjectDetection(String imagePath) async {
    try {
      File file = File(imagePath);
      img.Image? image = img.decodeImage(file.readAsBytesSync());

      if (image == null) {
        setState(() {
          _predictedObject = 'Fotoğraf okunamadı.';
          _isLoading = false;
        });
        return;
      }

      img.Image denoisedImage = img.gaussianBlur(image, radius: 2);
      img.Image sharpenedImage = img.adjustColor(denoisedImage, contrast: 1.2);
      img.Image resizedImage = img.copyResize(sharpenedImage, width: 224, height: 224);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/resized_image.jpg';
      File resizedFile = File(tempPath)..writeAsBytesSync(img.encodeJpg(resizedImage));

      var recognitions = await Tflite.runModelOnImage(
        path: resizedFile.path,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );

      setState(() {
        _isLoading = false;
        if (recognitions != null && recognitions.isNotEmpty) {
          _predictedObject = 'Tahmin Edilen Nesne: ${recognitions[0]['label']}';
        } else {
          _predictedObject = 'Nesne tespiti yapılamadı. Lütfen tekrar deneyin.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _predictedObject = 'Nesne tanıma hatası: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kamera'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? CameraPreview(_cameraController!)
                : Stack(
              children: [
                Center(
                  child: Image.file(
                    File(_imageFile!.path),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              _predictedObject ?? 'Tahmin yok',
              style: TextStyle(
                color: _predictedObject == 'Nesne tespiti yapılamadı. Lütfen tekrar deneyin.'
                    ? Colors.red
                    : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text('Fotoğraf Çek', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(Icons.photo, color: Colors.white),
                  label: Text('Galeriden Seç', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
