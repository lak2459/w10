import 'package:flutter/material.dart';
import '../database/gunpla_database.dart';
import '../models/gunpla.dart';

class GunplaFormScreen extends StatefulWidget {
  const GunplaFormScreen({super.key, this.item});
  final Gunpla? item;
  @override
  State<GunplaFormScreen> createState() => _GunplaFormScreenState();
}

class _GunplaFormScreenState extends State<GunplaFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name, _code, _price, _notes;
  late String _grade, _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _code = TextEditingController(text: item?.modelCode ?? '');
    _price = TextEditingController(text: item == null ? '' : money(item.priceSatang));
    _notes = TextEditingController(text: item?.notes ?? '');
    _grade = item?.grade ?? grades.first;
    _status = item?.status ?? buildStatuses.first;
  }

  @override
  void dispose() {
    for (final controller in [_name, _code, _price, _notes]) { controller.dispose(); }
    super.dispose();
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)));

  Future<void> _save() async {
    if (_busy || !_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await GunplaDatabase.instance.save(Gunpla(
        id: widget.item?.id, name: _name.text.trim(), modelCode: _code.text.trim(),
        grade: _grade, status: _status, priceSatang: parsePrice(_price.text)!,
        notes: _notes.text.trim()));
      if (mounted) { setState(() => _busy = false); Navigator.of(context).pop(true); }
    } catch (_) {
      if (mounted) { setState(() => _busy = false); _message('บันทึกไม่ได้ กรุณาลองใหม่'); }
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('ลบรายการนี้หรือไม่'),
      content: Text('ต้องการลบ ${widget.item!.name} ออกจากคอลเลกชันหรือไม่'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ลบรายการ')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await GunplaDatabase.instance.delete(widget.item!.id!);
      if (mounted) { setState(() => _busy = false); Navigator.of(context).pop(true); }
    } catch (_) {
      if (mounted) { setState(() => _busy = false); _message('ลบไม่ได้ กรุณาลองใหม่'); }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? 'เพิ่มกันพลา' : 'แก้ไขกันพลา'), actions: [
        if (widget.item != null) IconButton(tooltip: 'ลบรายการ',
          onPressed: _busy ? null : _delete, icon: const Icon(Icons.delete_outline)),
      ]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(padding: const EdgeInsets.all(20),
          child: Form(key: _key, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('รายละเอียดโมเดล', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(controller: _name, enabled: !_busy, maxLength: 100,
              decoration: const InputDecoration(labelText: 'ชื่อกันพลา', hintText: 'เช่น RX-78-2 Gundam'),
              validator: (value) => value == null || value.trim().isEmpty ? 'กรุณากรอกชื่อกันพลา' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _code, enabled: !_busy, maxLength: 40,
              decoration: const InputDecoration(labelText: 'รหัสรุ่น', hintText: 'เช่น RX-78-2'),
              validator: (value) => value == null || value.trim().isEmpty ? 'กรุณากรอกรหัสรุ่น' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _grade,
              decoration: const InputDecoration(labelText: 'เกรด'),
              items: grades.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: _busy ? null : (value) => setState(() => _grade = value!)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(initialValue: _status,
              decoration: const InputDecoration(labelText: 'สถานะการประกอบ'),
              items: buildStatuses.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: _busy ? null : (value) => setState(() => _status = value!)),
            const SizedBox(height: 20),
            TextFormField(controller: _price, enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'ราคา บาท', hintText: 'เช่น 650.00'),
              validator: (value) => parsePrice(value ?? '') == null
                ? 'กรอก 0–9999999.99 ทศนิยมไม่เกิน 2 ตำแหน่ง ไม่ใส่ comma' : null),
            const SizedBox(height: 20),
            TextFormField(controller: _notes, enabled: !_busy, maxLength: 500, maxLines: 3,
              decoration: const InputDecoration(labelText: 'หมายเหตุ ไม่บังคับ')),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _busy ? null : _save,
              icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
              label: Padding(padding: const EdgeInsets.all(12), child: Text(_busy ? 'กำลังบันทึก' : 'บันทึกข้อมูล'))),
          ])),
        ),
      )),
    ),
  );
}
