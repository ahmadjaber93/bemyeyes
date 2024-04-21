class AssetsManager {
  static const String aiPath = 'assets/ai_models';
  static const String imagePath = 'assets/images';
  static const String audioPath = 'audio';

  static const String mobilenetModelPath = '$aiPath/mobilenet_v1.tflite';
  static const String mobilenetLabelsPath = '$aiPath/mobilenet_v1.txt';
  static const String yolov2ModelPath = '$aiPath/yolov2_tiny.tflite';
  static const String yolov2LabelsPath = '$aiPath/yolov2_tiny.txt';

  static const String noCamera = '$imagePath/no-camera.png';

  static const String turnOffAudio = '$audioPath/turn-off.mp3';
  static const String turnOnAudio = '$audioPath/turn-on.mp3';
}
