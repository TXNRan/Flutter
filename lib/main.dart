import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'scan_page.dart';
import 'image_display_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final hasCamera = cameras.isNotEmpty;
  final firstCamera = hasCamera ? cameras.first : null;
  runApp(MyApp(camera: firstCamera, hasCamera: hasCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription? camera;
  final bool hasCamera;

  const MyApp({
    Key? key,
    required this.camera,
    required this.hasCamera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower Scanner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(camera: camera, hasCamera: hasCamera),
    );
  }
}

@immutable
class MyHomePage extends StatefulWidget {
  final CameraDescription? camera;
  final bool hasCamera;

  const MyHomePage({
    Key? key,
    required this.camera,
    required this.hasCamera,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageDisplayPage(imagePath: pickedFile.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Klasifikasi Anggrek',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo bunga di atas tombol Ambil Foto
            const Icon(
              Icons.local_florist,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.hasCamera
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanPage(camera: widget.camera!),
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: Text(
                widget.hasCamera ? 'Ambil Foto' : 'Kamera Tidak Tersedia',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text(
                'Dari Penyimpanan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
