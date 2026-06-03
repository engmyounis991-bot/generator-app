class Subscriber {
  final int? id;
  final String name; // اسم المشترك
  final String phone; // رقم الهاتف
  final String category; // فئة الاشتراك: عادي / ذهبي
  final double pricePerAmpere; // مبلغ الاشتراك لكل أمبير
  final double amperes; // عدد الأمبيرات
  final double amountReceived; // المبلغ الواصل
  final double previousDebt; // ديون سابقة
  final String cabinet; // رقم الكابينة
  final String fuse; // رقم الجوزة
  final String expiryDate; // تاريخ الانتهاء (yyyy-MM-dd)
  final String notes; // ملاحظات

  Subscriber({
    this.id,
    required this.name,
    this.phone = '',
    this.category = 'عادي',
    this.pricePerAmpere = 0,
    this.amperes = 0,
    this.amountReceived = 0,
    this.previousDebt = 0,
    this.cabinet = '',
    this.fuse = '',
    this.expiryDate = '',
    this.notes = '',
  });

  // الحسابات التلقائية
  double get subscriptionAmount => pricePerAmpere * amperes; // مبلغ الاشتراك
  double get remaining => subscriptionAmount - amountReceived; // المبلغ المتبقي
  double get totalDebt =>
      previousDebt + (remaining > 0 ? remaining : 0); // مجموع الديون

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'category': category,
        'pricePerAmpere': pricePerAmpere,
        'amperes': amperes,
        'amountReceived': amountReceived,
        'previousDebt': previousDebt,
        'cabinet': cabinet,
        'fuse': fuse,
        'expiryDate': expiryDate,
        'notes': notes,
      };

  factory Subscriber.fromMap(Map<String, dynamic> m) => Subscriber(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        category: (m['category'] ?? 'عادي') as String,
        pricePerAmpere: (m['pricePerAmpere'] ?? 0).toDouble(),
        amperes: (m['amperes'] ?? 0).toDouble(),
        amountReceived: (m['amountReceived'] ?? 0).toDouble(),
        previousDebt: (m['previousDebt'] ?? 0).toDouble(),
        cabinet: (m['cabinet'] ?? '') as String,
        fuse: (m['fuse'] ?? '') as String,
        expiryDate: (m['expiryDate'] ?? '') as String,
        notes: (m['notes'] ?? '') as String,
      );
}
