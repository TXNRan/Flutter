import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'image_display_page.dart';

class ScanPage extends StatefulWidget {
  final CameraDescription camera;

  // 1. Tambahkan key parameter dan const constructor
  const ScanPage({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _takePicture() async {
    try {
      // 2. Tangkap context sebelum async gap
      final currentContext = context;
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      // 3. Periksa mounted sebelum navigasi
      if (!currentContext.mounted) return;

      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => ImageDisplayPage(imagePath: image.path),
        ),
      );
    } catch (e) {
      // 4. Ganti print dengan debugPrint
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text( // 5. Tambahkan const
            'Foto Anggrek',
            style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Center(
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: _takePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10
                ),
              ),
              child: const Text(
                  'Ambil Foto',
                  style: TextStyle(color: Colors.white)
              ),
            ),
          )
        ],
      ),
    );
  }
}