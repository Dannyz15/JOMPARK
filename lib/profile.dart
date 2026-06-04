import 'package:flutter/material.dart';
import 'package:jompark/app_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Ahmad Haziq';
  String _email = 'ahmad.haziq@email.com';
  int _mainVehicleIndex = 0;

  List<Map<String, dynamic>> get _vehicles => AppState.instance.vehicles.value;

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Nama Penuh', Icons.person),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDeco('E-mel', Icons.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _name = nameCtrl.text.trim();
                  _email = emailCtrl.text.trim();
                });
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berjaya dikemaskini'),
                  backgroundColor: Color(0xFF059669),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVehicleOptions(int index) {
    final v = _vehicles[index];
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
            Text('${v['plate']} — ${v['model']}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${v['color']}', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            const SizedBox(height: 20),
            if (_mainVehicleIndex != index)
              _OptionTile(
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4ADE80),
                label: 'Tetapkan sebagai Utama',
                onTap: () {
                  setState(() => _mainVehicleIndex = index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${v['plate']} ditetapkan sebagai kenderaan utama'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                },
              ),
            if (_mainVehicleIndex != index) const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.edit_outlined,
              color: const Color(0xFF60A5FA),
              label: 'Edit Kenderaan',
              onTap: () {
                Navigator.pop(context);
                _showEditVehicle(index);
              },
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.delete_outline,
              color: const Color(0xFFF87171),
              label: 'Padam Kenderaan',
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteVehicle(index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditVehicle(int index) {
    final v = _vehicles[index];
    final plateCtrl = TextEditingController(text: v['plate'] as String);
    final modelCtrl = TextEditingController(text: v['model'] as String);
    final colorCtrl = TextEditingController(text: v['color'] as String);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Kenderaan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('No. Plat', Icons.directions_car),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Model Kenderaan', Icons.directions_car_filled),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: colorCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Warna', Icons.palette),
            ),
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
              await AppState.instance.updateVehicle(index, {
                'plate': plateCtrl.text.trim().toUpperCase(),
                'model': modelCtrl.text.trim(),
                'color': colorCtrl.text.trim(),
              });
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kenderaan dikemaskini'), backgroundColor: Color(0xFF059669)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVehicle(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Padam Kenderaan?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Anda pasti ingin memadam ${_vehicles[index]['plate']}?',
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AppState.instance.removeVehicle(index);
              if (mounted) {
                setState(() {
                  if (_mainVehicleIndex >= AppState.instance.vehicles.value.length) {
                    _mainVehicleIndex = 0;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kenderaan dipadam'), backgroundColor: Color(0xFFDC2626)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Padam', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addVehicle() {
    final plateCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final colorCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Kenderaan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('No. Plat', Icons.directions_car),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Model Kenderaan', Icons.directions_car_filled),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: colorCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Warna', Icons.palette),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (plateCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await AppState.instance.addVehicle({
                'plate': plateCtrl.text.trim().toUpperCase(),
                'model': modelCtrl.text.trim(),
                'color': colorCtrl.text.trim(),
              });
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kenderaan ditambah'), backgroundColor: Color(0xFF059669)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFF1A2035),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profil Saya',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(28)),
                  child: Center(
                    child: Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() + (_name.contains(' ') ? _name.split(' ')[1][0].toUpperCase() : '') : 'AH',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(_email,
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium,
                                color: Color(0xFF60A5FA), size: 13),
                            SizedBox(width: 4),
                            Text('Member Premium',
                                style: TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showEditProfile,
                  child: const Icon(Icons.edit_outlined, color: Color(0xFF6B7280), size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),


          // Vehicles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kenderaan Saya',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: _addVehicle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Color(0xFF60A5FA), size: 14),
                      SizedBox(width: 4),
                      Text('Tambah', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_vehicles.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(14)),
              child: const Center(
                child: Text('Tiada kenderaan. Tambah kenderaan anda.',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            )
          else
            ...List.generate(_vehicles.length, (i) {
              final v = _vehicles[i];
              final isMain = _mainVehicleIndex == i;
              return Padding(
                padding: EdgeInsets.only(bottom: i < _vehicles.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => _showVehicleOptions(i),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFF141B2D),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.directions_car,
                              color: Color(0xFF9CA3AF), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v['plate'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text('${v['model']} • ${v['color']}',
                                  style: const TextStyle(
                                      color: Color(0xFF9CA3AF), fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isMain)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF14532D),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Utama',
                                style: TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          )
                        else
                          const Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF6B7280), size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 20),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF141B2D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Log Keluar?',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    content: const Text(
                      'Anda pasti ingin log keluar dari akaun ini?',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal',
                            style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Log Keluar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, size: 18, color: Color(0xFFF87171)),
              label: const Text('Log Keluar',
                  style: TextStyle(color: Color(0xFFF87171), fontSize: 15)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF87171)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _OptionTile(
      {required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF1A2035), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

