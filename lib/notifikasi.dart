import 'package:flutter/material.dart';
import 'package:jompark/app_state.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B0F1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const _NotifBody(),
    );
  }
}

class _NotifBody extends StatelessWidget {
  const _NotifBody();

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru sahaja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minit lepas';
    if (diff.inHours < 24) return '${diff.inHours} jam lepas';
    if (diff.inDays == 1) return 'Semalam';
    return '${diff.inDays} hari lepas';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.instance.activeTicket,
      builder: (context, ticket, child) => ValueListenableBuilder(
        valueListenable: AppState.instance.history,
        builder: (context, history, child) => ValueListenableBuilder(
          valueListenable: AppState.instance.parkingList,
          builder: (context, parkingList, child) {
            final items = <_NotifItem>[];

            // Masa hampir tamat — active ticket < 15 min remaining
            if (ticket != null) {
              final remaining = ticket.remainingSeconds;
              if (remaining > 0 && remaining <= 15 * 60) {
                final minLeft = (remaining / 60).ceil();
                items.add(_NotifItem(
                  icon: Icons.access_time,
                  iconBg: const Color(0xFF3A2E1A),
                  iconColor: const Color(0xFFFBBF24),
                  title: 'Masa hampir tamat',
                  subtitle: 'Tempahan ${ticket.name} tamat dalam $minLeft minit.',
                  time: _timeAgo(ticket.startTime),
                ));
              }
            }

            // Tempahan berjaya — active ticket atau entri sejarah terkini
            if (ticket != null) {
              items.add(_NotifItem(
                icon: Icons.check_circle,
                iconBg: const Color(0xFF1A3A2E),
                iconColor: const Color(0xFF4ADE80),
                title: 'Tempahan berjaya',
                subtitle: 'Slot ${ticket.slot} di ${ticket.name} telah disahkan.',
                time: _timeAgo(ticket.startTime),
              ));
            } else if (history.isNotEmpty) {
              final last = history[0];
              items.add(_NotifItem(
                icon: Icons.check_circle,
                iconBg: const Color(0xFF1A3A2E),
                iconColor: const Color(0xFF4ADE80),
                title: 'Tempahan berjaya',
                subtitle: 'Slot ${last.slot} di ${last.name} telah disahkan.',
                time: last.date,
              ));
            }

            // Slot EV tersedia — dari senarai parkir
            for (final p in parkingList) {
              if (p['type'] == 'ev' && (p['availableSlots'] as int) > 0) {
                items.add(_NotifItem(
                  icon: Icons.electric_car,
                  iconBg: const Color(0xFF2E1A3A),
                  iconColor: const Color(0xFFA78BFA),
                  title: 'Slot EV tersedia',
                  subtitle:
                      '${p['name']} kini ada ${p['availableSlots']} slot EV yang kosong.',
                  time: '3 jam lepas',
                ));
              }
            }

            // Promosi — PWTC (static)
            final pwtc = parkingList.firstWhere(
              (p) => p['name'].toString().contains('PWTC'),
              orElse: () => {},
            );
            if (pwtc.isNotEmpty) {
              items.add(_NotifItem(
                icon: Icons.local_offer,
                iconBg: const Color(0xFF1E3A5F),
                iconColor: const Color(0xFF60A5FA),
                title: 'Promosi Jom Park',
                subtitle:
                    'Parking percuma 1 jam di ${pwtc['name']} setiap hujung minggu!',
                time: 'Semalam',
              ));
            }

            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, color: Color(0xFF374151), size: 56),
                    SizedBox(height: 12),
                    Text('Tiada notifikasi',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFF1F2A40), indent: 72, endIndent: 0),
              itemBuilder: (_, i) => _NotifTile(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle, time;

  const _NotifItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
