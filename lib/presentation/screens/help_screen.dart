import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _sections = <(IconData, String, String)>[
    (Icons.dashboard_outlined, 'التنقل الرئيسي', 'استخدم الشريط السفلي للوصول إلى المصحف والبحث والآية اليومية والمحادثة. تجمع صفحة «المزيد» بقية الأدوات والواجهات.'),
    (Icons.menu_book_outlined, 'قراءة القرآن', 'اختر السورة من الفهرس، وانتقل بين الآيات أو صفحات المصحف. النص المعروض يأتي من الأصول المحلية المضمّنة، ولا ينبغي تعديل النص القرآني بواسطة التوليد الآلي.'),
    (Icons.format_list_numbered, 'فهرس السور والصفحات', 'استخدم مرجع السورة والآية للتنقل إلى موضع محدد. إذا لم يتوفر المرجع في البيانات المحلية، تعرض الواجهة رسالة بدل إنشاء آية بديلة.'),
    (Icons.record_voice_over_outlined, 'التلاوة الصوتية', 'اختر السورة ثم استخدم أدوات التشغيل والإيقاف المؤقت والاستئناف. يتطلب تشغيل الصوت اتصالًا صالحًا بالمصدر الصوتي وإتاحة خدمة الصوت على الجهاز.'),
    (Icons.bookmark_border_rounded, 'العلامات والمفضلة', 'احفظ مواضع الآيات للعودة إليها لاحقًا. تستخدم شاشة علامات المصحف والمفضلة مخزن العلامات المحلي المشترك لتجنب نسخ متعارضة.'),
    (Icons.search_rounded, 'البحث المتقدم', 'ابحث بكلمة أو عبارة أو مرجع آية. قد يوحّد البحث بعض الحروف ويزيل التشكيل للمطابقة؛ يبقى نص الآية الأصلي مستقلًا عن نص البحث المطبّع.'),
    (Icons.chat_bubble_outline_rounded, 'المحادثة والوكلاء', 'تختلف نتائج الاسترجاع المحلي عن إجابة نموذج توليدي. راجع المصادر والحالة لكل خطوة، ولا تعتبر وجود وكيل في السجل دليلًا على أنه يعمل حاليًا.'),
    (Icons.memory_rounded, 'النواة والنموذج المحلي', 'استيراد ملف GGUF لا يعني أنه أصبح جاهزًا للاستدلال؛ يجب أن ينجح تحميله في وقت التشغيل. لا تُرسل الأسئلة إلى خدمة بعيدة ضمن مسار النموذج المحلي.'),
    (Icons.tune_rounded, 'التخصيص', 'تتيح الواجهة ضبط الخيارات التي تدعمها الخدمات المحلية. لا يظهر الخيار على أنه مطبّق ما لم تحفظ الخدمة قيمته بنجاح.'),
    (Icons.model_training_outlined, 'التدريب', 'لا تُعلن الواجهة عن تدريب أوزان نموذج GGUF. أي تدريب للمصنّف المحلي يحتاج بيانات مصنّفة ومحركًا متوافقًا، وتُعرض القيود عندما لا تتوفر هذه المتطلبات.'),
    (Icons.compare_arrows_rounded, 'مقارنة الآيات والإحصاء', 'تستخدم المقارنة نصوص المصحف المحلي وتعرض التقاطع اللفظي وفق قواعد تطبيع معلنة. الأعداد النصية لا تثبت بمفردها تفسيرًا أو ادعاءً دينيًا.'),
    (Icons.insights_outlined, 'إحصائيات القراءة', 'تُحسب المؤشرات من نشاط القراءة المسجل محليًا. إذا لم توجد بيانات سابقة، فقد تبدأ القيم من الصفر؛ لا تمثل القيم غير المسجلة نشاطًا مؤكدًا.'),
    (Icons.person_outline_rounded, 'الملف الشخصي والإنجازات', 'يعرض الملف بيانات الملف النشط والإنجازات التي تملك آلية تتبع. قد تظهر بعض الإنجازات على أنها غير موصولة إذا لم يكن قياسها مدعومًا.'),
    (Icons.hub_outlined, 'مركز السيادة والاتصال القريب', 'تتطلب ميزات اكتشاف الأجهزة والاتصال نظيرًا إلى نظير أذونات النظام ودعم الجهاز. لا يعني بدء الاكتشاف أن جهازًا آخر قد اتصل بالفعل.'),
    (Icons.inventory_2_outlined, 'الخدمات والسجلات المحلية', 'توضح الواجهات ما يُحفظ على الجهاز. لا تفترض أن الحفظ المحلي مزامنة سحابية، أو أن المذكرات والتذكيرات تمثل تنبؤات أو حقائق مؤكدة.'),
    (Icons.settings_outlined, 'الإعدادات والخصوصية', 'راجع إعدادات التطبيق وأذونات الجهاز قبل استخدام الميزات الحساسة. إذا فشل تحميل البيانات، استخدم إعادة المحاولة الظاهرة أو عد إلى الشاشة السابقة.'),
    (Icons.info_outline_rounded, 'حول مُدَبِّر', 'تعرض صفحة «حول» معلومات التطبيق. تعتمد الوظائف المتاحة على الأصول والخدمات الموجودة في النسخة المثبتة، وقد تتطلب بعض الميزات إعدادًا إضافيًا.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('المساعدة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline_rounded, color: colors.primary, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('دليل استخدام مُدَبِّر',
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          'شرح الواجهات وحدود الوظائف الحالية. عند غياب مصدر أو خدمة، يجب إظهار ذلك بوضوح بدل عرض نتيجة غير متحققة.',
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(section.$1, color: colors.primary, size: 25),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.$2,
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                section.$3,
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface.withOpacity(.78),
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
