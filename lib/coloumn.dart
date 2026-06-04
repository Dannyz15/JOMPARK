import 'package:flutter/material.dart';
import 'package:jompark/home.dart';
import 'package:jompark/tiket.dart';
import 'package:jompark/sejarah.dart';
import 'package:jompark/profile.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ColumnPage extends StatefulWidget {
  const ColumnPage({super.key});

  @override
  State<ColumnPage> createState() => _ColumnPageState();
}

class _ColumnPageState extends State<ColumnPage> {
  int _currentIndex = 0;
  String _appVersion = '';

  final List<Widget> _pages = const [
    HomePage(),
    TiketPage(),
    SejarahPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    });
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),
      appBar: AppBar(
        title: const Text(
          'Jom Park',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B0F1E),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: _AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: (i) {
          setState(() => _currentIndex = i);
          Navigator.pop(context);
        },
        onLogout: _logout,
        appVersion: _appVersion,
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0B0F1E),
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Tiket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time),
              label: 'Sejarah',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onNavigate;
  final VoidCallback onLogout;
  final String appVersion;

  const _AppDrawer({
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
    required this.appVersion,
  });

  static const _items = [
    (icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Peta'),
    (icon: Icons.confirmation_number_outlined, activeIcon: Icons.confirmation_number, label: 'Tiket'),
    (icon: Icons.access_time_outlined, activeIcon: Icons.access_time, label: 'Sejarah'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF141B2D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B0F1E),
                border: Border(bottom: BorderSide(color: Color(0xFF1F2A40))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_parking, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jom Park',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(appVersion,
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Nav items
            ...List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = currentIndex == i;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  onTap: () => onNavigate(i),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isActive ? const Color(0xFF1E3A5F) : Colors.transparent,
                  leading: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? const Color(0xFF60A5FA) : const Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF60A5FA) : Colors.white,
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),
            const Divider(color: Color(0xFF1F2A40), indent: 16, endIndent: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              child: ListTile(
                onTap: onLogout,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: Color(0xFFF87171), size: 22),
                title: const Text(
                  'Log Keluar',
                  style: TextStyle(
                      color: Color(0xFFF87171),
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
