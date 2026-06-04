import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryEntry {
  final int? id;
  final String name, date, duration, slot, amount, type, plate;
  final double rawAmount;
  final IconData icon;
  final Color iconColor, iconBg;

  const HistoryEntry({
    this.id,
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
  final int extraMinutes;
  final double pricePerHour, totalAmount, extendedAmount;
  final DateTime startTime;

  ActiveTicket({
    required this.name,
    required this.slot,
    required this.plate,
    required this.totalHours,
    required this.pricePerHour,
    required this.totalAmount,
    required this.startTime,
    this.extraMinutes = 0,
    this.extendedAmount = 0,
  });

  int get totalSeconds => totalHours * 3600;
  int get totalBookedSeconds => totalSeconds + extraMinutes * 60;

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (totalBookedSeconds - elapsed).clamp(0, totalBookedSeconds);
  }

  String get startTimeLabel {
    final h = startTime.hour.toString().padLeft(2, '0');
    final m = startTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String endTimeLabel(int extraSeconds) {
    final end = startTime.add(Duration(seconds: totalBookedSeconds + extraSeconds));
    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }
}

class AppState {
  AppState._();
  static final AppState instance = AppState._();

  final activeTicket = ValueNotifier<ActiveTicket?>(null);
  final vehicles = ValueNotifier<List<Map<String, dynamic>>>([]);
  final profileName = ValueNotifier<String>('Ahmad Haziq');
  final profileEmail = ValueNotifier<String>('ahmad.haziq@email.com');

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

  final history = ValueNotifier<List<HistoryEntry>>([]);

  Future<void> init() async {
    final db = DatabaseHelper.instance;
    final v = await db.getVehicles();
    vehicles.value = v;
    final h = await db.getHistory();
    history.value = h;
    final p = await db.getProfile();
    profileName.value = p['name']!;
    profileEmail.value = p['email']!;
    final t = await db.getActiveTicket();
    if (t != null && t.remainingSeconds > 0) {
      activeTicket.value = t;
    } else if (t != null) {
      await db.clearActiveTicket();
    }
  }

  Future<void> saveActiveTicket(ActiveTicket ticket) async {
    await DatabaseHelper.instance.saveActiveTicket(ticket);
    activeTicket.value = ticket;
  }

  Future<void> extendActiveTicket(int extraMinutes, double extendedAmount) async {
    final ticket = activeTicket.value;
    if (ticket == null) return;
    final updated = ActiveTicket(
      name: ticket.name, slot: ticket.slot, plate: ticket.plate,
      totalHours: ticket.totalHours, pricePerHour: ticket.pricePerHour,
      totalAmount: ticket.totalAmount, startTime: ticket.startTime,
      extraMinutes: extraMinutes, extendedAmount: extendedAmount,
    );
    await DatabaseHelper.instance.updateActiveTicketExtension(extraMinutes, extendedAmount);
    activeTicket.value = updated;
  }

  Future<void> clearActiveTicket() async {
    await DatabaseHelper.instance.clearActiveTicket();
    activeTicket.value = null;
  }

  Future<void> updateProfile(String name, String email) async {
    await DatabaseHelper.instance.updateProfile(name, email);
    profileName.value = name;
    profileEmail.value = email;
  }

  Future<void> addVehicle(Map<String, dynamic> vehicle) async {
    final id = await DatabaseHelper.instance.insertVehicle(vehicle);
    vehicles.value = [...vehicles.value, {...vehicle, 'id': id}];
  }

  Future<void> updateVehicle(int index, Map<String, dynamic> vehicle) async {
    final id = vehicles.value[index]['id'] as int;
    await DatabaseHelper.instance.updateVehicle(id, vehicle);
    final list = [...vehicles.value];
    list[index] = {...vehicle, 'id': id};
    vehicles.value = list;
  }

  Future<void> removeVehicle(int index) async {
    final id = vehicles.value[index]['id'] as int;
    await DatabaseHelper.instance.deleteVehicle(id);
    final list = [...vehicles.value]..removeAt(index);
    vehicles.value = list;
  }

  Future<void> addBooking(HistoryEntry entry) async {
    final id = await DatabaseHelper.instance.insertHistory(entry);
    final saved = HistoryEntry(
      id: id, name: entry.name, date: entry.date, duration: entry.duration,
      slot: entry.slot, amount: entry.amount, rawAmount: entry.rawAmount,
      icon: entry.icon, iconColor: entry.iconColor, iconBg: entry.iconBg,
      type: entry.type, plate: entry.plate,
    );
    history.value = [saved, ...history.value];
  }

  Future<void> updateLastBookingAmount(double extraAmount) async {
    if (history.value.isEmpty) return;
    final first = history.value[0];
    final newRaw = first.rawAmount + extraAmount;
    final newAmount = 'RM ${newRaw.toStringAsFixed(2)}';
    if (first.id != null) {
      await DatabaseHelper.instance.updateHistoryAmount(first.id!, newAmount, newRaw);
    }
    final updated = HistoryEntry(
      id: first.id, name: first.name, date: first.date, duration: first.duration,
      slot: first.slot, amount: newAmount, rawAmount: newRaw,
      icon: first.icon, iconColor: first.iconColor, iconBg: first.iconBg,
      type: first.type, plate: first.plate,
    );
    history.value = [updated, ...history.value.sublist(1)];
  }

  Future<void> updateLastBookingDuration(String duration) async {
    if (history.value.isEmpty) return;
    final first = history.value[0];
    if (first.id != null) {
      await DatabaseHelper.instance.updateHistoryDuration(first.id!, duration);
    }
    final updated = HistoryEntry(
      id: first.id, name: first.name, date: first.date, duration: duration,
      slot: first.slot, amount: first.amount, rawAmount: first.rawAmount,
      icon: first.icon, iconColor: first.iconColor, iconBg: first.iconBg,
      type: first.type, plate: first.plate,
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
