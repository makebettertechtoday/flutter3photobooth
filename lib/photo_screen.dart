import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
    _initializeCamera();
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
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
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
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi), // Flip horizontally
                  child: CameraPreview(_controller!),
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
