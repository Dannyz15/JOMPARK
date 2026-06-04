import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jompark/app_state.dart';

class ParkingDetailPage extends StatefulWidget {
  final String name;
  final String level;
  final double distance;
  final double pricePerHour;
  final int totalSlots;
  final int availableSlots;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool is24Hours;
  final String type;

  const ParkingDetailPage({
    super.key,
    required this.name,
    required this.level,
    required this.distance,
    required this.pricePerHour,
    required this.totalSlots,
    required this.availableSlots,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.is24Hours,
    required this.type,
  });

  @override
  State<ParkingDetailPage> createState() => _ParkingDetailPageState();
}

class _ParkingDetailPageState extends State<ParkingDetailPage> {
  int? _selectedSlot;
  int _hours = 1;
  int? _selectedVehicleIndex;
  final _plateController = TextEditingController();
  late final List<bool> _slotOccupied;

  @override
  void initState() {
    super.initState();
    final occupied = widget.totalSlots - widget.availableSlots;
    _slotOccupied = ([
      ...List.filled(occupied, true),
      ...List.filled(widget.availableSlots, false),
    ]..shuffle(Random(42)));
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  double get _total => widget.pricePerHour * _hours;

  String _slotName(int i) {
    final row = String.fromCharCode(65 + i ~/ 10);
    final num = (i % 10 + 1).toString().padLeft(2, '0');
    return '$row$num';
  }

  void _book() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila pilih slot parking terlebih dahulu'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    if (_plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila masukkan nombor plat kenderaan'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 28),
            SizedBox(width: 10),
            Text('Tempahan Berjaya!', style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Color(0xFF374151)),
            const SizedBox(height: 8),
            _BookingRow('Lokasi', widget.name),
            _BookingRow('Slot', _slotName(_selectedSlot!)),
            _BookingRow('No. Plat', _plateController.text.trim().toUpperCase()),
            _BookingRow('Tempoh', '$_hours jam'),
            const Divider(color: Color(0xFF374151)),
            _BookingRow('Jumlah Bayaran', 'RM ${_total.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await AppState.instance.saveActiveTicket(ActiveTicket(
                  name: widget.name,
                  slot: _slotName(_selectedSlot!),
                  plate: _plateController.text.trim().toUpperCase(),
                  totalHours: _hours,
                  pricePerHour: widget.pricePerHour,
                  totalAmount: _total,
                  startTime: DateTime.now(),
                ));
                AppState.instance.bookParking(widget.name);
                await AppState.instance.addBooking(HistoryEntry(
                  name: widget.name,
                  date: formatDateMy(DateTime.now()),
                  duration: '$_hours jam',
                  slot: _slotName(_selectedSlot!),
                  amount: 'RM ${_total.toStringAsFixed(2)}',
                  rawAmount: _total,
                  icon: widget.icon,
                  iconColor: widget.iconColor,
                  iconBg: widget.iconBg,
                  type: widget.type == 'ev'
                      ? 'EV Charging'
                      : widget.type == 'indoor'
                          ? 'Dalam bangunan'
                          : 'Luar bangunan',
                  plate: _plateController.text.trim().toUpperCase(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.availableSlots > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0B0F1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: widget.iconBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(widget.level, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF60A5FA), size: 13),
                            Text(' ${widget.distance} km dari anda', style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
                            if (widget.is24Hours) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(4)),
                                child: const Text('24 Jam', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 10)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _StatChip(
                  label: 'Slot Tersedia',
                  value: '${widget.availableSlots}/${widget.totalSlots}',
                  color: isAvailable ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Harga/jam',
                  value: 'RM ${widget.pricePerHour % 1 == 0 ? widget.pricePerHour.toInt() : widget.pricePerHour.toStringAsFixed(2)}',
                  color: const Color(0xFF60A5FA),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Jenis',
                  value: widget.type == 'ev' ? 'EV' : widget.type == 'indoor' ? 'Dalam' : 'Luar',
                  color: const Color(0xFFA78BFA),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Slot picker
            const Text('Pilih Slot', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _Legend(color: const Color(0xFF14532D), label: 'Tersedia'),
                const SizedBox(width: 12),
                _Legend(color: const Color(0xFF450A0A), label: 'Diduduki'),
                const SizedBox(width: 12),
                _Legend(color: const Color(0xFF1E40AF), label: 'Dipilih'),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
              ),
              itemCount: widget.totalSlots,
              itemBuilder: (_, i) {
                final occupied = _slotOccupied[i];
                final selected = _selectedSlot == i;
                final bg = selected
                    ? const Color(0xFF1E40AF)
                    : occupied
                        ? const Color(0xFF450A0A)
                        : const Color(0xFF14532D);
                return GestureDetector(
                  onTap: occupied ? null : () => setState(() => _selectedSlot = i),
                  child: Container(
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(
                        _slotName(i),
                        style: TextStyle(
                          color: occupied
                              ? const Color(0xFFF87171)
                              : selected
                                  ? Colors.white
                                  : const Color(0xFF4ADE80),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // Plate number input
            const Text('No. Plat Kenderaan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppState.instance.vehicles,
              builder: (context, vehicles, _) {
                if (vehicles.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih kenderaan berdaftar:',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < vehicles.length; i++)
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedVehicleIndex = i;
                              _plateController.text = vehicles[i]['plate'] as String;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedVehicleIndex == i
                                    ? const Color(0xFF1E3A5F)
                                    : const Color(0xFF141B2D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedVehicleIndex == i
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF374151),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_car,
                                      size: 16,
                                      color: _selectedVehicleIndex == i
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF9CA3AF)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vehicles[i]['plate'] as String,
                                          style: TextStyle(
                                              color: _selectedVehicleIndex == i
                                                  ? const Color(0xFF60A5FA)
                                                  : Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1)),
                                      Text(vehicles[i]['model'] as String,
                                          style: const TextStyle(
                                              color: Color(0xFF9CA3AF), fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Atau isi manual:',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
            TextField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white, letterSpacing: 2),
              onChanged: (val) {
                final vehicles = AppState.instance.vehicles.value;
                final idx = vehicles.indexWhere(
                    (v) => (v['plate'] as String) == val.trim().toUpperCase());
                setState(() => _selectedVehicleIndex = idx == -1 ? null : idx);
              },
              decoration: InputDecoration(
                hintText: 'cth: WKB 2024',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF141B2D),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 18),

            // Duration picker
            const Text('Tempoh Parking', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _hours > 1 ? Colors.white : const Color(0xFF374151),
                      size: 28,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_hours jam',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RM ${_total.toStringAsFixed(2)} jumlah',
                        style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _hours < 12 ? () => setState(() => _hours++) : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _hours < 12 ? Colors.white : const Color(0xFF374151),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Book button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isAvailable ? _book : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF374151),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isAvailable
                      ? 'Tempah Sekarang  —  RM ${_total.toStringAsFixed(2)}'
                      : 'Tiada Slot Tersedia',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final String label;
  final String value;
  const _BookingRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
      ],
    );
  }
}
