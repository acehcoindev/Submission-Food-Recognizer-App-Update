import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class WebcamScreen extends StatefulWidget {
  const WebcamScreen({super.key});

  @override
  _WebcamScreenState createState() => _WebcamScreenState();
}

class _WebcamScreenState extends State<WebcamScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _simulateCapture({required bool isFood}) async {
    setState(() {
      _isLoading = true;
    });
    // Create an empty temp file to simulate captured picture path
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final directory = await getTemporaryDirectory();
      final suffix = isFood ? 'simulated_scan' : 'simulated_non_food';
      final path = '${directory.path}/${suffix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes([0, 1, 2, 3]); // Dummy byte stream
      if (mounted) {
        Navigator.pop(context, path);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Pemindai Cerdas TFLite',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed / Emulator Fallback
          if (_isInitialized && _controller != null)
            Center(child: CameraPreview(_controller!))
          else if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.videocam_off, color: Colors.amber, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sensor Kamera Tidak Ditemukan',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Emulator terdeteksi. Sistem mengaktifkan Mode Simulasi Lensa untuk verifikasi fungsionalitas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Simulasi Pindai Sate Matang (Makanan)', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () => _simulateCapture(isFood: true),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Simulasi Pindai Buku (Non-Makanan)', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () => _simulateCapture(isFood: false),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. Crosshair Scanner Frame (Only if camera is working)
          if (_isInitialized)
            IgnorePointer(
              child: Stack(
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.5),
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(color: Colors.black),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF3B82F6), width: 3),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 3. Floating Capture Button
          if (_isInitialized)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: _isLoading ? null : _takePicture,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : null,
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
