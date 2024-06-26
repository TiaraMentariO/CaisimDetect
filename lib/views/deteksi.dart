import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dataSawi.dart'; // Sesuaikan dengan lokasi file jika berbeda
import 'package:tugasakhirsawihijau/data/database_helper.dart'; // Sesuaikan dengan lokasi file jika berbeda

class Result {
  final String label;
  final String latinName;
  final double confidence;
  final String description;
  final String handling;
  final String imagePath;

  Result({
    required this.label,
    required this.latinName,
    required this.confidence,
    required this.description,
    required this.handling,
    required this.imagePath,
  });
}

class DeteksiView extends StatefulWidget {
  const DeteksiView({Key? key}) : super(key: key);

  @override
  State<DeteksiView> createState() => _DeteksiViewState();
}

class _DeteksiViewState extends State<DeteksiView> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  String _lastImagePath = '';
  Result? _result;
  late DataSawi _dataSawi; // Perubahan di sini untuk late initialization

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
    _dataSawi = DataSawi(); // Inisialisasi setelah initState
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model/model.tflite',
        labels: 'assets/model/labels.txt',
      );
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<Result?> predictUsingTFLite(String imagePath) async {
    try {
      final List<dynamic>? dynamicResults = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );
      if (dynamicResults != null && dynamicResults.isNotEmpty) {
        final int predictionIndex = dynamicResults[0]['index'] as int;
        final String label = dynamicResults[0]['label'] as String;
        final double confidence = dynamicResults[0]['confidence'] as double;

        // Check if the predictionIndex is valid
        if (predictionIndex < _dataSawi.treatment.length) {
          final String latinName =
              _dataSawi.treatment[predictionIndex]['latinName'] ?? '';
          return Result(
            label: label,
            latinName: latinName,
            confidence: confidence,
            description:
                _dataSawi.treatment[predictionIndex]['characteristics'] ?? '',
            handling: _dataSawi.treatment[predictionIndex]['handling'] ?? '',
            imagePath: imagePath,
          );
        } else {
          return Result(
            label: 'Tidak Diketahui',
            latinName: 'Tidak Diketahui',
            confidence: confidence,
            description: '',
            handling: '',
            imagePath: imagePath,
          );
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<void> takePictureAndPredict() async {
    if (!_cameraController!.value.isTakingPicture) {
      await _cameraController?.setFlashMode(FlashMode.off);
      final XFile? image = await _cameraController!.takePicture();
      final String imagePath = image?.path ?? '';
      _lastImagePath = imagePath;
      final result = await predictUsingTFLite(imagePath);

      if (result != null) {
        setState(() {
          _result = result;
        });

        await DatabaseHelper().insertData('PrediksiHama', {
          'jenis_hama': result.label,
          'nama_latin': result.latinName,
          'persentase': result.confidence * 100,
          'ciri_ciri': result.description,
          'cara_penanganan': result.handling,
          'path': result.imagePath,
        });
      }
    }
  }

  Future<void> _getImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final String imagePath = pickedFile.path;
      _lastImagePath = imagePath;
      final result = await predictUsingTFLite(imagePath);

      if (result != null) {
        setState(() {
          _result = result;
        });

        await DatabaseHelper().insertData('PrediksiHama', {
          'jenis_hama': result.label,
          'nama_latin': result.latinName,
          'persentase': result.confidence * 100,
          'ciri_ciri': result.description,
          'cara_penanganan': result.handling,
          'path': result.imagePath,
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUnknown = _result?.latinName == 'Tidak Diketahui';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Scrollbar(
                  thickness: 6,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back,
                                    size: 30, color: Colors.black),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Deteksi Hama',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'InterMedium',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _cameraController != null &&
                                _cameraController!.value.isInitialized
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          1 /
                                          _cameraController!.value.aspectRatio,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: _result != null
                                          ? Image.file(
                                              File(_lastImagePath),
                                              fit: BoxFit.cover,
                                            )
                                          : CameraPreview(_cameraController!),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  if (_result != null)
                                    SingleChildScrollView(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              "Hasil",
                                              style: TextStyle(
                                                fontFamily: "InterMedium",
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Center(
                                            child: Text(
                                              "${_result!.label}",
                                              style: TextStyle(
                                                fontFamily: "Yeseva",
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal,
                                                color: _result != null &&
                                                        _result!.latinName ==
                                                            'Tidak Diketahui'
                                                    ? Colors
                                                        .black // Change to black for unknown results
                                                    : _result != null &&
                                                            _result!.label ==
                                                                'Tanpa Hama'
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                          if (isUnknown) ...[
                                            SizedBox(height: 5),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/images/icon_persentase.png',
                                                      width: 35,
                                                      height: 35),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "${(_result!.confidence * 100).toStringAsFixed(2)}%",
                                                    style: TextStyle(
                                                      fontFamily: "InterMedium",
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          if (!isUnknown) ...[
                                            SizedBox(height: 5),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (_result!.label ==
                                                      'Kumbang Daun')
                                                    Image.asset(
                                                        'assets/images/icon_kumbang.png',
                                                        width: 35,
                                                        height: 35),
                                                  if (_result!.label ==
                                                      'Ulat Krop Kubis')
                                                    Image.asset(
                                                        'assets/images/icon_ulat_krop.png',
                                                        width: 35,
                                                        height: 35),
                                                  if (_result!.label ==
                                                      'Ulat Perusak Daun')
                                                    Image.asset(
                                                        'assets/images/icon_ulat_daun.png',
                                                        width: 35,
                                                        height: 35),
                                                  if (_result!.label ==
                                                      'Tanpa Hama')
                                                    Image.asset(
                                                        'assets/images/icon_tanpa_hama.png',
                                                        width: 35,
                                                        height: 35),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "${_result?.latinName}",
                                                    style: TextStyle(
                                                      fontFamily: "InterMedium",
                                                      fontSize: 18,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      'assets/images/icon_persentase.png',
                                                      width: 35,
                                                      height: 35),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "${(_result!.confidence * 100).toStringAsFixed(2)}%",
                                                    style: TextStyle(
                                                      fontFamily: "InterMedium",
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  "Ciri - Ciri :",
                                                  style: TextStyle(
                                                    fontFamily: "InterMedium",
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: _result!.description
                                                      .split('\n')
                                                      .map((String item) => Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "• ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  item,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "Ruda",
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ))
                                                      .toList(),
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  "Cara Penanganan :",
                                                  style: TextStyle(
                                                    fontFamily: "InterMedium",
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: _result!.handling
                                                      .split('\n')
                                                      .where((item) => item
                                                          .isNotEmpty) // Filter item yang tidak kosong
                                                      .map((String item) => Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "• ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  item,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "Ruda",
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ))
                                                      .toList(),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: takePictureAndPredict,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13.5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              color: Color.fromARGB(
                                                  255, 104, 163, 27),
                                            ),
                                            child: Text(
                                              "Ambil dari Kamera",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: "InterMedium",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        InkWell(
                                          onTap: _getImageFromGallery,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13.5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              color: Color.fromARGB(
                                                  255, 104, 163, 27),
                                            ),
                                            child: Text(
                                              "Ambil dari Galeri",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: "InterMedium",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
