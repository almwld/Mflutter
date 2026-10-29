import 'package:flutter/material.dart';

/// Historical overview of the twelve signs used in Western tropical astrology.
/// Date ranges are conventional approximations, not astronomical calculations.
class ZodiacScreen extends StatefulWidget {
  const ZodiacScreen({super.key});
  @override
  State<ZodiacScreen> createState() => _ZodiacScreenState();
}

class _ZodiacScreenState extends State<ZodiacScreen> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  _ZodiacSign? _selected;

  static const List<_ZodiacSign> _signs = [
    _ZodiacSign(name: 'الحمل', symbol: '♈', element: 'النار', quality: 'أساسي', range: '21 مارس – 19 أبريل', startMonth: 3, startDay: 21, endMonth: 4, endDay: 19, color: Color(0xFFD96C55), note: 'أول الأبراج في الترتيب الاصطلاحي الشائع للأبراج الاستوائية.'),
    _ZodiacSign(name: 'الثور', symbol: '♉', element: 'التراب', quality: 'ثابت', range: '20 أبريل – 20 مايو', startMonth: 4, startDay: 20, endMonth: 5, endDay: 20, color: Color(0xFF7A9B68), note: 'يرتبط في التصنيف التقليدي بعنصر التراب والجودة الثابتة.'),
    _ZodiacSign(name: 'الجوزاء', symbol: '♊', element: 'الهواء', quality: 'متغير', range: '21 مايو – 20 يونيو', startMonth: 5, startDay: 21, endMonth: 6, endDay: 20, color: Color(0xFFB5A36B), note: 'يأتي ثالثًا في التسلسل الاصطلاحي للأبراج الاستوائية.'),
    _ZodiacSign(name: 'السرطان', symbol: '♋', element: 'الماء', quality: 'أساسي', range: '21 يونيو – 22 يوليو', startMonth: 6, startDay: 21, endMonth: 7, endDay: 22, color: Color(0xFF6997C7), note: 'يرتبط تقليديًا بعنصر الماء والجودة الأساسية.'),
    _ZodiacSign(name: 'الأسد', symbol: '♌', element: 'النار', quality: 'ثابت', range: '23 يوليو – 22 أغسطس', startMonth: 7, startDay: 23, endMonth: 8, endDay: 22, color: Color(0xFFD99C48), note: 'خامس الرموز في الترتيب الغربي الشائع.'),
    _ZodiacSign(name: 'العذراء', symbol: '♍', element: 'التراب', quality: 'متغير', range: '23 أغسطس – 22 سبتمبر', startMonth: 8, startDay: 23, endMonth: 9, endDay: 22, color: Color(0xFF8A9A79), note: 'يرتبط في التصنيف التقليدي بعنصر التراب والجودة المتغيرة.'),
    _ZodiacSign(name: 'الميزان', symbol: '♎', element: 'الهواء', quality: 'أساسي', range: '23 سبتمبر – 22 أكتوبر', startMonth: 9, startDay: 23, endMonth: 10, endDay: 22, color: Color(0xFFB69AC9), note: 'سابع الرموز، ويصوَّر تقليديًا بميزان.'),
    _ZodiacSign(name: 'العقرب', symbol: '♏', element: 'الماء', quality: 'ثابت', range: '23 أكتوبر – 21 نوفمبر', startMonth: 10, startDay: 23, endMonth: 11, endDay: 21, color: Color(0xFF9B6B85), note: 'يرتبط تقليديًا بعنصر الماء والجودة الثابتة.'),
    _ZodiacSign(name: 'القوس', symbol: '♐', element: 'النار', quality: 'متغير', range: '22 نوفمبر – 21 ديسمبر', startMonth: 11, startDay: 22, endMonth: 12, endDay: 21, color: Color(0xFFD17C55), note: 'تاسع الرموز في الترتيب الشائع للأبراج.'),
    _ZodiacSign(name: 'الجدي', symbol: '♑', element: 'التراب', quality: 'أساسي', range: '22 ديسمبر – 19 يناير', startMonth: 12, startDay: 22, endMonth: 1, endDay: 19, color: Color(0xFF82928D), note: 'يمتد نطاقه التقليدي عبر نهاية السنة وبدايتها.'),
    _ZodiacSign(name: 'الدلو', symbol: '♒', element: 'الهواء', quality: 'ثابت', range: '20 يناير – 18 فبراير', startMonth: 1, startDay: 20, endMonth: 2, endDay: 18, color: Color(0xFF5EA8B8), note: 'يرتبط تقليديًا بعنصر الهواء والجودة الثابتة.'),
    _ZodiacSign(name: 'الحوت', symbol: '♓', element: 'الماء', quality: 'متغير', range: '19 فبراير – 20 مارس', startMonth: 2, startDay: 19, endMonth: 3, endDay: 20, color: Color(0xFF778FD1), note: 'آخر الرموز في الترتيب الاصطلاحي الشائع.'),
  ];

  _ZodiacSign _forDate(DateTime date) {
    // Compare month/day tuples; this handles the Capricorn year boundary.
    for (final sign in _signs) {
      final afterStart = date.month > sign.startMonth ||
          (date.month == sign.startMonth && date.day >= sign.startDay);
      final beforeEnd = date.month < sign.endMonth ||
          (date.month == sign.endMonth && date.day <= sign.endDay);
      if (sign.startMonth > sign.endMonth) {
        if (afterStart || beforeEnd) return sign;
      } else if (afterStart && beforeEnd) {
        return sign;
      }
    }
    return _signs.last;
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context, initialDate: _birthDate,
      firstDate: DateTime(1900), lastDate: DateTime.now(),
      helpText: 'اختر تاريخ الميلاد',
    );
    if (value != null && mounted) setState(() {
      _birthDate = value;
      _selected = _forDate(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final birthSign = _forDate(_birthDate);
    final current = _selected ?? birthSign;
    final elements = <String, Color>{
      'النار': const Color(0xFFD96C55),
      'التراب': const Color(0xFF7A9B68),
      'الهواء': const Color(0xFF6D9FB5),
      'الماء': const Color(0xFF6997C7),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('علم الأبراج والرموز التاريخية')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('دليل الأبراج الاثني عشر', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('هذه الواجهة مرجع للتصنيفات والرموز المتداولة في تقاليد التنجيم الغربي. تواريخ الانتقال تقريبية وقد تختلف بحسب السنة والمنطقة الزمنية؛ ولا توجد أدلة علمية موثوقة على أن البرج يحدد الشخصية أو يتنبأ بالمستقبل.', textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_month_rounded), label: const Text('اختيار تاريخ الميلاد'))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: current.color.withOpacity(.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: current.color.withOpacity(.55))),
              child: Column(children: [
                Text(birthSign.symbol, style: TextStyle(fontSize: 42, color: birthSign.color)),
                Text(birthSign.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('${_birthDate.year}-${_birthDate.month.toString().padLeft(2, '0')}-${_birthDate.day.toString().padLeft(2, '0')} • ${birthSign.range}', textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('العنصر التقليدي: ${birthSign.element} • الجودة: ${birthSign.quality}', textAlign: TextAlign.center),
              ]),
            ),
          ],
        ))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _signs.map((sign) => SizedBox(
          width: (MediaQuery.sizeOf(context).width - 48) / (MediaQuery.sizeOf(context).width >= 700 ? 3 : 2),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: current.name == sign.name ? sign.color : colors.outlineVariant, width: current.name == sign.name ? 2 : 1)),
            child: InkWell(
              onTap: () => setState(() => _selected = sign),
              child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                Text(sign.symbol, style: TextStyle(fontSize: 32, color: sign.color)),
                Text(sign.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(sign.range, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                const SizedBox(height: 5),
                Chip(label: Text(sign.element), backgroundColor: elements[sign.element]?.withOpacity(.15)),
              ])),
            ),
          ),
        )).toList()),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('عن ${current.name}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(current.note, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            const SizedBox(height: 8),
            Text('العنصر: ${current.element} • الجودة: ${current.quality} • المدى الشائع: ${current.range}', textDirection: TextDirection.rtl),
            const SizedBox(height: 6),
            Text('الاختيار يعرض معلومات ثقافية عن الرمز فقط؛ ولا يستنتج سمات شخصية من تاريخ الميلاد.', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65)), textDirection: TextDirection.rtl),
          ],
        ))),
      ]),
    );
  }
}

class _ZodiacSign {
  final String name, symbol, element, quality, range, note;
  final int startMonth, startDay, endMonth, endDay;
  final Color color;
  const _ZodiacSign({required this.name, required this.symbol, required this.element, required this.quality, required this.range, required this.startMonth, required this.startDay, required this.endMonth, required this.endDay, required this.color, required this.note});
}
