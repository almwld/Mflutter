import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../services/astronomy_calculations_service.dart';

/// Offline astronomy calculators; lunar phase values are approximate.
class AstronomyScreen extends StatefulWidget {
  const AstronomyScreen({super.key});
  @override
  State<AstronomyScreen> createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> {
  final _distance = TextEditingController(text: '1');
  final _axis = TextEditingController(text: '1');
  DateTime _date = DateTime.now();
  double _distanceAu = 1;
  double _semiMajorAxis = 1;
  String? _distanceError;
  String? _axisError;

  @override
  void dispose() { _distance.dispose(); _axis.dispose(); super.dispose(); }

  double _moonAge(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day, 12);
    final reference = DateTime.utc(2000, 1, 6, 18, 14);
    final elapsed = utc.difference(reference).inSeconds / 86400.0;
    return ((elapsed % 29.530588853) + 29.530588853) % 29.530588853;
  }

  String _phase(double age) {
    if (age < 1.85 || age >= 27.68) return 'محاق / قمر جديد تقريبًا';
    if (age < 5.53) return 'هلال متزايد';
    if (age < 9.22) return 'التربيع الأول تقريبًا';
    if (age < 12.91) return 'أحدب متزايد';
    if (age < 16.61) return 'بدر تقريبًا';
    if (age < 20.30) return 'أحدب متناقص';
    if (age < 23.99) return 'التربيع الأخير تقريبًا';
    return 'هلال متناقص';
  }

