import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scanned_food.dart';
import '../services/classifier_service.dart';
import '../services/gemini_service.dart';
import '../services/mealdb_service.dart';
import '../widgets/upload_card.dart';
import '../widgets/history_list.dart';
import 'result_screen.dart';
import 'webcam_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final ClassifierService _classifierService = ClassifierService();
  final GeminiService _geminiService = GeminiService();
  final MealDBService _mealDBService = MealDBService();

  List<ScannedFood> _history = [];
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _classifierService.init();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyData = prefs.getStringList('scan_history');

    if (historyData != null && historyData.isNotEmpty) {
      setState(() {
        _history = historyData.map((item) => ScannedFood.fromJson(item)).toList();
      });
    } else {
      // Pre-populate with beautiful demo samples if empty
      // Ensuring origin is present for each sample as mandated by Submission 6
      final demoSamples = [
        ScannedFood(
          id: 'demo-1',
          name: 'Sate Matang',
          confidence: 0.962,
          imagePath: '',
          origin: 'Bireuen, Aceh, Indonesia',
          halalStatus: 'Halal',
          halalReason: 'Menggunakan daging sapi segar yang disembelih sesuai syariat Islam, dimasak dengan kaldu kaya rempah tradisional tanpa penambahan zat aditif kritis.',
          calories: 385.0,
          carbs: 14.2,
          protein: 32.5,
          fat: 21.0,
          fiber: 1.8,
          recipeIngredients: [
            '500 gram Daging Sapi segar (potong dadu)',
            'Bumbu halus serai, daun jeruk, bawang merah-putih, ketumbar',
            'Santan kelapa encer untuk kuah soto berempah',
            'Kacang tanah goreng giling halus untuk bumbu sate'
          ],
          recipeInstructions: '1. Lumuri daging dengan bumbu rempah halus, diamkan 30 menit.\n2. Tusuk dan bakar sate di atas arang hingga harum.\n3. Rebus kuah kaldu soto bersantan encer.\n4. Sajikan sate bersama nasi, siraman kuah soto hangat, dan saus kacang gurih manis.',
          dateTime: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ScannedFood(
          id: 'demo-2',
          name: 'Rendang',
          confidence: 0.948,
          imagePath: '',
          origin: 'Minangkabau, Sumatera Barat, Indonesia',
          halalStatus: 'Halal',
          halalReason: 'Menggunakan daging sapi bersertifikasi halal, santan murni perasan kelapa tua, dan campuran rempah mentah giling segar.',
          calories: 468.0,
          carbs: 9.2,
          protein: 34.0,
          fat: 31.5,
          fiber: 2.4,
          recipeIngredients: [
            '1 kg Daging Sapi (potong dadu besar)',
            '1 Liter Santan Kental kelapa murni',
            'Bumbu rempah halus padang murni giling',
            'Asam kandis, daun kunyit, daun jeruk, serai'
          ],
          recipeInstructions: '1. Rebus santan bersama bumbu halus giling hingga mengeluarkan minyak kemerahan.\n2. Masukkan daging, aduk perlahan di api sedang.\n3. Setelah mengental cokelat, kecilkan api kompor.\n4. Aduk hingga santan mengering hitam beraroma wangi karamel.',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      setState(() {
        _history = demoSamples;
      });
      await _saveHistory();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyData = _history.map((item) => item.toJson()).toList();
    await prefs.setStringList('scan_history', historyData);
  }

  Future<void> _deleteHistoryItem(String id) async {
    setState(() {
      _history.removeWhere((item) => item.id == id);
    });
    await _saveHistory();
  }

  /// Memproses alur klasifikasi, analisis gizi Gemini, dan resep MealDB
  Future<void> _processImageAnalysis(String imagePath) async {
    if (imagePath.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Melakukan Inferensi LiteRT...';
    });

    try {
      // 1. Jalankan klasifikasi on-device dengan LiteRT model.tflite di background isolate
      final classification = await _classifierService.classifyImage(imagePath);
      final String foodName = classification['name'];
      final double confidence = classification['confidence'];

      setState(() {
        _loadingMessage = 'Mengekstrak Gizi via Gemini AI...';
      });

      // 2. Ambil kandungan gizi makro dan status halal dari Google Gemini
      final nutrition = await _geminiService.analyzeFood(foodName);

      setState(() {
        _loadingMessage = 'Mengunduh Resep Autentik...';
      });

      // 3. Ambil resep dari TheMealDB API dengan fallback tradisional
      final recipe = await _mealDBService.fetchRecipe(foodName);

      // 4. Buat objek data hasil pemindaian
      final newFood = ScannedFood(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: foodName,
        confidence: confidence,
        imagePath: imagePath,
        origin: nutrition['origin'] ?? 'Indonesia',
        halalStatus: nutrition['halalStatus'] ?? 'Halal',
        halalReason: nutrition['halalReason'] ?? 'Bahan alami bebas titik kritis.',
        calories: (nutrition['calories'] as num).toDouble(),
        carbs: (nutrition['carbs'] as num).toDouble(),
        protein: (nutrition['protein'] as num).toDouble(),
        fat: (nutrition['fat'] as num).toDouble(),
        fiber: (nutrition['fiber'] as num).toDouble(),
        recipeIngredients: List<String>.from(recipe['ingredients'] ?? []),
        recipeInstructions: recipe['instructions'] ?? '',
        dateTime: DateTime.now(),
      );

      // 5. Tambahkan ke riwayat lokal dan navigasikan ke layar hasil
      setState(() {
        _history.insert(0, newFood);
      });
      await _saveHistory();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(foodItem: newFood),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan analisis: $e')),
        );
      }
    }
  }

  Future<void> _triggerCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        await _processImageAnalysis(photo.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera tidak dapat diakses: $e')),
      );
    }
  }

  Future<void> _triggerGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        await _processImageAnalysis(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Galeri tidak dapat diakses: $e')),
      );
    }
  }

  Future<void> _triggerLiveScanner() async {
    final String? resultPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const WebcamScreen()),
    );

    if (resultPath != null && resultPath.isNotEmpty) {
      await _processImageAnalysis(resultPath);
    }
  }

  void _showApiKeyDialog() async {
    final TextEditingController controller = TextEditingController();
    final currentKey = await _geminiService.getApiKey();
    controller.text = currentKey ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: Colors.blue),
            SizedBox(width: 10),
            Text('Google Gemini API Key', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan API Key Google AI Studio Anda untuk mengaktifkan analisis gizi gizi makro real-time menggunakan model cerdas.',
              style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'API Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            onPressed: () async {
              await _geminiService.deleteApiKey();
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key berhasil dihapus. Aplikasi kembali ke mode simulasi.')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800)),
            onPressed: () async {
              await _geminiService.saveApiKey(controller.text.trim());
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key disimpan dengan sukses!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Food Recognizer AI',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937), fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF4B5563)),
            tooltip: 'Konfigurasi Gemini API Key',
            onPressed: _showApiKeyDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Greeting Card
                const Text(
                  'Halo, Muhammad Aiyub 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Deteksi kandungan gizi & kehalalan piring makanmu hari ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Bento Grid Upload Controls
                UploadCard(
                  onCameraTap: _triggerCamera,
                  onGalleryTap: _triggerGallery,
                  onScannerTap: _triggerLiveScanner,
                ),
                const SizedBox(height: 28),

                // 3. Scan History List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Pemindaian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (_history.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            _history.clear();
                          });
                          await _saveHistory();
                        },
                        child: const Text(
                          'Bersihkan Semua',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                HistoryList(
                  items: _history,
                  onTap: (item) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(foodItem: item),
                      ),
                    );
                  },
                  onDelete: _deleteHistoryItem,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 4. Staggered Full Screen Loader Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _loadingMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mengolah citra model & data gizi...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
