import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jompark/app_state.dart';

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> {
  int _remainingSeconds = 0;
  int _extraMinutes = 0;
  double _totalExtendedAmount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initFromTicket();
    AppState.instance.activeTicket.addListener(_onTicketChanged);
  }

  @override
  void dispose() {
    AppState.instance.activeTicket.removeListener(_onTicketChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _initFromTicket() {
    final ticket = AppState.instance.activeTicket.value;
    if (ticket != null) {
      _remainingSeconds = ticket.totalSeconds;
      _startTimer();
    }
  }

  void _onTicketChanged() {
    _timer?.cancel();
    final ticket = AppState.instance.activeTicket.value;
    setState(() {
      _extraMinutes = 0;
      _totalExtendedAmount = 0;
      _remainingSeconds = ticket?.totalSeconds ?? 0;
    });
    if (ticket != null) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds == 0) _timer?.cancel();
      }
    });
  }

  String get _timeLabel {
    final h = _remainingSeconds ~/ 3600;
    final m = (_remainingSeconds % 3600) ~/ 60;
    final s = _remainingSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  int get _totalWithExtra {
    final ticket = AppState.instance.activeTicket.value;
    return (ticket?.totalSeconds ?? 0) + _extraMinutes * 60;
  }

  double get _progress =>
      _totalWithExtra > 0 ? (_remainingSeconds / _totalWithExtra).clamp(0.0, 1.0) : 0.0;

  void _confirmExtend(int addMinutes, double amount) {
    final label = addMinutes < 60 ? '+$addMinutes minit' : '+${addMinutes ~/ 60} jam';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sahkan Lanjut Masa?',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            _InfoRow('Tambahan masa', label),
            _InfoRow('Bayaran tambahan', 'RM ${amount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              setState(() {
                _remainingSeconds += addMinutes * 60;
                _extraMinutes += addMinutes;
                _totalExtendedAmount += amount;
              });
              _showExtendSuccess(addMinutes, amount);
              final ticket = AppState.instance.activeTicket.value;
              if (ticket != null) {
                final origStr = '${ticket.totalHours} jam';
                final extH = _extraMinutes ~/ 60;
                final extM = _extraMinutes % 60;
                final extStr = extH > 0 && extM > 0
                    ? '$extH jam $extM minit'
                    : extH > 0
                        ? '$extH jam'
                        : '$extM minit';
                await AppState.instance.updateLastBookingDuration('$origStr + $extStr');
                await AppState.instance.updateLastBookingAmount(amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sahkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExtendTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141B2D),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lanjut Masa Parking',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Pilih tempoh tambahan:',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            const SizedBox(height: 16),
            _ExtendOption(
              duration: '+30 minit',
              price: 'RM 1.00',
              onTap: () => _confirmExtend(30, 1.00),
            ),
            const SizedBox(height: 10),
            _ExtendOption(
              duration: '+1 jam',
              price: 'RM 2.00',
              onTap: () => _confirmExtend(60, 2.00),
            ),
            const SizedBox(height: 10),
            _ExtendOption(
              duration: '+2 jam',
              price: 'RM 4.00',
              onTap: () => _confirmExtend(120, 4.00),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExtendSuccess(int minutes, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4ADE80)),
            const SizedBox(width: 8),
            Text(
              'Masa dilanjutkan ${minutes < 60 ? "$minutes minit" : "${minutes ~/ 60} jam"}. Bayaran: RM ${amount.toStringAsFixed(2)}',
            ),
          ],
        ),
        backgroundColor: const Color(0xFF14532D),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCheckout() {
    final ticket = AppState.instance.activeTicket.value;
    if (ticket == null) return;

    final elapsed = DateTime.now().difference(ticket.startTime);
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final parkedLabel = h > 0 ? '${h}j ${m}m' : '${elapsed.inMinutes} minit';
    final charge = ticket.totalAmount + _totalExtendedAmount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sahkan Keluar?',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            _InfoRow('Lokasi', ticket.name),
            _InfoRow('Slot', ticket.slot),
            _InfoRow('No. Plat', ticket.plate),
            _InfoRow('Masa diparkir', parkedLabel),
            _InfoRow('Jumlah bayaran', 'RM ${charge.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showReceiptDialog(charge, ticket.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(double amount, String parkingName) {
    _timer?.cancel();
    AppState.instance.releaseParking(parkingName);
    AppState.instance.activeTicket.value = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.check_circle_outline, color: Color(0xFF4ADE80), size: 64),
            const SizedBox(height: 16),
            const Text('Terima Kasih!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Anda telah berjaya keluar dari $parkingName.',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A2035), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jumlah Dibayar',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                  Text('RM ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF4ADE80), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Selesai', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ActiveTicket?>(
      valueListenable: AppState.instance.activeTicket,
      builder: (context, ticket, _) {
        if (ticket == null) return _buildEmpty();
        return _buildTicket(ticket);
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: Color(0xFF374151), size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Tiada Tiket Aktif',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Beli parking dari halaman Peta\nuntuk melihat tiket anda di sini.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTicket(ActiveTicket ticket) {
    final amountLabel =
        'RM ${ticket.totalAmount % 1 == 0 ? ticket.totalAmount.toInt() : ticket.totalAmount.toStringAsFixed(2)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiket Aktif',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFF14532D), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                    SizedBox(width: 5),
                    Text('Aktif',
                        style: TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${ticket.name} • Slot ${ticket.slot}',
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          const SizedBox(height: 16),

          // Timer card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Text('Masa Berbaki',
                    style: TextStyle(color: Color(0xFFBAE6FD), fontSize: 14)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _remainingSeconds == 0 ? 1.0 : _progress,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFF1E40AF),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingSeconds == 0
                                ? const Color(0xFFF87171)
                                : const Color(0xFF60A5FA),
                          ),
                        ),
                      ),
                      Text(
                        _remainingSeconds == 0 ? 'TAMAT' : _timeLabel,
                        style: TextStyle(
                            color: _remainingSeconds == 0
                                ? const Color(0xFFF87171)
                                : Colors.white,
                            fontSize: _remainingSeconds == 0 ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'daripada ${(_totalWithExtra / 3600).toStringAsFixed(_extraMinutes % 60 == 0 ? 0 : 1)} jam',
                  style: const TextStyle(color: Color(0xFFBAE6FD), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(label: 'No. Plat', value: ticket.plate),
                Container(width: 1, height: 36, color: const Color(0xFF374151)),
                _DetailItem(label: 'Slot', value: ticket.slot),
                Container(width: 1, height: 36, color: const Color(0xFF374151)),
                _DetailItem(label: 'Bayaran', value: amountLabel),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Times
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF141B2D),
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Text(ticket.startTimeLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Masuk',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF141B2D),
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Text(
                        ticket.endTimeLabel(_extraMinutes * 60),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Tamat',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showExtendTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: const Text('Lanjut Masa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF374151)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showCheckout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ExtendOption extends StatelessWidget {
  final String duration;
  final String price;
  final VoidCallback onTap;

  const _ExtendOption(
      {required this.duration, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF1A2035), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0xFF60A5FA), size: 20),
                const SizedBox(width: 10),
                Text(duration,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            Text(price,
                style: const TextStyle(
                    color: Color(0xFF4ADE80), fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
