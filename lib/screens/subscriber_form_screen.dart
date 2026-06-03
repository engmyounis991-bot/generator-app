import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/subscriber.dart';
import '../utils/formatters.dart';

const Color kPrimary = Color(0xFF1A3A6B);

class SubscriberFormScreen extends StatefulWidget {
  final Subscriber? subscriber;
  const SubscriberFormScreen({super.key, this.subscriber});

  @override
  State<SubscriberFormScreen> createState() => _SubscriberFormScreenState();
}

class _SubscriberFormScreenState extends State<SubscriberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name,
      _phone,
      _price,
      _amp,
      _received,
      _prevDebt,
      _cabinet,
      _fuse,
      _notes;
  String _category = 'عادي';
  String _expiry = '';

  bool get _isEdit => widget.subscriber != null;

  @override
  void initState() {
    super.initState();
    final s = widget.subscriber;
    _name = TextEditingController(text: s?.name ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _price = TextEditingController(
        text: s != null && s.pricePerAmpere > 0 ? amp(s.pricePerAmpere) : '');
    _amp = TextEditingController(
        text: s != null && s.amperes > 0 ? amp(s.amperes) : '');
    _received = TextEditingController(
        text: s != null && s.amountReceived > 0 ? amp(s.amountReceived) : '');
    _prevDebt = TextEditingController(
        text: s != null && s.previousDebt > 0 ? amp(s.previousDebt) : '');
    _cabinet = TextEditingController(text: s?.cabinet ?? '');
    _fuse = TextEditingController(text: s?.fuse ?? '');
    _notes = TextEditingController(text: s?.notes ?? '');
    _category = s?.category ?? 'عادي';
    _expiry = s?.expiryDate ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _price,
      _amp,
      _received,
      _prevDebt,
      _cabinet,
      _fuse,
      _notes
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  double get _sub => _d(_price) * _d(_amp);
  double get _remaining => _sub - _d(_received);
  double get _debt => _d(_prevDebt) + (_remaining > 0 ? _remaining : 0);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        _expiry.isNotEmpty ? (DateTime.tryParse(_expiry) ?? now) : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _expiry =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = Subscriber(
      id: widget.subscriber?.id,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      category: _category,
      pricePerAmpere: _d(_price),
      amperes: _d(_amp),
      amountReceived: _d(_received),
      previousDebt: _d(_prevDebt),
      cabinet: _cabinet.text.trim(),
      fuse: _fuse.text.trim(),
      expiryDate: _expiry,
      notes: _notes.text.trim(),
    );
    if (s.id == null) {
      await DatabaseHelper.instance.insert(s);
    } else {
      await DatabaseHelper.instance.update(s);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final id = widget.subscriber?.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المشترك'),
        content: const Text('هل أنت متأكد من حذف هذا المشترك؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل مشترك' : 'مشترك جديد'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEdit)
            IconButton(
                onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'اسم المشترك',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null),
            _field(_phone, 'رقم الهاتف', type: TextInputType.phone),
            _categoryField(),
            _field(_price, 'سعر الأمبير (د.ع)',
                type: TextInputType.number, recalc: true),
            _field(_amp, 'عدد الأمبيرات',
                type: TextInputType.number, recalc: true),
            _field(_received, 'المبلغ الواصل (د.ع)',
                type: TextInputType.number, recalc: true),
            _field(_prevDebt, 'ديون سابقة (د.ع)',
                type: TextInputType.number, recalc: true),
            Row(children: [
              Expanded(child: _field(_cabinet, 'رقم الكابينة')),
              const SizedBox(width: 12),
              Expanded(child: _field(_fuse, 'رقم الجوزة')),
            ]),
            _dateField(),
            _field(_notes, 'ملاحظات', maxLines: 2),
            const SizedBox(height: 8),
            _summaryBox(),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: kPrimary,
                  minimumSize: const Size.fromHeight(48)),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? type,
      bool recalc = false,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        onChanged: recalc ? (_) => setState(() {}) : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _categoryField() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(
            labelText: 'فئة الاشتراك',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'عادي', child: Text('عادي')),
            DropdownMenuItem(value: 'ذهبي', child: Text('ذهبي')),
          ],
          onChanged: (v) => setState(() => _category = v ?? 'عادي'),
        ),
      );

  Widget _dateField() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: _pickDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'تاريخ الانتهاء',
              border: OutlineInputBorder(),
              isDense: true,
              suffixIcon: Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(_expiry.isEmpty ? 'اختر التاريخ' : _expiry),
          ),
        ),
      );

  Widget _summaryBox() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            _row('مبلغ الاشتراك', money(_sub)),
            _row('المبلغ المتبقي', money(_remaining)),
            _row('مجموع الديون', money(_debt), bold: true),
          ],
        ),
      );

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            Text(value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: bold ? kPrimary : null)),
          ],
        ),
      );
}
