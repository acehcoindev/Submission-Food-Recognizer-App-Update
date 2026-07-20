import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class Restaurant {
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String time;
  final String halalCertNumber;
  final Offset mapOffset; // Position on the visual mock map

  Restaurant({
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.time,
    required this.halalCertNumber,
    required this.mapOffset,
  });
}

class RestaurantFinder extends StatefulWidget {
  final String foodName;
  final bool isFood;

  const RestaurantFinder({
    super.key,
    required this.foodName,
    required this.isFood,
  });

  @override
  _RestaurantFinderState createState() => _RestaurantFinderState();
}

class _RestaurantFinderState extends State<RestaurantFinder> with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _routeController;
  
  int _selectedIdx = 0;
  bool _isNavigating = false;
  List<Restaurant> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantFinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foodName != widget.foodName) {
      _loadRestaurants();
      setState(() {
        _selectedIdx = 0;
        _isNavigating = false;
        _routeController.reset();
      });
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  void _loadRestaurants() {
    if (!widget.isFood) {
      _restaurants = [];
      return;
    }

    final normalized = widget.foodName.toLowerCase();
    
    // Handpicked famous outlets across categories for high realism
    if (normalized.contains('matang')) {
      _restaurants = [
        Restaurant(
          name: 'Sate Matang Cek Nawi Rawamangun',
          address: 'Jl. Pemuda No. 12, Rawamangun, Jakarta Timur',
          rating: 4.8,
          distance: '1.2 km',
          time: '5 mnt',
          halalCertNumber: 'ID3111000102931',
          mapOffset: const Offset(80, 50),
        ),
        Restaurant(
          name: 'Sate Matang Khas Aceh Cek Dun',
          address: 'Jl. Tebet Raya No. 45, Tebet, Jakarta Selatan',
          rating: 4.7,
          distance: '2.8 km',
          time: '12 mnt',
          halalCertNumber: 'ID3111000293812',
          mapOffset: const Offset(220, 120),
        ),
        Restaurant(
          name: 'Rumah Makan Khas Aceh Keulayu',
          address: 'Jl. Margonda Raya No. 110, Beji, Depok',
          rating: 4.6,
          distance: '5.1 km',
          time: '18 mnt',
          halalCertNumber: 'ID3211000291038',
          mapOffset: const Offset(150, 200),
        ),
      ];
    } else if (normalized.contains('rendang')) {
      _restaurants = [
        Restaurant(
          name: 'Restoran Sederhana SA',
          address: 'Kawasan Niaga Sudirman Lot 18, Jakarta Selatan',
          rating: 4.9,
          distance: '0.6 km',
          time: '3 mnt',
          halalCertNumber: 'ID0021000018231',
          mapOffset: const Offset(60, 80),
        ),
        Restaurant(
          name: 'Rumah Makan Padang Garuda',
          address: 'Jl. Sultan Iskandar Muda No. 79, Pondok Indah, Jakarta',
          rating: 4.8,
          distance: '2.1 km',
          time: '8 mnt',
          halalCertNumber: 'ID0011000021948',
          mapOffset: const Offset(240, 60),
        ),
        Restaurant(
          name: 'RM Pagi Sore Cipete',
          address: 'Jl. Cipete Raya No. 2, Cilandak, Jakarta Selatan',
          rating: 4.8,
          distance: '4.3 km',
          time: '14 mnt',
          halalCertNumber: 'ID0011000010293',
          mapOffset: const Offset(180, 180),
        ),
      ];
    } else if (normalized.contains('aceh')) {
      _restaurants = [
        Restaurant(
          name: 'Mie Aceh Seulawah',
          address: 'Jl. Bendungan Hilir Raya No. 8, Tanah Abang, Jakarta Pusat',
          rating: 4.8,
          distance: '1.5 km',
          time: '6 mnt',
          halalCertNumber: 'ID3111000203912',
          mapOffset: const Offset(100, 40),
        ),
        Restaurant(
          name: 'Mie Aceh Jaly-Jaly',
          address: 'Jl. Mampang Prapatan Raya No. 28, Jakarta Selatan',
          rating: 4.7,
          distance: '3.1 km',
          time: '11 mnt',
          halalCertNumber: 'ID3111000192837',
          mapOffset: const Offset(250, 130),
        ),
        Restaurant(
          name: 'Warung Mie Aceh Cek Kar',
          address: 'Jl. Salemba Raya No. 51, Senen, Jakarta Pusat',
          rating: 4.5,
          distance: '4.8 km',
          time: '16 mnt',
          halalCertNumber: 'ID3111000492812',
          mapOffset: const Offset(90, 190),
        ),
      ];
    } else if (normalized.contains('bakso')) {
      _restaurants = [
        Restaurant(
          name: 'Bakso Solo Samrat Kuningan',
          address: 'Jl. Prof. Dr. Satrio No. 28, Kuningan, Jakarta Selatan',
          rating: 4.7,
          distance: '1.0 km',
          time: '4 mnt',
          halalCertNumber: 'ID3121000293811',
          mapOffset: const Offset(120, 60),
        ),
        Restaurant(
          name: 'Bakso Titoti Wonogiri',
          address: 'Jl. Raya Kebon Jeruk No. 15, Jakarta Barat',
          rating: 4.6,
          distance: '3.5 km',
          time: '14 mnt',
          halalCertNumber: 'ID3121000129381',
          mapOffset: const Offset(210, 170),
        ),
      ];
    } else if (normalized.contains('soto')) {
      _restaurants = [
        Restaurant(
          name: 'Soto Kudus Blok M',
          address: 'Jl. KH Ahmad Dahlan No. 34, Kebayoran Baru, Jakarta Selatan',
          rating: 4.8,
          distance: '1.8 km',
          time: '7 mnt',
          halalCertNumber: 'ID3111000192831',
          mapOffset: const Offset(130, 90),
        ),
        Restaurant(
          name: 'Soto Ayam Lamongan Cak Har',
          address: 'Kawasan Kuliner Pujasera, Senayan, Jakarta',
          rating: 4.7,
          distance: '2.5 km',
          time: '9 mnt',
          halalCertNumber: 'ID3511000129382',
          mapOffset: const Offset(260, 80),
        ),
      ];
    } else if (normalized.contains('gado')) {
      _restaurants = [
        Restaurant(
          name: 'Gado-Gado Boplo Menteng',
          address: 'Jl. Gereja Theresa No. 41, Menteng, Jakarta Pusat',
          rating: 4.6,
          distance: '1.3 km',
          time: '5 mnt',
          halalCertNumber: 'ID3111000219381',
          mapOffset: const Offset(70, 110),
        ),
        Restaurant(
          name: 'Gado-Gado Direksi Glodok',
          address: 'Pintu Besar Selatan 1 No. 10, Pinangsia, Jakarta Barat',
          rating: 4.8,
          distance: '4.2 km',
          time: '15 mnt',
          halalCertNumber: 'ID3111000129382',
          mapOffset: const Offset(180, 210),
        ),
      ];
    } else if (normalized.contains('martabak')) {
      _restaurants = [
        Restaurant(
          name: 'Martabak Pecenongan 650',
          address: 'Jl. Pecenongan Raya No. 65B, Gambir, Jakarta Pusat',
          rating: 4.7,
          distance: '2.1 km',
          time: '9 mnt',
          halalCertNumber: 'ID3111000129831',
          mapOffset: const Offset(110, 50),
        ),
        Restaurant(
          name: 'Martabak San Francisco Cilandak',
          address: 'Jl. Fatmawati No. 15, Cilandak, Jakarta Selatan',
          rating: 4.8,
          distance: '1.4 km',
          time: '6 mnt',
          halalCertNumber: 'ID3111000239121',
          mapOffset: const Offset(230, 140),
        ),
      ];
    } else {
      // Fallback umum
      _restaurants = [
        Restaurant(
          name: 'Warung Selera Nusantara',
          address: 'Jl. Jenderal Sudirman Kav. 21, Menteng, Jakarta Pusat',
          rating: 4.7,
          distance: '1.1 km',
          time: '4 mnt',
          halalCertNumber: 'ID3111000123456',
          mapOffset: const Offset(90, 70),
        ),
        Restaurant(
          name: 'Resto Rasa Indonesia Sehat',
          address: 'Kawasan Senayan City, Gelora, Jakarta Pusat',
          rating: 4.8,
          distance: '2.4 km',
          time: '8 mnt',
          halalCertNumber: 'ID3111000789012',
          mapOffset: const Offset(210, 110),
        ),
      ];
    }
  }

  void _simulateRoute() {
    if (_restaurants.isEmpty) return;
    
    setState(() {
      _isNavigating = true;
    });
    
    _routeController.reset();
    _routeController.forward().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rute simulasi menuju ${_restaurants[_selectedIdx].name} berhasil digambar!'),
          backgroundColor: const Color(0xFF2563EB),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFood || _restaurants.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(Icons.storefront_outlined, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text(
              '2. Cek Tempat yang Menjual Makanan Ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 6),
            Text(
              'Peta outlet terdekat dan cek tempat penjualan hanya tersedia untuk produk berkategori makanan dan minuman konsumsi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
            ),
          ],
        ),
      );
    }

    final selectedRestaurant = _restaurants[_selectedIdx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Judul
          const Text(
            '2. Cek Tempat yang Menjual Makanan Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rekomendasi outlet terdekat dengan sertifikasi halal aktif secara real-time.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Stylized Vector Mock Map Container
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Stack(
              children: [
                // Custom Map Painting
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_radarController, _routeController]),
                      builder: (context, child) {
                        return CustomPaint(
                          painter: MapPainter(
                            userPosition: const Offset(150, 95), // Center of 300x190 is roughly 150,95
                            restaurantPositions: _restaurants.map((r) => r.mapOffset).toList(),
                            selectedIndex: _selectedIdx,
                            routeAnimationValue: _routeController.value,
                            radarRadius: _radarController.value * 50.0,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Live Compass Widget / Marker overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.explore_outlined, color: Color(0xFF2563EB), size: 18),
                  ),
                ),

                // Accuracy Radius Tag
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Akurasi GPS ±5m',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Plotting Visual Interactive Pins overlay so they are tappable
                ...List.generate(_restaurants.length, (index) {
                  final r = _restaurants[index];
                  final isSelected = index == _selectedIdx;
                  return Positioned(
                    left: r.mapOffset.dx - 12,
                    top: r.mapOffset.dy - 24,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIdx = index;
                          _isNavigating = false;
                        });
                        _routeController.reset();
                      },
                      child: Tooltip(
                        message: r.name,
                        child: AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.red : Colors.orange[800],
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Active Selected Restaurant Information Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            selectedRestaurant.rating.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Color(0xFF10B981), size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Sertifikasi Halal MUI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  selectedRestaurant.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedRestaurant.address,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car_filled, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${selectedRestaurant.distance} (±${selectedRestaurant.time})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                        ),
                      ],
                    ),
                    Text(
                      'No. Reg: ${selectedRestaurant.halalCertNumber}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Navigation Actions Buttons Grid
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.navigation, size: 14),
                        label: const Text(
                          'Simulasikan Rute',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        onPressed: _simulateRoute,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book, size: 14),
                        label: const Text(
                          'Hubungi / Menu',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () {
                          _showRestaurantMenu(context, selectedRestaurant);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Step-by-Step Directions if user has drawn route
          if (_isNavigating) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.turn_slight_right, color: Color(0xFF2563EB), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Panduan Rute Jalan Tercepat:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStep('1. Mulai dari lokasi Anda saat ini, berkendaralah ke arah Utara sejauh 150m.'),
                  _buildStep('2. Belok kanan setelah persimpangan, ikuti jalan utama sejauh 400m.'),
                  _buildStep('3. Belok kiri menuju area parkir ${selectedRestaurant.name}.'),
                  _buildStep('4. Tujuan berada di sebelah kanan Anda. Parkir dan pintu masuk ramah disabilitas tersedia.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 4. Quick Selection Tabs of other restaurants
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _restaurants.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final r = _restaurants[index];
                final isSelected = index == _selectedIdx;
                return ChoiceChip(
                  label: Text(
                    r.name.split(' ').take(3).join(' '), // Short name
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E2937),
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedIdx = index;
                        _isNavigating = false;
                      });
                      _routeController.reset();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.4),
      ),
    );
  }

  void _showRestaurantMenu(BuildContext context, Restaurant r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Menu Andalan Utama (Bebas Bahan Syubhat):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 8),
              _buildMenuItem('Porsi Autentik Spesial', 'Rp 45.000'),
              _buildMenuItem('Porsi Regular Tradisional', 'Rp 32.000'),
              _buildMenuItem('Es Kelapa Muda Murni', 'Rp 12.000'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2937),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hubungi Outlet (Pemesanan)', style: TextStyle(fontWeight: FontWeight.w800)),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Panggilan simulasi telepon berhasil dihubungkan...')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
          Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final Offset userPosition;
  final List<Offset> restaurantPositions;
  final int selectedIndex;
  final double routeAnimationValue;
  final double radarRadius;

  MapPainter({
    required this.userPosition,
    required this.restaurantPositions,
    required this.selectedIndex,
    required this.routeAnimationValue,
    required this.radarRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid Background lines
    final Paint gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.04)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // 2. Simulated Roads mapping
    final Paint roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.5)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path roadPath1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width, size.height * 0.6);

    final Path roadPath2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.5, size.width * 0.3, size.height);

    canvas.drawPath(roadPath1, roadPaint);
    canvas.drawPath(roadPath2, roadPaint);

    // 3. Radar Circle Expansion Wave for GPS simulation
    final Paint radarPaint = Paint()
      ..color = Colors.blue.withOpacity((1.0 - (radarRadius / 50.0)).clamp(0.0, 1.0) * 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userPosition, radarRadius, radarPaint);

    // 4. Center user pulse point
    final Paint userPaint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(userPosition, 6.0, userPaint);
    final Paint userBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(userPosition, 6.0, userBorderPaint);

    // 5. Draw animated dashed route line from User to Selected Restaurant
    if (selectedIndex >= 0 && selectedIndex < restaurantPositions.length) {
      final dest = restaurantPositions[selectedIndex];
      final Paint routePaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final Path routePath = Path()
        ..moveTo(userPosition.dx, userPosition.dy)
        ..lineTo(dest.dx, dest.dy);

      _drawDashedPath(canvas, routePath, routePaint, 6.0, 4.0, routeAnimationValue);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace, double progress) {
    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      final double totalLength = pathMetric.length * progress;
      while (distance < totalLength) {
        final double length = (distance + dashWidth < totalLength) ? dashWidth : totalLength - distance;
        final Path extractPath = pathMetric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
