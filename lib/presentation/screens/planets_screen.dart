import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/planetary_catalog_service.dart';
import '../../services/achievements_service.dart';

/// Offline reference for Solar System bodies. Distances and physical values
/// are rounded educational averages, not live ephemeris data.
class PlanetsScreen extends StatefulWidget {
  const PlanetsScreen({super.key});

  @override
  State<PlanetsScreen> createState() => _PlanetsScreenState();
}

class _PlanetsScreenState extends State<PlanetsScreen> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _mass = TextEditingController(text: '70');
  String _filter = 'الكل';
  String _query = '';
  _CelestialBody? _selected = _bodies[3];

  static const List<_CelestialBody> _bodies = [
    _CelestialBody(name: 'الشمس', symbol: '☉', kind: 'نجم', distanceAu: 0, diameterKm: 1392700, gravity: 274, day: 'نحو 25 يومًا عند خط الاستواء', year: 'نحو 225–250 مليون سنة حول مركز المجرة', description: 'النجم المركزي للنظام الشمسي ومصدر معظم الضوء والحرارة التي تصل إلى الأرض.', color: Color(0xFFF4B942)),
    _CelestialBody(name: 'عطارد', symbol: '☿', kind: 'كوكب صخري', distanceAu: 0.387, diameterKm: 4879, gravity: 3.70, day: 'نحو 58.6 يومًا أرضيًا للدوران النجمي', year: '87.97 يومًا أرضيًا', description: 'أصغر كواكب النظام الشمسي وأقربها إلى الشمس؛ سطحه مليء بالفوهات وتفاوت حرارته كبير.', color: Color(0xFF9CA3AF)),
    _CelestialBody(name: 'الزهرة', symbol: '♀', kind: 'كوكب صخري', distanceAu: 0.723, diameterKm: 12104, gravity: 8.87, day: 'نحو 243 يومًا أرضيًا، ودورانه تراجعي', year: '224.7 يومًا أرضيًا', description: 'غلافه الجوي كثيف وغني بثاني أكسيد الكربون، وهو أشد كواكب النظام الشمسي حرارة على السطح.', color: Color(0xFFD7A86E)),
    _CelestialBody(name: 'الأرض', symbol: '⊕', kind: 'كوكب صخري', distanceAu: 1, diameterKm: 12742, gravity: 9.81, day: '23 ساعة و56 دقيقة تقريبًا للدوران النجمي', year: '365.256 يومًا', description: 'الكوكب المعروف بوجود حياة على سطحه، وله ماء سائل وفرة وغلاف جوي يدعم الحياة.', color: Color(0xFF3B82F6)),
    _CelestialBody(name: 'المريخ', symbol: '♂', kind: 'كوكب صخري', distanceAu: 1.524, diameterKm: 6779, gravity: 3.71, day: '24 ساعة و37 دقيقة تقريبًا', year: '687 يومًا أرضيًا', description: 'كوكب بارد ذو سطح غني بأكاسيد الحديد، وتوجد أدلة جيولوجية على أن الماء السائل جرى على سطحه قديمًا.', color: Color(0xFFDC6B4A)),
    _CelestialBody(name: 'المشتري', symbol: '♃', kind: 'عملاق غازي', distanceAu: 5.203, diameterKm: 139820, gravity: 24.79, day: 'نحو 9 ساعات و56 دقيقة', year: '11.86 سنة أرضية', description: 'أكبر كواكب النظام الشمسي، وله عواصف ضخمة ونظام من الحلقات وأقمار كثيرة.', color: Color(0xFFD6A77A)),
    _CelestialBody(name: 'زحل', symbol: '♄', kind: 'عملاق غازي', distanceAu: 9.537, diameterKm: 116460, gravity: 10.44, day: 'نحو 10 ساعات و33 دقيقة', year: '29.45 سنة أرضية', description: 'يشتهر بنظام حلقاته الواسع المكوّن أساسًا من جليد وجسيمات صخرية.', color: Color(0xFFE6C98E)),
    _CelestialBody(name: 'أورانوس', symbol: '⛢', kind: 'عملاق جليدي', distanceAu: 19.19, diameterKm: 50724, gravity: 8.69, day: 'نحو 17 ساعة و14 دقيقة', year: '84 سنة أرضية تقريبًا', description: 'عملاق جليدي يميل محور دورانه بشدة، لذلك تبدو فصوله طويلة وغير مألوفة.', color: Color(0xFF70C7D5)),
    _CelestialBody(name: 'نبتون', symbol: '♆', kind: 'عملاق جليدي', distanceAu: 30.07, diameterKm: 49244, gravity: 11.15, day: 'نحو 16 ساعة', year: '164.8 سنة أرضية', description: 'أبعد الكواكب الثمانية عن الشمس، ويشتهر برياح شديدة السرعة في غلافه الجوي.', color: Color(0xFF4569D4)),
    _CelestialBody(name: 'القمر', symbol: '☾', kind: 'قمر طبيعي', distanceAu: 1.0, diameterKm: 3475, gravity: 1.62, day: 'نحو 27.3 يومًا للدوران النجمي', year: 'يدور حول الأرض في نحو 27.3 يومًا', description: 'القمر الطبيعي للأرض؛ متوسط المسافة بين مركزيه ومركز الأرض نحو 384,400 كيلومتر.', color: Color(0xFFBFC7D5)),
  ];

  String _normalizeSearch(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  @override
  void initState() {
    super.initState();
    unawaited(AchievementsService.recordScienceExplored('planetary_science'));
  }

  @override
  void dispose() {
    _search.dispose();
    _mass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final query = _normalizeSearch(_query);
    final filtered = _bodies.where((body) {
      final categoryMatches = _filter == 'الكل' ||
          (_filter == 'الكواكب' && body.kind.startsWith('كوكب')) ||
          (_filter == 'الأقمار' && body.kind == 'قمر طبيعي') ||
          (_filter == 'النجوم' && body.kind == 'نجم');
      return categoryMatches &&
          (query.isEmpty ||
              _normalizeSearch(body.name).contains(query) ||
              _normalizeSearch(body.kind).contains(query) ||
              _normalizeSearch(body.description).contains(query));
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('علم الكواكب والنظام الشمسي'),
        actions: [
          IconButton(
            tooltip: 'مسح البحث',
            onPressed: () {
              _search.clear();
              setState(() => _query = '');
            },
            icon: const Icon(Icons.search_off_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('دليل فلكي تفاعلي', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'بيانات تعليمية محلية تقريبية عن الأجرام في النظام الشمسي. المسافات من الشمس متوسطات مدارية بوحدة فلكية، وليست مواقع لحظية. الارتباطات الرمزية التاريخية لا تعني أن الأجرام تتحكم في الشخصية أو المصير.',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    textDirection: TextDirection.rtl,
                    onChanged: (value) => setState(() => _query = _normalizeSearch(value)),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن جرم أو نوعه أو وصفه',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['الكل', 'الكواكب', 'الأقمار', 'النجوم'].map((filter) =>
                      ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('لا توجد أجرام مطابقة للبحث.')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.18,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final body = filtered[index];
                final selected = _selected?.name == body.name;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: selected ? body.color : colors.outlineVariant, width: selected ? 2 : 1),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selected = body),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(body.symbol, style: TextStyle(fontSize: 34, color: body.color)),
                          const SizedBox(height: 6),
                          Text(body.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Text(body.kind, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                          const SizedBox(height: 5),
                          Text(body.kind == 'قمر طبيعي' ? 'قمر الأرض' : (body.distanceAu == 0 ? 'مركز النظام' : '${body.distanceAu} AU'),
                            style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (_selected != null) ...[
            const SizedBox(height: 16),
            _detailsCard(context, _selected!),
          ],
          const SizedBox(height: 12),
          _weightCard(context),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context, _CelestialBody body) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: body.color.withOpacity(.18), child: Text(body.symbol, style: TextStyle(color: body.color, fontSize: 24))),
                const SizedBox(width: 10),
                Expanded(child: Text(body.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 10),
            Text(body.description, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            const Divider(height: 24),
            _metric(context, 'التصنيف', body.kind),
            _metric(context, 'القطر التقريبي', '${body.diameterKm.toStringAsFixed(0)} كم'),
            if (body.kind == 'قمر طبيعي')
              _metric(context, 'متوسط البعد عن الأرض', '384,400 كم تقريبًا')
            else
              _metric(context, 'متوسط البعد عن الشمس', body.distanceAu == 0 ? 'مركز النظام الشمسي' : '${body.distanceAu} وحدة فلكية'),
            _metric(context, 'الجاذبية السطحية التقريبية', '${body.gravity} م/ث²'),
            ..._catalogMetrics(context, body),
            _metric(context, 'الدوران', body.day),
            _metric(context, 'السنة / المدار', body.year),
            Text('الأرقام تقريبية ومناسبة للتعريف العام؛ تختلف بعض القيم باختلاف التعريف والمرجع.',
              textDirection: TextDirection.rtl, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65))),
          ],
        ),
      ),
    );
  }

  List<Widget> _catalogMetrics(BuildContext context, _CelestialBody body) {
    final matches = PlanetaryCatalogService.planets
        .where((planet) => planet.nameAr == body.name);
    if (matches.isEmpty) return const <Widget>[];
    final planet = matches.first;
    return <Widget>[
      _metric(context, 'الكتلة بالنسبة للأرض', planet.massInEarthMasses.toStringAsFixed(3)),
      _metric(context, 'الاستطالة المدارية', planet.orbitalEccentricity.toStringAsFixed(4)),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'مرجع البيانات المدارية: ${PlanetaryCatalogService.sourceName}. القيم مقربة وليست إحداثيات آنية.',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ];
  }

  Widget _weightCard(BuildContext context) {
    final theme = Theme.of(context);
    final body = _selected;
    final mass = double.tryParse(_mass.text.trim());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('حاسبة الوزن التقريبي', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('أدخل كتلتك بالكيلوغرام لحساب قوة الوزن النظرية: الكتلة × الجاذبية السطحية. الكتلة لا تتغير بتغير الجرم.',
              textDirection: TextDirection.rtl, textAlign: TextAlign.right),
            const SizedBox(height: 10),
            TextField(
              controller: _mass,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'الكتلة (كغ)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            if (mass != null &&
                mass.isFinite &&
                mass > 0 &&
                mass <= 1000000 &&
                body != null)
              Text('على ${body.name}: ${(mass * body.gravity).toStringAsFixed(2)} نيوتن تقريبًا',
                textDirection: TextDirection.rtl, style: theme.textTheme.titleMedium)
            else
              Text('أدخل كتلة موجبة وصالحة حتى مليون كغ.', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(value, textDirection: TextDirection.rtl)),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _CelestialBody {
  final String name;
  final String symbol;
  final String kind;
  final double distanceAu;
  final double diameterKm;
  final double gravity;
  final String day;
  final String year;
  final String description;
  final Color color;

  const _CelestialBody({
    required this.name,
    required this.symbol,
    required this.kind,
    required this.distanceAu,
    required this.diameterKm,
    required this.gravity,
    required this.day,
    required this.year,
    required this.description,
    required this.color,
  });
}
