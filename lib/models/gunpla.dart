const grades = ['HG', 'RG', 'MG', 'PG', 'SD'];
const buildStatuses = ['ยังไม่ประกอบ', 'กำลังประกอบ', 'ประกอบแล้ว'];

class Gunpla {
  final int? id;
  final String name;
  final String modelCode;
  final String grade;
  final String status;
  // Integer satang avoids floating point rounding in stored prices.
  final int priceSatang;
  final String notes;

  const Gunpla({this.id, required this.name, required this.modelCode,
    required this.grade, required this.status,
    required this.priceSatang, this.notes = ''});

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name, 'model_code': modelCode, 'grade': grade,
    'status': status, 'price_satang': priceSatang, 'notes': notes,
  };

  factory Gunpla.fromMap(Map<String, Object?> map) => Gunpla(
    id: map['id'] as int, name: map['name'] as String,
    modelCode: map['model_code'] as String, grade: map['grade'] as String,
    status: map['status'] as String, priceSatang: map['price_satang'] as int,
    notes: map['notes'] as String,
  );
}

int? parsePrice(String input) {
  final value = input.trim();
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  return int.parse(parts[0]) * 100 +
      (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
}

String money(int satang) => '${satang ~/ 100}.${(satang % 100).toString().padLeft(2, '0')}';
