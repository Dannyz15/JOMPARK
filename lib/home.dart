import 'package:flutter/material.dart';
import 'package:jompark/app_state.dart';
import 'package:jompark/parking_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    AppState.instance.parkingList.addListener(_onParkingChanged);
    AppState.instance.activeTicket.addListener(_onParkingChanged);
  }

  @override
  void dispose() {
    AppState.instance.parkingList.removeListener(_onParkingChanged);
    AppState.instance.activeTicket.removeListener(_onParkingChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onParkingChanged() => setState(() {});

  List<Map<String, dynamic>> get _filteredParking {
    var list = List<Map<String, dynamic>>.from(AppState.instance.parkingList.value);
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (p) => (p['name'] as String).toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    switch (_selectedFilter) {
      case 1:
        list.sort(
          (a, b) =>
              (a['distance'] as double).compareTo(b['distance'] as double),
        );
      case 2:
        list.sort(
          (a, b) => (a['price'] as double).compareTo(b['price'] as double),
        );
      case 3:
        list = list.where((p) => p['is24Hours'] as bool).toList();
    }
    return list;
  }

  void _navigateTo(Map<String, dynamic> parking) {
    final activeTicket = AppState.instance.activeTicket.value;
    if (activeTicket != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF141B2D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFBBF24), size: 22),
              SizedBox(width: 8),
              Text('Tiket Aktif', style: TextStyle(color: Colors.white, fontSize: 17)),
            ],
          ),
          content: Text(
            'Anda masih mempunyai tiket aktif di ${activeTicket.name}.\nSila keluar dahulu sebelum membuat tempahan baru.',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingDetailPage(
          name: parking['name'] as String,
          level: parking['level'] as String,
          distance: parking['distance'] as double,
          pricePerHour: parking['price'] as double,
          totalSlots: parking['totalSlots'] as int,
          availableSlots: parking['availableSlots'] as int,
          icon: parking['icon'] as IconData,
          iconColor: parking['iconColor'] as Color,
          iconBg: parking['iconBg'] as Color,
          is24Hours: parking['is24Hours'] as bool,
          type: parking['type'] as String,
        ),
      ),
    );
  }

  String _priceLabel(Map<String, dynamic> p) {
    final price = p['price'] as double;
    return 'RM${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}/jam';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredParking;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi semasa',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Kampung Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141B2D),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari lokasi parking...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF6B7280),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(4, (i) {
                  const labels = ['Semua', 'Berdekatan', 'Murah', '24 Jam'];
                  final selected = _selectedFilter == i;
                  return Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF141B2D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF0B0F1E)
                                : const Color(0xFF9CA3AF),
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Map view
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2D3A52), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 240),
                      painter: _MapPainter(),
                    ),
                    // Compass
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A3E).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2D3A52)),
                        ),
                        child: const Icon(Icons.navigation, color: Color(0xFF60A5FA), size: 14),
                      ),
                    ),
                    // Current location dot
                    Positioned(
                      left: 108,
                      top: 118,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Parking markers
                    Builder(builder: (context) {
                      final active = AppState.instance.activeTicket.value;
                      final pl = AppState.instance.parkingList.value;
                      return Stack(children: [
                        Positioned(
                          left: 58,
                          top: 72,
                          child: GestureDetector(
                            onTap: () => _navigateTo(pl[0]),
                            child: _MapMarker(
                              label: 'RM2/jam',
                              color: const Color(0xFF1D4ED8),
                              isMyParking: active?.name == pl[0]['name'],
                              isFull: (pl[0]['availableSlots'] as int) == 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 12,
                          child: GestureDetector(
                            onTap: () => _navigateTo(pl[1]),
                            child: _MapMarker(
                              label: 'RM1.5/jam',
                              color: const Color(0xFF166534),
                              isMyParking: active?.name == pl[1]['name'],
                              isFull: (pl[1]['availableSlots'] as int) == 0,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          top: 8,
                          child: GestureDetector(
                            onTap: () => _navigateTo(pl[2]),
                            child: _MapMarker(
                              label: 'RM3/jam',
                              color: const Color(0xFF92400E),
                              isMyParking: active?.name == pl[2]['name'],
                              isFull: (pl[2]['availableSlots'] as int) == 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 148,
                          top: 124,
                          child: GestureDetector(
                            onTap: () => _navigateTo(pl[3]),
                            child: _MapMarker(
                              label: 'RM2.5/jam',
                              color: const Color(0xFF5B21B6),
                              isMyParking: active?.name == pl[3]['name'],
                              isFull: (pl[3]['availableSlots'] as int) == 0,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 18,
                          top: 140,
                          child: GestureDetector(
                            onTap: () => _navigateTo(pl[4]),
                            child: _MapMarker(
                              label: 'RM1/jam',
                              color: const Color(0xFF065F46),
                              isMyParking: active?.name == pl[4]['name'],
                              isFull: (pl[4]['availableSlots'] as int) == 0,
                            ),
                          ),
                        ),
                      ]);
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Parking Berdekatan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedFilter = 0;
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: Text(
                    'Lihat semua',
                    style: TextStyle(color: Colors.blue[400], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Parking list
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.grey[600], size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Tiada parking dijumpai',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered
                .map((p) {
                  final activeTicket = AppState.instance.activeTicket.value;
                  final isMyParking = activeTicket?.name == p['name'];
                  return GestureDetector(
                    onTap: () => _navigateTo(p),
                    child: _ParkingCard(
                      icon: p['icon'] as IconData,
                      iconColor: p['iconColor'] as Color,
                      iconBg: p['iconBg'] as Color,
                      name: p['name'] as String,
                      distance: '${p['distance']} km',
                      level: p['level'] as String,
                      price: _priceLabel(p),
                      priceColor: p['priceColor'] as Color,
                      slotLabel: isMyParking
                          ? 'Aktif'
                          : (p['availableSlots'] as int) > 0
                              ? '${p['availableSlots']} slot'
                              : 'Penuh',
                      isAvailable: !isMyParking && (p['availableSlots'] as int) > 0,
                      isMyParking: isMyParking,
                    ),
                  );
                }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Map widgets ──────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  void _label(Canvas canvas, String text, double x, double y, {
    double size = 8.0,
    bool bold = false,
    Color color = const Color(0xFF4A5E78),
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: bold ? 1.2 : 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background – dark navy
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1E2A3E));

    // Sungai Klang – curved river left
    final riverPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(40, h * 0.22, 16, h * 0.52, 26, h * 0.82)
      ..cubicTo(30, h * 0.92, 26, h * 0.97, 22, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(riverPath, Paint()..color = const Color(0xFF1A4A6A));

    final riverShine = Path()
      ..moveTo(8, 0)
      ..cubicTo(26, h * 0.2, 10, h * 0.48, 18, h * 0.78)
      ..cubicTo(20, h * 0.88, 16, h * 0.94, 14, h)
      ..lineTo(8, h)
      ..cubicTo(14, h * 0.88, 22, h * 0.6, 10, h * 0.36)
      ..cubicTo(20, h * 0.16, 30, h * 0.1, 10, 0)
      ..close();
    canvas.drawPath(riverShine,
        Paint()..color = const Color(0xFF1E5A80).withValues(alpha: 0.4));

    // Padang / park – top right
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.67, 0, w * 0.33, h * 0.43), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1A3828),
    );
    final treePaint = Paint()..color = const Color(0xFF213E2E);
    for (double tx = w * 0.695; tx < w * 0.99; tx += w * 0.065) {
      for (double ty = h * 0.05; ty < h * 0.38; ty += h * 0.1) {
        canvas.drawCircle(Offset(tx, ty), w * 0.02, treePaint);
      }
    }

    // Roads
    final mainRoad = Paint()..color = const Color(0xFF2C3C56);
    final sideRoad = Paint()..color = const Color(0xFF243048);

    // Horizontal roads
    canvas.drawRect(Rect.fromLTWH(32, h * 0.50, w - 32, 20), mainRoad); // Jln Raja Muda
    canvas.drawRect(Rect.fromLTWH(32, h * 0.26, w - 32, 12), sideRoad); // Jln Raja Bot
    canvas.drawRect(Rect.fromLTWH(32, h * 0.76, w - 32, 10), sideRoad); // Lower road

    // Vertical roads
    canvas.drawRect(Rect.fromLTWH(w * 0.29, 0, 18, h), mainRoad);  // Jln Raja Abdullah
    canvas.drawRect(Rect.fromLTWH(w * 0.64, 0, 12, h), sideRoad);  // Jln TAR

    // Road centre dashes – main horizontal
    final dash = Paint()..color = const Color(0xFF3A4E6A)..strokeWidth = 1.0;
    for (double x = 36; x < w - 6; x += 14) {
      canvas.drawLine(Offset(x, h * 0.50 + 10), Offset(x + 7, h * 0.50 + 10), dash);
    }

    // Buildings
    final buildFill = Paint()..color = const Color(0xFF263242);
    final buildBorder = Paint()
      ..color = const Color(0xFF2E3D52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final r in [
      Rect.fromLTWH(36, h * 0.07, 50, h * 0.15),
      Rect.fromLTWH(92, h * 0.07, 32, h * 0.15),
      Rect.fromLTWH(36, h * 0.33, 56, h * 0.14),
      Rect.fromLTWH(98, h * 0.33, 32, h * 0.14),
      Rect.fromLTWH(36, h * 0.59, 54, h * 0.14),
      Rect.fromLTWH(36, h * 0.79, 54, h * 0.14),
      Rect.fromLTWH(w * 0.29 + 22, h * 0.05, 52, h * 0.17),
      Rect.fromLTWH(w * 0.29 + 80, h * 0.05, 28, h * 0.17),
      Rect.fromLTWH(w * 0.29 + 22, h * 0.33, 54, h * 0.14),
      Rect.fromLTWH(w * 0.29 + 82, h * 0.33, 28, h * 0.14),
      Rect.fromLTWH(w * 0.29 + 22, h * 0.59, 52, h * 0.14),
      Rect.fromLTWH(w * 0.29 + 22, h * 0.79, 52, h * 0.14),
      Rect.fromLTWH(w * 0.64 + 16, h * 0.50, 42, h * 0.22),
      Rect.fromLTWH(w * 0.64 + 16, h * 0.79, 42, h * 0.14),
    ]) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(3));
      canvas.drawRRect(rr, buildFill);
      canvas.drawRRect(rr, buildBorder);
    }

    // Labels
    _label(canvas, 'Jln Raja Muda Abdul Aziz', 38, h * 0.515, size: 7.0);
    _label(canvas, 'Jln Raja Bot', 38, h * 0.268, size: 6.5);
    _label(canvas, 'Jln Raja Abdullah', w * 0.295, 4, size: 6.0);
    _label(canvas, 'Padang', w * 0.76, h * 0.17, size: 8.0, color: const Color(0xFF3A6E48));
    _label(canvas, 'KAMPUNG BARU', w * 0.34, h * 0.15,
        size: 10, bold: true, color: const Color(0xFF4A5E78));
    _label(canvas, 'Sg. Klang', 1, h * 0.46, size: 6.0, color: const Color(0xFF2A6A94));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _MapMarker extends StatelessWidget {
  final String label;
  final Color color;
  final bool isMyParking;
  final bool isFull;

  const _MapMarker({
    required this.label,
    required this.color,
    this.isMyParking = false,
    this.isFull = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMyParking
        ? const Color(0xFF1D4ED8)
        : isFull
            ? const Color(0xFF7F1D1D)
            : color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: isMyParking
                ? Border.all(color: const Color(0xFF93C5FD), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMyParking ? Icons.directions_car : Icons.local_parking,
                color: Colors.white,
                size: 11,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _TailPainter(color: bg),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  const _TailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Parking card ─────────────────────────────────────────────────────────────

class _ParkingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String name;
  final String distance;
  final String level;
  final String price;
  final Color priceColor;
  final String slotLabel;
  final bool isAvailable;
  final bool isMyParking;

  const _ParkingCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.name,
    required this.distance,
    required this.level,
    required this.price,
    required this.priceColor,
    required this.slotLabel,
    required this.isAvailable,
    this.isMyParking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$distance • $level',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: priceColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMyParking
                      ? const Color(0xFF1E3A5F)
                      : isAvailable
                          ? const Color(0xFF14532D)
                          : const Color(0xFF450A0A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMyParking
                          ? Icons.directions_car
                          : isAvailable ? Icons.access_time : Icons.close,
                      color: isMyParking
                          ? const Color(0xFF60A5FA)
                          : isAvailable
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFFF87171),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      slotLabel,
                      style: TextStyle(
                        color: isMyParking
                            ? const Color(0xFF60A5FA)
                            : isAvailable
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