  String _emoji(double age) {
    if (age < 1.85 || age >= 27.68) return '🌑';
    if (age < 5.53) return '🌒';
    if (age < 9.22) return '🌓';
    if (age < 12.91) return '🌔';
    if (age < 16.61) return '🌕';
    if (age < 20.30) return '🌖';
    if (age < 23.99) return '🌗';
    return '🌘';
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime(1900), lastDate: DateTime(2200),
      helpText: 'اختر تاريخًا لحساب طور القمر التقريبي',
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final age = _moonAge(_date);
    final solar = AstronomyCalculationsService.solarCoordinates(
      DateTime.utc(_date.year, _date.month, _date.day, 12),
    );
    final illumination = (1 - math.cos(2 * math.pi * age / 29.530588853)) / 2;
    final years = math.sqrt(_semiMajorAxis * _semiMajorAxis * _semiMajorAxis);
    return Scaffold(
      appBar: AppBar(title: const Text('علم الفلك'), actions: [
        IconButton(tooltip: 'اختيار التاريخ', onPressed: _pickDate, icon: const Icon(Icons.calendar_month_rounded)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('مختبر فلكي محلي', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('أدوات حسابية تعليمية تعمل دون اتصال. لا تستخدم بيانات رصد مباشرة أو موقعًا جغرافيًا؛ لذلك لا تعرض مواقع لحظية للنجوم والكواكب أو أوقات شروق وغروب محلية.', textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            const SizedBox(height: 12),
            _fact(context, 'الوحدة الفلكية', 'متوسط المسافة بين الأرض والشمس ≈ 149.6 مليون كم'),
            _fact(context, 'السنة الضوئية', 'المسافة التي يقطعها الضوء في سنة ≈ 9.46 تريليون كم'),
            _fact(context, 'الشهر الاقتراني', 'متوسط دورة أطوار القمر ≈ 29.53 يومًا'),
          ],
        ))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('طور القمر التقريبي', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(child: Text(_emoji(age), style: const TextStyle(fontSize: 68))),
            Center(child: Text(_phase(age), style: theme.textTheme.titleLarge)),
            Center(child: Text('التاريخ: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}')),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: illumination, minHeight: 8),
            const SizedBox(height: 5),
            Text('إضاءة القرص التقريبية: ${(illumination * 100).round()}٪', textDirection: TextDirection.rtl),
            Align(alignment: AlignmentDirectional.centerStart, child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event), label: const Text('تغيير التاريخ'))),
            Text('تقدير مبني على دورة قمرية متوسطة ومرجع ثابت؛ قد يختلف عن الطور الفلكي الدقيق.', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65)), textDirection: TextDirection.rtl),
          ],
        ))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('إحداثيات الشمس التقريبية', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('اليوم المرجعي عند 12:00 UTC: ${solar.julianDay.toStringAsFixed(5)} يوم يولياني',
              textDirection: TextDirection.rtl),
            _fact(context, 'الطول الكسوفي الظاهري', '${solar.eclipticLongitudeDegrees.toStringAsFixed(3)}°'),
            _fact(context, 'المطلع المستقيم', '${solar.rightAscensionDegrees.toStringAsFixed(3)}°'),
            _fact(context, 'الميل السماوي', '${solar.declinationDegrees.toStringAsFixed(3)}°'),
            _fact(context, 'معادلة الزمن', '${solar.equationOfTimeMinutes.toStringAsFixed(2)} دقيقة'),
            const SizedBox(height: 5),
            Text('حساب شمسي منخفض الدقة للتعلم فقط؛ لا يصلح للملاحة أو توجيه التلسكوبات أو توقيت الكسوفات. مصدر الطريقة: معادلات شمسية تقريبية من عائلة NOAA/Meeus.',
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65))),
          ],
        ))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('زمن انتقال الضوء', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('أدخل المسافة عن الشمس بوحدات فلكية؛ يستخدم الحساب 8.316746 دقيقة لكل وحدة فلكية.', textDirection: TextDirection.rtl),
            const SizedBox(height: 10),
            TextField(controller: _distance, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'المسافة (AU)', errorText: _distanceError, border: const OutlineInputBorder()), onChanged: (value) {
              final parsed = double.tryParse(value);
              setState(() {
                if (parsed != null && parsed.isFinite && parsed >= 0 && parsed <= 100000) {
                  _distanceAu = parsed;
                  _distanceError = null;
                } else {
                  _distanceError = 'أدخل رقمًا من 0 إلى 100000.';
                }
              });
            }),
            const SizedBox(height: 8),
            if (_distanceError == null) Text(_distanceAu * 8.316746 >= 60
              ? 'زمن الضوء: ${(_distanceAu * 8.316746 / 60).toStringAsFixed(2)} ساعة تقريبًا'
              : 'زمن الضوء: ${(_distanceAu * 8.316746).toStringAsFixed(2)} دقيقة تقريبًا',
              style: theme.textTheme.titleMedium, textDirection: TextDirection.rtl),
          ],
        ))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('المدار وقانون كبلر الثالث', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('للأجرام التي تدور حول الشمس تقريبًا: الفترة بالسنوات الأرضية ≈ الجذر التربيعي لمكعب نصف المحور الأكبر بوحدة AU.', textDirection: TextDirection.rtl),
            const SizedBox(height: 10),
            TextField(controller: _axis, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'نصف المحور الأكبر (AU)', errorText: _axisError, border: const OutlineInputBorder()), onChanged: (value) {
              final parsed = double.tryParse(value);
              setState(() {
                if (parsed != null && parsed.isFinite && parsed > 0 && parsed <= 100000) {
                  _semiMajorAxis = parsed;
                  _axisError = null;
                } else {
                  _axisError = 'أدخل رقمًا أكبر من صفر وحتى 100000.';
                }
              });
            }),
            const SizedBox(height: 8),
            if (_axisError == null) Text('الفترة المدارية النظرية: ${years.toStringAsFixed(3)} سنة أرضية', style: theme.textTheme.titleMedium, textDirection: TextDirection.rtl),
            Text('تقريب لجسم كتلته مهملة مقارنة بالشمس ومداره حولها؛ لا يشمل اضطرابات الكواكب.', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65)), textDirection: TextDirection.rtl),
          ],
        ))),
      ]),
    );
  }

  Widget _fact(BuildContext context, String title, String detail) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(detail, textDirection: TextDirection.rtl)),
      const SizedBox(width: 10),
      Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
    ]),
  );
}
