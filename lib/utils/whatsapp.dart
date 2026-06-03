import 'package:url_launcher/url_launcher.dart';
import '../models/subscriber.dart';
import 'formatters.dart';

/// اسم صاحب المولدة الذي يظهر أسفل الوصل — غيّره حسب الحاجة
const String ownerName = 'Eng. Mohammed Younis Jassim';

String buildReceipt(Subscriber s) {
  final b = StringBuffer();
  b.writeln('🔌 وصل اشتراك المولدة');
  b.writeln('━━━━━━━━━━━━━━━');
  b.writeln('المشترك: ${s.name}');
  b.writeln('الفئة: ${s.category}');
  b.writeln('عدد الأمبيرات: ${amp(s.amperes)}');
  b.writeln('سعر الأمبير: ${money(s.pricePerAmpere)}');
  b.writeln('مبلغ الاشتراك: ${money(s.subscriptionAmount)}');
  b.writeln('الواصل: ${money(s.amountReceived)}');
  b.writeln('المتبقي: ${money(s.remaining)}');
  b.writeln('مجموع الديون: ${money(s.totalDebt)}');
  if (s.expiryDate.isNotEmpty) b.writeln('تاريخ الانتهاء: ${s.expiryDate}');
  if (s.cabinet.isNotEmpty || s.fuse.isNotEmpty) {
    b.writeln('الكابينة: ${s.cabinet.isEmpty ? '-' : s.cabinet}'
        ' / الجوزة: ${s.fuse.isEmpty ? '-' : s.fuse}');
  }
  if (s.notes.isNotEmpty) b.writeln('ملاحظات: ${s.notes}');
  b.writeln('━━━━━━━━━━━━━━━');
  b.writeln(ownerName);
  return b.toString();
}

/// يفتح محادثة واتساب للمشترك مع الوصل جاهزاً (بضغطة إرسال واحدة)
Future<bool> sendWhatsApp(Subscriber s) async {
  final phone = normalizePhone(s.phone);
  final text = Uri.encodeComponent(buildReceipt(s));
  final uri = Uri.parse('https://wa.me/$phone?text=$text');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
