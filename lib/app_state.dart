import 'package:flutter/material.dart';

class HistoryEntry {
  final String name, date, duration, slot, amount, type, plate;
  final double rawAmount;
  final IconData icon;
  final Color iconColor, iconBg;

  const HistoryEntry({
    required this.name,
    required this.date,
    required this.duration,
    required this.slot,
    required this.amount,
    required this.rawAmount,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.type,
    required this.plate,
  });
}

class ActiveTicket {
  final String name, slot, plate;
  final int totalHours;
  final double pricePerHour, totalAmount;
  final DateTime startTime;

  ActiveTicket({
    required this.name,
    required this.slot,
    required this.plate,
    required this.totalHours,
    required this.pricePerHour,
    required this.totalAmount,
    required this.startTime,
  });

  int get totalSeconds => totalHours * 3600;

  String get startTimeLabel {
    final h = startTime.hour.toString().padLeft(2, '0');
    final m = startTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String endTimeLabel(int extraSeconds) {
    final end = startTime.add(Duration(seconds: totalSeconds + extraSeconds));
    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }
}

class AppState {
  AppState._();
  static final AppState instance = AppState._();

  final activeTicket = ValueNotifier<ActiveTicket?>(null);

  final vehicles = ValueNotifier<List<Map<String, dynamic>>>([
    {'plate': 'PETRA 2002', 'model': 'Porsche 911 GT3 RS', 'color': 'Putih'},
    {'plate': 'FAEDIY 1115', 'model': 'Mitsubishi Evo 10', 'color': 'Hitam'},
    {'plate': 'BOBBY 04', 'model': 'Lamborghini Aventador', 'color': 'Hitam'},
  ]);

  final parkingList = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'name': 'Kg. Baru Sentral P',
      'distance': 0.2,
      'level': 'Tingkat B1-B3',
      'price': 2.0,
      'totalSlots': 40,
      'availableSlots': 26,
      'icon': Icons.business,
      'iconColor': const Color(0xFF60A5FA),
      'iconBg': const Color(0xFF1E3A5F),
      'priceColor': const Color(0xFF60A5FA),
      'is24Hours': true,
      'type': 'indoor',
    },
    {
      'name': 'Masjid KBaru Open Air',
      'distance': 0.5,
      'level': 'Luar bangunan',
      'price': 1.5,
      'totalSlots': 25,
      'availableSlots': 11,
      'icon': Icons.local_parking,
      'iconColor': const Color(0xFF4ADE80),
      'iconBg': const Color(0xFF1A3A2E),
      'priceColor': const Color(0xFFFBBF24),
      'is24Hours': false,
      'type': 'outdoor',
    },
    {
      'name': 'Chow Kit Plaza EV',
      'distance': 0.9,
      'level': 'EV Charging',
      'price': 3.0,
      'totalSlots': 10,
      'availableSlots': 4,
      'icon': Icons.electric_car,
      'iconColor': const Color(0xFFFBBF24),
      'iconBg': const Color(0xFF3A2E1A),
      'priceColor': const Color(0xFFF87171),
      'is24Hours': true,
      'type': 'ev',
    },
    {
      'name': 'DBP Parking',
      'distance': 1.1,
      'level': 'Tingkat P1-P2',
      'price': 2.5,
      'totalSlots': 60,
      'availableSlots': 38,
      'icon': Icons.local_library,
      'iconColor': const Color(0xFFA78BFA),
      'iconBg': const Color(0xFF2E1A3A),
      'priceColor': const Color(0xFFA78BFA),
      'is24Hours': false,
      'type': 'indoor',
    },
    {
      'name': 'PWTC Parking',
      'distance': 1.4,
      'level': 'Luar bangunan',
      'price': 1.0,
      'totalSlots': 120,
      'availableSlots': 84,
      'icon': Icons.local_parking,
      'iconColor': const Color(0xFF34D399),
      'iconBg': const Color(0xFF1A3A2E),
      'priceColor': const Color(0xFF34D399),
      'is24Hours': true,
      'type': 'outdoor',
    },
  ]);

  void bookParking(String name) {
    final list = parkingList.value.map((p) {
      if (p['name'] == name && (p['availableSlots'] as int) > 0) {
        return {...p, 'availableSlots': (p['availableSlots'] as int) - 1};
      }
      return p;
    }).toList();
    parkingList.value = list;
  }

  void releaseParking(String name) {
    final list = parkingList.value.map((p) {
      if (p['name'] == name && (p['availableSlots'] as int) < (p['totalSlots'] as int)) {
        return {...p, 'availableSlots': (p['availableSlots'] as int) + 1};
      }
      return p;
    }).toList();
    parkingList.value = list;
  }

  final history = ValueNotifier<List<HistoryEntry>>(const [
    HistoryEntry(
      name: 'Kg. Baru Sentral P',
      date: '5 Nov 2024',
      duration: '2 jam',
      slot: 'B1-08',
      amount: 'RM 4.00',
      rawAmount: 4.00,
      icon: Icons.business,
      iconColor: Color(0xFF60A5FA),
      iconBg: Color(0xFF1E3A5F),
      type: 'Dalam bangunan',
      plate: 'PETRA 2002',
    ),
    HistoryEntry(
      name: 'Masjid KBaru Open Air',
      date: '3 Nov 2024',
      duration: '2 jam',
      slot: 'A-07',
      amount: 'RM 3.00',
      rawAmount: 3.00,
      icon: Icons.local_parking,
      iconColor: Color(0xFF4ADE80),
      iconBg: Color(0xFF1A3A2E),
      type: 'Luar bangunan',
      plate: 'BOBBY 04',
    ),
    HistoryEntry(
      name: 'DBP Parking',
      date: '1 Nov 2024',
      duration: '3 jam',
      slot: 'P1-14',
      amount: 'RM 7.50',
      rawAmount: 7.50,
      icon: Icons.local_library,
      iconColor: Color(0xFFA78BFA),
      iconBg: Color(0xFF2E1A3A),
      type: 'Dalam bangunan',
      plate: 'FAEDIY 1115',
    ),
    HistoryEntry(
      name: 'Chow Kit Plaza EV',
      date: '28 Okt 2024',
      duration: '1 jam',
      slot: 'EV-02',
      amount: 'RM 3.00',
      rawAmount: 3.00,
      icon: Icons.electric_car,
      iconColor: Color(0xFFFBBF24),
      iconBg: Color(0xFF3A2E1A),
      type: 'EV Charging',
      plate: 'PETRA 2002',
    ),
    HistoryEntry(
      name: 'PWTC Parking',
      date: '25 Okt 2024',
      duration: '4 jam',
      slot: 'L2-33',
      amount: 'RM 4.00',
      rawAmount: 4.00,
      icon: Icons.local_parking,
      iconColor: Color(0xFF34D399),
      iconBg: Color(0xFF1A3A2E),
      type: 'Luar bangunan',
      plate: 'BOBBY 04',
    ),
  ]);

  void addBooking(HistoryEntry entry) {
    history.value = [entry, ...history.value];
  }

  void updateLastBookingDuration(String duration) {
    if (history.value.isEmpty) return;
    final first = history.value[0];
    final updated = HistoryEntry(
      name: first.name,
      date: first.date,
      duration: duration,
      slot: first.slot,
      amount: first.amount,
      rawAmount: first.rawAmount,
      icon: first.icon,
      iconColor: first.iconColor,
      iconBg: first.iconBg,
      type: first.type,
      plate: first.plate,
    );
    history.value = [updated, ...history.value.sublist(1)];
  }
}

String formatDateMy(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ogs', 'Sep', 'Okt', 'Nov', 'Dis',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
