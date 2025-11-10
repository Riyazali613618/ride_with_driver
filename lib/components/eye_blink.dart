import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:r_w_r/components/app_button.dart' show CustomButton;
import 'package:r_w_r/constants/color_constants.dart';

import '../l10n/app_localizations.dart';

class FaceEyeBlinkCapture extends StatefulWidget {
  final Function(String?) onPhotoCaptured;
  final List<CameraDescription> cameras;

  const FaceEyeBlinkCapture({
    super.key,
    required this.onPhotoCaptured,
    required this.cameras,
  });

  @override
  _FaceEyeBlinkCaptureState createState() => _FaceEyeBlinkCaptureState();
}

class _FaceEyeBlinkCaptureState extends State<FaceEyeBlinkCapture>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  CameraDescription? _frontCamera;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isDetectionStarted = false;
  late String _statusMessage;

  // Eye blink detection
  bool _wasEyeOpen = false;
  bool _isEyeClosed = false;
  bool _captured = false;
  XFile? _capturedImage;
  int _blinkConfidence = 0;
  int _openEyeFrames = 0;

  // Face position tracking
  bool _faceInFrame = false;

  // UI feedback
  Color _frameColor = Colors.blue;

  // Simple face detector options
  final FaceDetectorOptions options = FaceDetectorOptions(
    performanceMode: FaceDetectorMode.fast,
    // Changed to fast for better performance
    enableClassification: true,
    enableLandmarks: false,
    // Disabled for performance
    enableTracking: false,
    // Disabled for performance
    minFaceSize: 0.15,
  );

  final Map<DeviceOrientation, int> orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _faceDetector = GoogleMlKit.vision.faceDetector(options);
    _initializeCameras();
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _statusMessage = "";
  }

  Future<void> _initializeCameras() async {
    try {
      // Use the cameras passed from the parent widget
      if (widget.cameras.isEmpty) {
        _updateStatus("Error: No cameras available", Colors.red);
        return;
      }

      // Try to get the front camera from the provided cameras
      final frontCameras = widget.cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();

      _frontCamera =
          frontCameras.isNotEmpty ? frontCameras.first : widget.cameras.first;
      setState(() {});
    } catch (e) {
      print('Error initializing cameras: $e');
      _updateStatus("Error: Cannot access camera", Colors.red);
    }
  }

  Future<void> _initializeCameraController() async {
    if (_frontCamera == null) return;
    _cameraController = CameraController(
      _frontCamera!,
      ResolutionPreset.high, // Reduced resolution for better performance
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      _updateStatus(
          "Camera ready - Start detection", ColorConstants.primaryColor);
      setState(() {});
    } catch (e) {
      print('Error initializing camera controller: $e');
      _updateStatus("Error: Camera initialization failed", Colors.red);
    }
  }

  void _updateStatus(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _frameColor = color;
    });
  }

  Future<void> _startDetection() async {
    if (_isDetectionStarted || _cameraController == null) return;
    _resetDetection();
    _isDetectionStarted = true;
    _updateStatus("Position your face in the circle", Colors.orange);
    setState(() {});

    await _cameraController!.startImageStream((CameraImage img) async {
      if (_isProcessing || !_isDetectionStarted) return;
      _isProcessing = true;

      // Process every 3rd frame for better performance
      await _processCameraImage(img);
      _isProcessing = false;
    });
  }

  Future<void> _stopDetection() async {
    _isDetectionStarted = false;
    setState(() {});
    try {
      await _cameraController?.stopImageStream();
    } catch (e) {}
  }

  InputImage? _getInputImageFromCameraImage(CameraImage image) {
    if (_frontCamera == null) return null;
    final sensorOrientation = _frontCamera!.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_frontCamera!.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (Platform.isAndroid) {
      if (image.format.group == ImageFormatGroup.yuv420 &&
          image.planes.length == 3) {
        final nv21 = yuv420ToNv21(image);
        return InputImage.fromBytes(
          bytes: nv21,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    } else if (Platform.isIOS) {
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }
    return null;
  }

  Uint8List yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final Uint8List nv21 = Uint8List(ySize + (width * height) ~/ 2);

    // Fill Y
    int index = 0;
    for (int y = 0; y < height; y++) {
      final int rowStart = y * image.planes[0].bytesPerRow;
      nv21.setRange(index, index + width, image.planes[0].bytes, rowStart);
      index += width;
    }

    // Fill interleaved VU (NV21 format)
    int uvIndex = ySize;
    for (int y = 0; y < height ~/ 2; y++) {
      int uRowStart = y * uvRowStride;
      int vRowStart = y * uvRowStride;
      for (int x = 0; x < width ~/ 2; x++) {
        int uIndex = uRowStart + x * uvPixelStride;
        int vIndex = vRowStart + x * uvPixelStride;
        nv21[uvIndex++] = image.planes[2].bytes[vIndex]; // V
        nv21[uvIndex++] = image.planes[1].bytes[uIndex]; // U
      }
    }
    return nv21;
  }

  // Simplified face position check
  bool _isFaceWellPositioned(Face face) {
    // Simple check based on face size
    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;
    // Mirror X coordinate

    // Face should be reasonably sized (not too small or too large)
    return faceWidth > 200 &&
        faceHeight > 200 &&
        faceWidth < 600 &&
        faceHeight < 800;
  }

  Future<void> _processCameraImage(CameraImage img) async {
    try {
      final inputImage = _getInputImageFromCameraImage(img);
      if (inputImage == null) return;

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _faceInFrame = false;
        _wasEyeOpen = false;
        _isEyeClosed = false;
        _blinkConfidence = 0;
        _openEyeFrames = 0;
        _updateStatus(
            "No face detected - Position your face in the circle", Colors.red);
        return;
      }

      final Face face = faces.first;

      // Simplified face position check
      bool faceWellPositioned = _isFaceWellPositioned(face);

      if (!faceWellPositioned) {
        _faceInFrame = false;
        _wasEyeOpen = false;
        _isEyeClosed = false;
        _blinkConfidence = 0;
        _openEyeFrames = 0;
        _updateStatus("Move closer to the camera", Colors.orange);
        return;
      } else {
        _faceInFrame = true;
        _updateStatus("Perfect! Now blink your eyes to capture", Colors.green);
      }

      // Eye blink detection
      double left = face.leftEyeOpenProbability ?? -1.0;
      double right = face.rightEyeOpenProbability ?? -1.0;

      if (left < 0 || right < 0) return;

      // Simplified blink detection
      bool eyesOpen = left > 0.6 && right > 0.6;
      bool eyesClosed = left < 0.3 && right < 0.3;

      if (eyesOpen) {
        _openEyeFrames++;
        if (_openEyeFrames >= 2 && !_wasEyeOpen) {
          _wasEyeOpen = true;
          _isEyeClosed = false;
          _blinkConfidence = 0;
        }

        // Capture after blink
        if (_wasEyeOpen && _isEyeClosed && _blinkConfidence >= 2) {
          if (!_captured) {
            await _captureImage();
          }
          _resetBlinkDetection();
        }
      } else if (eyesClosed && _wasEyeOpen) {
        _blinkConfidence++;
        _openEyeFrames = 0;
        if (_blinkConfidence >= 2) {
          _isEyeClosed = true;
          _updateStatus(
              "Blink detected! Opening eyes...", ColorConstants.primaryColor);
        }
      } else {
        _openEyeFrames = 0;
      }
    } catch (e) {
      print('Error processing camera image: $e');
    }
  }

  void _resetBlinkDetection() {
    _wasEyeOpen = false;
    _isEyeClosed = false;
    _blinkConfidence = 0;
    _openEyeFrames = 0;
  }

  Future<void> _captureImage() async {
    if (_cameraController!.value.isTakingPicture) return;
    try {
      await _stopDetection();
      final XFile file = await _cameraController!.takePicture();
      setState(() {
        _captured = true;
        _capturedImage = file;
      });
      _updateStatus("Image captured successfully!", Colors.green);

      HapticFeedback.mediumImpact();

      // Call the callback function to pass the image path to parent
      widget.onPhotoCaptured(file.path);

      _showCapturedDialog(file);
    } catch (e) {
      print('Error capturing image: $e');
      _updateStatus("Error capturing image", Colors.red);
      // Call callback with null to indicate error
      widget.onPhotoCaptured(null);
    }
  }

  void _resetDetection() {
    setState(() {
      _captured = false;
      _capturedImage = null;
      _faceInFrame = false;
    });
    _resetBlinkDetection();
  }

  void _showCapturedDialog(XFile file) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        // Get screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        // Calculate responsive dimensions
        final dialogWidth = screenWidth * 0.85; // 85% of screen width
        final maxImageWidth = dialogWidth - 48; // Account for padding
        final maxImageHeight = screenHeight * 0.4; // 40% of screen height

        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  localizations.image_captured,
                  style: TextStyle(
                    fontSize:
                        screenWidth < 360 ? 16 : 18, // Responsive font size
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Responsive image container
                Container(
                  constraints: BoxConstraints(
                    maxWidth: maxImageWidth,
                    maxHeight: maxImageHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 3 / 4, // Maintain 3:4 aspect ratio
                      child: Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    localizations.photo_captured_successfully,
                    style: TextStyle(
                      fontSize:
                          screenWidth < 360 ? 14 : 16, // Responsive font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Responsive button layout
            screenWidth < 400
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomButton(
                        text: localizations.use_this_photo,
                        backgroundColor: ColorConstants.primaryColor,
                        textColor: ColorConstants.white,
                        onPressed: () {
                          Navigator.pop(ctx); // Close dialog
                          Navigator.pop(context, file.path);
                        },
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _resetDetection();
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                        ),
                        child: Text(localizations.capture_again),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close dialog
                            Navigator.pop(context,
                                file.path); // Return to parent with image path
                          },
                          child: Text(localizations.use_this_photo),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close dialog only
                            _resetDetection(); // Allow capturing again
                          },
                          child: Text(localizations.capture_again),
                        ),
                      ),
                    ],
                  ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _faceDetector.close();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !_isCameraInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  // Simple circle overlay widget
  Widget _buildSimpleCircleOverlay() {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _faceInFrame ? Colors.green : _frameColor,
            width: 4,
          ),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.all(_faceInFrame ? 8 : 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  (_faceInFrame ? Colors.green : _frameColor).withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Assign localized message dynamically
    if (_statusMessage.isEmpty) {
      _statusMessage = localizations.startDetectionMessage;
    }
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: Text(localizations.capture_image),
        leading: CupertinoNavigationBarBackButton(
          color: ColorConstants.white,
        ),
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_captured)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _resetDetection();
                _startDetection();
              },
              tooltip: localizations.capture_again,
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _frameColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: _frameColor.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _faceInFrame
                      ? Icons.face
                      : _captured
                          ? Icons.check_circle
                          : Icons.face_retouching_natural,
                  color: _frameColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _frameColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Camera Preview with Simple Circle Overlay
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white38,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Camera Preview or Captured Image
                    _capturedImage != null
                        ? Image.file(
                            File(_capturedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : (_isCameraInitialized && _cameraController != null)
                            ? SizedBox(
                                width: double.infinity,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(-1.0,
                                        1.5), // Mirror horizontally for front camera
                                  child: CameraPreview(_cameraController!),
                                ))
                            : Container(
                                color: Colors.grey[900],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 64,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                    // Simple Circle Overlay (only show during detection)
                    if (_isDetectionStarted && !_captured)
                      _buildSimpleCircleOverlay(),
                  ],
                ),
              ),
            ),
          ),

          // Instructions
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  localizations.instructions,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  localizations.face_capture_instructions,
                  // "1. Position your face in the circle\n2. Wait for the green border\n3. Blink your eyes to capture",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),

          // Action Button
          Container(
            padding: EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_isDetectionStarted) {
                    if (!_isCameraInitialized) {
                      await _initializeCameraController();
                    }
                    _startDetection();
                  } else {
                    _stopDetection();
                    _resetDetection();
                  }
                },
                icon: Icon(_isDetectionStarted ? Icons.stop : Icons.play_arrow),
                label: Text(_isDetectionStarted
                    ? "Stop Capturing"
                    : _captured
                        ? "Capture Again"
                        : "Start Capturing"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDetectionStarted
                      ? Colors.red
                      : ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
