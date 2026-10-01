import 'package:flutter/material.dart';
import '../database/gunpla_database.dart';
import '../models/gunpla.dart';
import '../widgets/gunpla_card.dart';
import 'gunpla_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gunpla> _items = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _grade = 'ทั้งหมด';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await GunplaDatabase.instance.readAll();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _error = 'เปิดข้อมูลไม่ได้ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open([Gunpla? item]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => GunplaFormScreen(item: item)));
    if (!mounted || changed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกการเปลี่ยนแปลงแล้ว')));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = _items.where((item) =>
      (_grade == 'ทั้งหมด' || item.grade == _grade) &&
      ('${item.name} ${item.modelCode}'.toLowerCase().contains(query))).toList();
    final total = _items.fold<int>(0, (sum, item) => sum + item.priceSatang);
    return Scaffold(
      appBar: AppBar(title: const Text('Gunpla Collection'), actions: [
        IconButton(tooltip: 'โหลดข้อมูลใหม่', onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading || _error != null ? null : () => _open(),
        icon: const Icon(Icons.add), label: const Text('เพิ่มกันพลา')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760),
        child: _loading ? const Center(child: CircularProgressIndicator())
        : _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!), TextButton(onPressed: _load, child: const Text('ลองใหม่')),
        ])) : Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Card(color: const Color(0xFF233D8F), child: Padding(
                padding: const EdgeInsets.all(20), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('คอลเลกชันของฉัน', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${_items.length} รายการ', style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('มูลค่ารวม ${money(total)} บาท', style: const TextStyle(color: Colors.white)),
                  ]))),
              const SizedBox(height: 16),
              TextField(onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(hintText: 'ค้นหาชื่อหรือรหัสรุ่น',
                  prefixIcon: Icon(Icons.search))),
              const SizedBox(height: 10),
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Row(children: ['ทั้งหมด', ...grades].map((grade) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(label: Text(grade), selected: _grade == grade,
                    onSelected: (_) => setState(() => _grade = grade)),
                )).toList())),
              const SizedBox(height: 8), Text('แสดง ${visible.length} รายการ'),
            ])),
          Expanded(child: visible.isEmpty ? Center(child: Padding(
            padding: const EdgeInsets.all(24), child: Text(_items.isEmpty
              ? 'ยังไม่มีข้อมูล กด “เพิ่มกันพลา” เพื่อเริ่มต้น'
              : 'ไม่พบรายการที่ตรงกับการค้นหา', textAlign: TextAlign.center)))
            : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: visible.length, itemBuilder: (_, index) => GunplaCard(
                item: visible[index], onTap: () => _open(visible[index])))),
        ]))),
    );
  }
}
