import 'dart:typed_data';

import 'package:tflite/tflite.dart';

Future<String?> load_mobilenet() async{
  String? res = await Tflite.loadModel(
      model: "assets/models/v3-large_224_1.0_float.tflite",
      labels: "assets/labels/imagenet_labels.txt",
      numThreads: 1, // defaults to 1
      isAsset: true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate: false // defaults to false, set to true to use GPU delegate
  );

  return res;
}

Future<String?> load_yolov2() async{
  String? res = await Tflite.loadModel(
      model: "assets/models/yolov2_tiny.tflite",
      labels: "assets/labels/yolov2_tiny.txt",
      numThreads: 1, // defaults to 1
      isAsset: true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate: false // defaults to false, set to true to use GPU delegate
  );

  return res;
}

Future<List?> run_mobilenet_by_path(String filepath) async {
  var recognitions = await Tflite.runModelOnImage(
      path: filepath,
      // required
      imageMean: 0.0,
      // defaults to 117.0
      imageStd: 255.0,
      // defaults to 1.0
      numResults: 2,
      // defaults to 5
      threshold: 0.2,
      // defaults to 0.1
      asynch: true // defaults to true
  );

  return recognitions;
}

Future<List?> run_ssd_mobilenet_by_path(String filepath) async {
  var recognitions = await Tflite.detectObjectOnImage(
      path: filepath,       // required
      model: "SSDMobileNet",
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.4,       // defaults to 0.1
      numResultsPerClass: 2,// defaults to 5
      asynch: true          // defaults to true
  );

  return recognitions;
}

Future<List?> run_yolov2_by_path(String filepath) async {
  var recognitions = await Tflite.detectObjectOnImage(
      path: filepath,       // required
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      threshold: 0.3,       // defaults to 0.1
      numResultsPerClass: 2,// defaults to 5
      //anchors: anchors,     // defaults to [0.57273,0.677385,1.87446,2.06253,3.33843,5.47434,7.88282,3.52778,9.77052,9.16828]
      blockSize: 32,        // defaults to 32
      numBoxesPerBlock: 5,  // defaults to 5
      asynch: true          // defaults to true
  );
  return recognitions;
}

Future<List?> run_yolov2_by_binary(Uint8List buffer) async {
  var recognitions = await Tflite.detectObjectOnBinary(
      binary: buffer,
      // required
      model: "YOLO",
      threshold: 0.3,
      // defaults to 0.1
      numResultsPerClass: 2,
      // defaults to 5
      //anchors: anchors,
      // defaults to [0.57273,0.677385,1.87446,2.06253,3.33843,5.47434,7.88282,3.52778,9.77052,9.16828]
      blockSize: 32,
      // defaults to 32
      numBoxesPerBlock: 5,
      // defaults to 5
      asynch: true // defaults to true
  );
}

Future<String> load_test()async{
  return "test";
}



Future<void> release() async{
  await Tflite.close();
}