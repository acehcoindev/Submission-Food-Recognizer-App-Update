import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/scanned_food.dart';
import '../widgets/macro_card.dart';
import '../widgets/restaurant_finder.dart';

class ResultScreen extends StatefulWidget {
  final ScannedFood foodItem;

  const ResultScreen({super.key, required this.foodItem});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('id-ID');
    _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakAnalysis() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    final String narration = 'Berikut adalah analisis gizi untuk ${widget.foodItem.name}. '
        'Asal makanan dari ${widget.foodItem.origin}. '
        'Status kehalalan adalah ${widget.foodItem.halalStatus}. '
        'Kandungan kalori sebesar ${widget.foodItem.calories.toInt()} kilo kalori, '
        'protein ${widget.foodItem.protein.toInt()} gram, '
        'karbohidrat ${widget.foodItem.carbs.toInt()} gram, '
        'dan lemak ${widget.foodItem.fat.toInt()} gram. '
        'Selamat menikmati hidangan sehat Anda.';

    await _flutterTts.speak(narration);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.foodItem;
    final fileExists = item.imagePath.isNotEmpty && File(item.imagePath).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Image
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                image: fileExists
                    ? DecorationImage(
                        image: FileImage(File(item.imagePath)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !fileExists
                  ? const Center(
                      child: Icon(Icons.fastfood, color: Colors.white54, size: 72),
                    )
                  : null,
            ),

            // 2. Info Header (Confidence & Origin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              'Akurasi ${(item.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'LiteRT On-Device',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Asal Kuliner / Tradisional',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        item.origin,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Model Active Notification Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology, color: Color(0xFF2563EB), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deteksi Model model.tflite Aktif',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E40AF)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Klasifikasi diverifikasi secara instan via MobileNetV2 lokal.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Macro-Nutrients Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kandungan Nutrisi Gizi Makro',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                    children: [
                      MacroCard(
                        label: 'Kalori',
                        value: '${item.calories.toInt()} kkal',
                        percentage: (item.calories / 2000.0).clamp(0.0, 1.0),
                        color: const Color(0xFF3B82F6),
                        icon: Icons.local_fire_department,
                      ),
                      MacroCard(
                        label: 'Protein',
                        value: '${item.protein.toInt()} g',
                        percentage: (item.protein / 50.0).clamp(0.0, 1.0),
                        color: const Color(0xFF10B981),
                        icon: Icons.fitness_center,
                      ),
                      MacroCard(
                        label: 'Karbohidrat',
                        value: '${item.carbs.toInt()} g',
                        percentage: (item.carbs / 300.0).clamp(0.0, 1.0),
                        color: const Color(0xFFF59E0B),
                        icon: Icons.rice_bowl,
                      ),
                      MacroCard(
                        label: 'Lemak',
                        value: '${item.fat.toInt()} g',
                        percentage: (item.fat / 65.0).clamp(0.0, 1.0),
                        color: const Color(0xFFEF4444),
                        icon: Icons.opacity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Halal Certification Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Audit Sertifikasi Halal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.halalStatus == 'Bukan Makanan' ? const Color(0xFFF1F5F9) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.halalStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: item.halalStatus == 'Bukan Makanan' ? const Color(0xFF64748B) : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.halalReason,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. Recipe Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resep Pembuatan Autentik',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bahan-Bahan Masakan:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 6),
                  ...item.recipeIngredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle_notifications, size: 14, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ing,
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text(
                    'Langkah-Langkah Memasak:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.recipeInstructions,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 7. Cek Tempat yang Menjual Makanan Ini
            RestaurantFinder(
              foodName: item.name,
              isFood: item.halalStatus != 'Bukan Makanan',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speakAnalysis,
        backgroundColor: const Color(0xFF3B82F6),
        child: Icon(
          _isSpeaking ? Icons.stop : Icons.volume_up,
          color: Colors.white,
        ),
      ),
    );
  }
}
