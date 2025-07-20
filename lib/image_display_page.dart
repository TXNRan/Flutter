import 'package:flutter/material.dart';
import 'dart:io';
import 'classifier.dart';

// import deskripsi genus
import 'genus_descriptions.dart';

class ImageDisplayPage extends StatefulWidget {
  final String imagePath;
  const ImageDisplayPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  late Classifier _classifier;
  bool _isLoading = true;
  String _classification = '';
  double _confidence = 0.0;
  int _genusIndex = 0;

  @override
  void initState() {
    super.initState();
    _classifier = Classifier();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    await _classifier.loadModel();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final result = await _classifier.classifyImage(File(widget.imagePath));
      setState(() {
        _classification = result['label'];
        _confidence = result['maxProb'];
        _genusIndex = result['index'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> _getSpeciesData(int index) {
    final speciesData = [
      [
        {'image': 'assets/Cattleya/intermedia/cattleya_intermedia.jpg', 'name': 'Cattleya intermedia'},
        {'image': 'assets/Cattleya/labiatacoerulea/cattleya_labiatacoerulea.jpg', 'name': 'Cattleya labiata coerulea'},
        {'image': 'assets/Cattleya/walkeriana/cattleya_walkeriana.jpg', 'name': 'Cattleya walkeriana'},
      ],
      [
        {'image': 'assets/Dendrobium/aphylum/dendrobium_aphylum.jpg', 'name': 'Dendrobium aphylum'},
        {'image': 'assets/Dendrobium/macrophylum/dendrobium_macrophylum.jpg', 'name': 'Dendrobium macrophylum'},
        {'image': 'assets/Dendrobium/spectabile/dendrobium_spectabile.jpg', 'name': 'Dendrobium spectabile'},
      ],
      [
        {'image': ''},
        {'image': ''},
        {'image': ''},
      ],
      [
        {'image': 'assets/Oncidium/brassia/oncidium_brassia.jpg', 'name': 'Oncidium brassia'},
        {'image': 'assets/Oncidium/goldenshower/oncidium_goldenshower.jpg', 'name': 'Oncidium goldenshower'},
        {'image': 'assets/Oncidium/miltonia/oncidium_miltonia.jpg', 'name': 'Oncidium miltonia'},
      ],
      [
        {'image': 'assets/Phalaenopsis/amabilis/phalaenopsis_amabilis.jpg', 'name': 'Phalaenopsis amabilis'},
        {'image': 'assets/Phalaenopsis/belina/phalaenopsis_bellina.jpg', 'name': 'Phalaenopsis belina'},
        {'image': 'assets/Phalaenopsis/gigantea/phalaenopsis_gigantea.jpg', 'name': 'Phalaenopsis gigantea'},
      ],
      [
        {'image': 'assets/Vanda/sanderiana/vanda_sanderiana.jpg', 'name': 'Vanda sanderiana'},
        {'image': 'assets/Vanda/teres/vanda_teres.jpg', 'name': 'Vanda teres'},
        {'image': 'assets/Vanda/tricolor/vanda_tricolor.jpg', 'name': 'Vanda tricolor'},
      ],
    ];
    return speciesData[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Klasifikasi'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultContent(),
    );
  }

  Widget _buildResultContent() {
    final percentage = _confidence * 100;
    final fileImage = ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        File(widget.imagePath),
        width: 224,
        height: 224,
        fit: BoxFit.cover,
      ),
    );

    // Cek apakah kelas non-anggrek (misal label 'non-anggrek' atau index 5 ke atas)
    final isNonAnggrek = _classification.toLowerCase() == 'non-anggrek' || _genusIndex >= 6;

    // Jika confidence < 70% atau kelas non-anggrek, tampilkan pesan "tidak terdeteksi"
    if (isNonAnggrek) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fileImage,
            const SizedBox(height: 16),
            const Text(
              'Tidak terdeteksi bunga anggrek pada gambar yang dipilih. Silakan pilih/ambil gambar ulang.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Jika bukan non-anggrek dan confidence >= 70%, tampilkan detail genus
    final speciesList = _getSpeciesData(_genusIndex);
    final description = genusDescriptions[_genusIndex].trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: fileImage),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Klasifikasi: $_classification',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Probabilitas: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18, color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
            ),
            itemCount: speciesList.length,
            itemBuilder: (ctx, idx) => Column(
              children: [
                Expanded(
                  child: Image.asset(
                    speciesList[idx]['image']!,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  speciesList[idx]['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
