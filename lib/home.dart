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
  }

  @override
  void dispose() {
    AppState.instance.parkingList.removeListener(_onParkingChanged);
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

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141B2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _NotifItem(
              icon: Icons.access_time,
              color: const Color(0xFFFBBF24),
              title: 'Masa hampir tamat',
              subtitle: 'Tempahan Kg. Baru Sentral P tamat dalam 15 minit.',
              time: '5 min lepas',
            ),
            const SizedBox(height: 10),
            _NotifItem(
              icon: Icons.check_circle,
              color: const Color(0xFF4ADE80),
              title: 'Tempahan berjaya',
              subtitle: 'Slot B1-08 di Kg. Baru Sentral P telah disahkan.',
              time: '1 jam lepas',
            ),
            const SizedBox(height: 10),
            _NotifItem(
              icon: Icons.electric_car,
              color: const Color(0xFFA78BFA),
              title: 'Slot EV tersedia',
              subtitle: 'Chow Kit Plaza EV kini ada 4 slot EV yang kosong.',
              time: '3 jam lepas',
            ),
            const SizedBox(height: 10),
            _NotifItem(
              icon: Icons.local_offer,
              color: const Color(0xFF60A5FA),
              title: 'Promosi Jom Park',
              subtitle: 'Parking percuma 1 jam di PWTC setiap hujung minggu!',
              time: 'Semalam',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Map<String, dynamic> parking) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                GestureDetector(
                  onTap: _showNotifications,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141B2D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
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
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 220),
                      painter: _MapPainter(),
                    ),
                    // Current location dot
                    Positioned(
                      left: 100,
                      top: 108,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 58,
                      top: 68,
                      child: GestureDetector(
                        onTap: () => _navigateTo(AppState.instance.parkingList.value[0]),
                        child: const _MapMarker(label: 'RM2/jam', color: Color(0xFF1D4ED8)),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: GestureDetector(
                        onTap: () => _navigateTo(AppState.instance.parkingList.value[1]),
                        child: const _MapMarker(label: 'RM1.5/jam', color: Color(0xFF166534)),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 10,
                      child: GestureDetector(
                        onTap: () => _navigateTo(AppState.instance.parkingList.value[2]),
                        child: const _MapMarker(label: 'RM3/jam', color: Color(0xFF92400E)),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      top: 116,
                      child: GestureDetector(
                        onTap: () => _navigateTo(AppState.instance.parkingList.value[3]),
                        child: const _MapMarker(label: 'RM2.5/jam', color: Color(0xFF6D28D9)),
                      ),
                    ),
                    Positioned(
                      right: 22,
                      top: 130,
                      child: GestureDetector(
                        onTap: () => _navigateTo(AppState.instance.parkingList.value[4]),
                        child: const _MapMarker(label: 'RM1/jam', color: Color(0xFF065F46)),
                      ),
                    ),
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
                .map(
                  (p) => GestureDetector(
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
                      slotLabel: (p['availableSlots'] as int) > 0
                          ? '${p['availableSlots']} slot'
                          : 'Penuh',
                      isAvailable: (p['availableSlots'] as int) > 0,
                    ),
                  ),
                ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Map widgets ──────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  void _label(Canvas canvas, String text, double x, double y,
      {double size = 8.5, bool bold = false, Color color = const Color(0xFF888070)}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
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

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFE5DDD0));

    // Sungai Klang – river strip left
    canvas.drawRect(Rect.fromLTWH(0, 0, 26, h), Paint()..color = const Color(0xFF72C2E0));

    // Padang / park – top right
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.68, 0, w * 0.32, h * 0.44), const Radius.circular(4)),
      Paint()..color = const Color(0xFF8FCC90),
    );

    // Roads
    final main = Paint()..color = const Color(0xFFFAF8F4);
    final side = Paint()..color = const Color(0xFFEEEBE4);

    // Horizontal
    canvas.drawRect(Rect.fromLTWH(26, h * 0.52, w - 26, 17), main);  // Jln Raja Muda
    canvas.drawRect(Rect.fromLTWH(26, h * 0.27, w - 26, 11), side);  // Jln Raja Bot
    canvas.drawRect(Rect.fromLTWH(26, h * 0.77, w - 26, 10), side);  // Lower road

    // Vertical
    canvas.drawRect(Rect.fromLTWH(w * 0.30, 0, 15, h), main);   // Jln Raja Abdullah
    canvas.drawRect(Rect.fromLTWH(w * 0.65, 0, 10, h), side);   // Jln TAR

    // Building blocks
    final blk = Paint()..color = const Color(0xFFC0B8AA);
    for (final r in [
      Rect.fromLTWH(30, h * 0.34, 68, 46),
      Rect.fromLTWH(w * 0.30 + 20, h * 0.34, 72, 46),
      Rect.fromLTWH(30, h * 0.61, 66, 40),
      Rect.fromLTWH(w * 0.30 + 20, h * 0.61, 68, 40),
      Rect.fromLTWH(w * 0.65 + 14, h * 0.61, 52, 40),
      Rect.fromLTWH(w * 0.65 + 14, h * 0.10, 52, 38),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), blk);
    }

    // Labels
    _label(canvas, 'Jln Raja Muda Abdul Aziz', 30, h * 0.53);
    _label(canvas, 'Jln Raja Bot', 30, h * 0.28);
    _label(canvas, 'Jln Raja Abdullah', w * 0.30 + 17, 4, size: 7.5);
    _label(canvas, 'Padang', w * 0.74, h * 0.14, size: 8.0, color: const Color(0xFF4A7A4A));
    _label(canvas, 'KAMPUNG BARU', w * 0.33, h * 0.17,
        size: 11, bold: true, color: const Color(0xFF6A6055));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _MapMarker extends StatelessWidget {
  final String label;
  final Color color;

  const _MapMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_parking, color: Colors.white, size: 11),
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
          painter: _TailPainter(color: color),
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
                  color: isAvailable
                      ? const Color(0xFF14532D)
                      : const Color(0xFF450A0A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable ? Icons.access_time : Icons.close,
                      color: isAvailable
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      slotLabel,
                      style: TextStyle(
                        color: isAvailable
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

// ── Notification item ─────────────────────────────────────────────────────────

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
