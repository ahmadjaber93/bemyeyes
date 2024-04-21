import 'dart:developer';
import 'package:bemyeyes/utils/assets_manager.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  List<String> detectedLabels = [];
  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  late FlutterTts flutterTts;
  bool showCamera = true;

  void changeShowCamera(passedShowCamera) async {
    showCamera = passedShowCamera;
    update(); // Notify listeners to update UI if needed.
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
    initTTS();
  }

  @override
  void dispose() {
    cameraController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void initTTS() {
    flutterTts = FlutterTts();

    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });
  }

  // New method to stop the camera.
  void stopCamera() async {
    await cameraController.stopImageStream();
    // Consider setting isCameraInitialized to false if you want to re-initialize the camera later.
    isCameraInitialized(false);
    update(); // Notify listeners to update UI if needed.
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((_) {
        isCameraInitialized(true);
        cameraController.startImageStream((image) {
          if (showCamera) {
            cameraCount++;
            if (cameraCount % 10 == 0) {
              cameraCount = 0;
              objectDetector(image);
            }
            update();
          }
        });
      });
    } else {
      log("Permission denied");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: AssetsManager.mobilenetModelPath,
      labels: AssetsManager.mobilenetLabelsPath,
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetector(CameraImage image) async {
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) => e.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResults: 1,
    );
    if (recognitions != null && recognitions.isNotEmpty) {
      log("recognitions $recognitions");
      var ourDetectedObject = recognitions.first;
      // Ensure that 'confidence' is a number and not null before multiplying.
      // This condition checks that 'confidence' exists and is above 0.45 (after multiplying by 100)
      var confidence = ourDetectedObject['confidence'] as double?;
      if (confidence != null && confidence * 100 > 45) {
        String label = ourDetectedObject['label'];
        if (!detectedLabels.contains(label)) {
          // Ensure label is new
          detectedLabels.add(label);
          speakLabel(label);
        }
      }
    }
    update();
  }

  void speakLabel(String label) async {
    if (await flutterTts.isLanguageAvailable("en-US")) {
      await flutterTts.speak(label);
    }
  }
}
