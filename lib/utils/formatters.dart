/// تنسيق المبالغ بفواصل الآلاف + إضافة "د.ع"
String money(double v) {
  final n = v.round();
  final neg = n < 0;
  final s = n.abs().toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write(',');
  }
  final formatted = buf.toString().split('').reversed.join();
  return '${neg ? '-' : ''}$formatted د.ع';
}

/// عرض الأرقام بدون أصفار عشرية غير ضرورية (15.0 -> 15)
String amp(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

/// تحويل الرقم العراقي المحلي إلى الصيغة الدولية لواتساب
/// مثال: 07701234567 -> 9647701234567
String normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('0')) {
    d = '964${d.substring(1)}';
  } else if (!d.startsWith('964') && d.length == 10) {
    d = '964$d';
  }
  return d;
}
