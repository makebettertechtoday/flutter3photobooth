import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class PhotoScreen extends StatefulWidget {
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initializeCamera();
  }

  @override
  void dispose() {
    // Reset orientation when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    final frontCamera = cameras?.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    if (frontCamera != null) {
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      // await _controller!.lockCaptureOrientation(CameraOrientation.landscapeRight);
      await _controller!.lockCaptureOrientation(DeviceOrientation.landscapeRight);

      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  void _startCountdownAndTakePhoto() {
    setState(() {
      _countdown = 3; // Start countdown at 3 seconds.
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown == 0) {
        timer.cancel();
        _takePhoto();
      }
    });
  }

  Future<void> _takePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final photo = await _controller!.takePicture();

      // Navigate to the Collection Screen with the captured photo’s path.
      Navigator.pushNamed(
        context,
        '/collection',
        arguments: photo.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Photo'),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Transform(
                      alignment: Alignment.center,
                      // Flip preview and rotate to match landscape orientation
                      transform: Matrix4.identity()
                        ..rotateY(0) // Flip horizontally for front camera
                        ..rotateZ(math.pi), // Rotate to landscape
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                if (_countdown > 0)
                  Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: _startCountdownAndTakePhoto,
        child: Container(
          width: 120.0,
          height: 120.0,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'Take Photo',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
