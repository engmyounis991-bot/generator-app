import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/subscriber.dart';
import '../utils/formatters.dart';
import '../utils/whatsapp.dart';
import 'subscriber_form_screen.dart';

const Color kPrimary = Color(0xFF1A3A6B);
const Color kGold = Color(0xFFCBA135);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subscriber> _all = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await DatabaseHelper.instance.getAll();
    if (!mounted) return;
    setState(() {
      _all = data;
      _loading = false;
    });
  }

  List<Subscriber> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return _all;
    return _all
        .where((s) =>
            s.name.contains(q) ||
            s.phone.contains(q) ||
            s.cabinet.contains(q) ||
            s.fuse.contains(q))
        .toList();
  }

  double get _totalDebt => _all.fold(0.0, (sum, s) => sum + s.totalDebt);

  Future<void> _openForm([Subscriber? s]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SubscriberFormScreen(subscriber: s)),
    );
    if (changed == true) _load();
  }

  Future<void> _share(Subscriber s) async {
    if (s.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رقم هاتف لهذا المشترك')),
      );
      return;
    }
    final ok = await sendWhatsApp(s);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح واتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('اشتراكات المولدة'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('مشترك جديد'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _summary(),
                _searchBar(),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Text('لا يوجد مشتركون بعد — أضف أول مشترك'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: list.length,
                          itemBuilder: (_, i) => _card(list[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _summary() => Container(
        width: double.infinity,
        color: kPrimary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _stat('المشتركون', _all.length.toString()),
            const SizedBox(width: 12),
            _stat('مجموع الديون', money(_totalDebt)),
          ],
        ),
      );

  Widget _stat(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'بحث بالاسم أو الهاتف أو الكابينة',
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      );

  Widget _card(Subscriber s) {
    final hasDebt = s.totalDebt > 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => _openForm(s),
        title: Row(
          children: [
            Expanded(
              child: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: s.category == 'ذهبي' ? kGold : Colors.blueGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(s.category,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('أمبير: ${amp(s.amperes)}  •  كابينة: '
                '${s.cabinet.isEmpty ? '-' : s.cabinet} / جوزة: '
                '${s.fuse.isEmpty ? '-' : s.fuse}'),
            Text(
              hasDebt ? 'الدين: ${money(s.totalDebt)}' : 'مسدّد بالكامل',
              style: TextStyle(
                color: hasDebt ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.send, color: Color(0xFF25D366)),
          tooltip: 'إرسال الوصل عبر واتساب',
          onPressed: () => _share(s),
        ),
      ),
    );
  }
}
