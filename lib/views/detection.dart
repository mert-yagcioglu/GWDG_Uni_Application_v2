import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class DetectionPage extends StatefulWidget {
  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  bool isWorking = false;
  String results = "";
  late CameraController cameraController;
  CameraImage? imgCamera;
  final picker = ImagePicker();
  bool isCameraInitialized = false; //Kameranın başlatılıp başlatılmadığını kontrol etmeye yarıyor.

  // Eğitilmiş modeli bu şekilde yüklüyoruz!!
  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
      );
    } catch (e) {
      print("Model yüklenirken hata oluştu: $e");
    }
  }

  // Kamerayı başlatmak için
  void initCamera() {
    if (isCameraInitialized) {
      print("Kamera zaten başlatılmış.");
      return; //Kamera zaten başlatıldıysa, işlemi durdur.
    }

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    cameraController.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        isCameraInitialized = true;     //Kamera başlatıldıktan sonra bu durumu kaydediyoruz.
        cameraController.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            imgCamera = imageFromStream;
            runModelOnStreamFrames();
          }
        });
      });
    }).catchError((e) {
      print("Kamera başlatma hatası: $e");
    });
  }

  //Modeli kamera  görüntüleri üzerinde çalıştırma
  Future<void> runModelOnStreamFrames() async {
    if (imgCamera != null) {
      try {
        var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera!.planes.map((plane) => plane.bytes).toList(),
          imageHeight: imgCamera!.height,
          imageWidth: imgCamera!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.3,        //Treshold değerini 0.1'den 0.3'e çıkardığım için doğru sonuç aldım. Daha yüksek değerler denenebilir!!!!
          asynch: true,
        );

        results = "";

        recognitions?.forEach((response) {
          results +=
          "Nesne: ${response["label"]} \n Güven: ${(response["confidence"] as double).toStringAsFixed(2)}\n";
        });


        setState(() {
          results;
        });
      } catch (e) {
        print("Model çalıştırma hatası: $e");
      } finally {
        isWorking = false;
      }
    }
  }

  //Çalışan kameradan fotoğraf çekme fonksiyonu
  Future<void> captureImage() async {
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        //Fotoğraf seçildiyse, burada gerekli işlemler yapılabilir.
        //Fotoğraf üzerinde işlem yapabiliriz yadaa kaydedebiliriz.
        print("Fotoğraf çekildi: ${photo.path}");
      }
    } catch (e) {
      print("Fotoğraf çekme hatası: $e");
    }
  }

  //Galeriden istenen fotoğrafı seçme
  Future<void> selectImageFromGallery() async {
    try {
      final XFile? selectedPhoto =
      await picker.pickImage(source: ImageSource.gallery);
      if (selectedPhoto != null) {
        //Galeriden seçtiğimiz fotoğrafı alabiliriz.
        //Burada da gerekli işlemleri yapabiliriz.
        print("Fotoğraf seçildi: ${selectedPhoto.path}");
      }
    } catch (e) {
      print("Fotoğraf seçme hatası: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('Detection Page'),
            backgroundColor: Colors.blue,
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              children: [
                Stack(
                  children: [
                    //Center(
                    //   child: Container(
                     //   color: Colors.black,
                     //   height: 400,
                    //    width: 360,
                    //    child: Image.asset("assets/camera.jpg"),
                    //  ),
                    //),
                    Center(
                      child: TextButton(
                        onPressed: initCamera,
                        child: Container(
                          margin: EdgeInsets.only(top: 35),
                          height: 400,
                          width: 360,
                          child: imgCamera == null
                              ? Icon(
                            Icons.photo_camera_front,
                            color: Colors.blueAccent,
                            size: 30,
                          )
                              : AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      results,
                      style: TextStyle(
                        backgroundColor: Colors.black87,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


