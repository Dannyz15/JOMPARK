import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'app_state.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'jompark.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL,
        model TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration TEXT NOT NULL,
        slot TEXT NOT NULL,
        amount TEXT NOT NULL,
        rawAmount REAL NOT NULL,
        type TEXT NOT NULL,
        plate TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconColorValue INTEGER NOT NULL,
        iconBgValue INTEGER NOT NULL
      )
    ''');

    // Data awal kenderaan
    for (final v in [
      {'plate': 'PETRA 2002', 'model': 'Porsche 911 GT3 RS', 'color': 'Putih'},
      {'plate': 'FAEDIY 1115', 'model': 'Mitsubishi Evo 10', 'color': 'Hitam'},
      {'plate': 'BOBBY 04', 'model': 'Lamborghini Aventador', 'color': 'Hitam'},
    ]) {
      await db.insert('vehicles', v);
    }

    // Data awal sejarah (oldest first, query returns newest first via id DESC)
    for (final h in _seedHistory) {
      await db.insert('history', h);
    }
  }

  static final _seedHistory = [
    {
      'name': 'PWTC Parking',
      'date': '25 Okt 2024',
      'duration': '4 jam',
      'slot': 'L2-33',
      'amount': 'RM 4.00',
      'rawAmount': 4.00,
      'type': 'Luar bangunan',
      'plate': 'BOBBY 04',
      'iconCodePoint': Icons.local_parking.codePoint,
      'iconColorValue': const Color(0xFF34D399).toARGB32(),
      'iconBgValue': const Color(0xFF1A3A2E).toARGB32(),
    },
    {
      'name': 'Chow Kit Plaza EV',
      'date': '28 Okt 2024',
      'duration': '1 jam',
      'slot': 'EV-02',
      'amount': 'RM 3.00',
      'rawAmount': 3.00,
      'type': 'EV Charging',
      'plate': 'PETRA 2002',
      'iconCodePoint': Icons.electric_car.codePoint,
      'iconColorValue': const Color(0xFFFBBF24).toARGB32(),
      'iconBgValue': const Color(0xFF3A2E1A).toARGB32(),
    },
    {
      'name': 'DBP Parking',
      'date': '1 Nov 2024',
      'duration': '3 jam',
      'slot': 'P1-14',
      'amount': 'RM 7.50',
      'rawAmount': 7.50,
      'type': 'Dalam bangunan',
      'plate': 'FAEDIY 1115',
      'iconCodePoint': Icons.local_library.codePoint,
      'iconColorValue': const Color(0xFFA78BFA).toARGB32(),
      'iconBgValue': const Color(0xFF2E1A3A).toARGB32(),
    },
    {
      'name': 'Masjid KBaru Open Air',
      'date': '3 Nov 2024',
      'duration': '2 jam',
      'slot': 'A-07',
      'amount': 'RM 3.00',
      'rawAmount': 3.00,
      'type': 'Luar bangunan',
      'plate': 'BOBBY 04',
      'iconCodePoint': Icons.local_parking.codePoint,
      'iconColorValue': const Color(0xFF4ADE80).toARGB32(),
      'iconBgValue': const Color(0xFF1A3A2E).toARGB32(),
    },
    {
      'name': 'Kg. Baru Sentral P',
      'date': '5 Nov 2024',
      'duration': '2 jam',
      'slot': 'B1-08',
      'amount': 'RM 4.00',
      'rawAmount': 4.00,
      'type': 'Dalam bangunan',
      'plate': 'PETRA 2002',
      'iconCodePoint': Icons.business.codePoint,
      'iconColorValue': const Color(0xFF60A5FA).toARGB32(),
      'iconBgValue': const Color(0xFF1E3A5F).toARGB32(),
    },
  ];

  // ── Kenderaan ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final db = await database;
    return db.query('vehicles', orderBy: 'id ASC');
  }

  Future<int> insertVehicle(Map<String, dynamic> v) async {
    final db = await database;
    return db.insert('vehicles', {
      'plate': v['plate'],
      'model': v['model'],
      'color': v['color'],
    });
  }

  Future<void> updateVehicle(int id, Map<String, dynamic> v) async {
    final db = await database;
    await db.update(
      'vehicles',
      {'plate': v['plate'], 'model': v['model'], 'color': v['color']},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteVehicle(int id) async {
    final db = await database;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // ── Sejarah ───────────────────────────────────────────────────────────────

  Future<List<HistoryEntry>> getHistory() async {
    final db = await database;
    final rows = await db.query('history', orderBy: 'id DESC');
    return rows.map((r) => HistoryEntry(
      id: r['id'] as int,
      name: r['name'] as String,
      date: r['date'] as String,
      duration: r['duration'] as String,
      slot: r['slot'] as String,
      amount: r['amount'] as String,
      rawAmount: (r['rawAmount'] as num).toDouble(),
      type: r['type'] as String,
      plate: r['plate'] as String,
      icon: IconData(r['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(r['iconColorValue'] as int),
      iconBg: Color(r['iconBgValue'] as int),
    )).toList();
  }

  Future<int> insertHistory(HistoryEntry entry) async {
    final db = await database;
    return db.insert('history', {
      'name': entry.name,
      'date': entry.date,
      'duration': entry.duration,
      'slot': entry.slot,
      'amount': entry.amount,
      'rawAmount': entry.rawAmount,
      'type': entry.type,
      'plate': entry.plate,
      'iconCodePoint': entry.icon.codePoint,
      'iconColorValue': entry.iconColor.toARGB32(),
      'iconBgValue': entry.iconBg.toARGB32(),
    });
  }

  Future<void> updateHistoryDuration(int id, String duration) async {
    final db = await database;
    await db.update(
      'history',
      {'duration': duration},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
