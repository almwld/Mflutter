import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../utils/abjad_constants.dart';

class DivineNamesScreen extends StatelessWidget {
  const DivineNamesScreen({super.key});

  static const Map<String, String> _descriptions = {
    'الله': 'المعبود بحق',
    'الرحمن': 'واسع الرحمة',
    'الرحيم': 'دائم الرحمة والإحسان',
    'الملك': 'المالك المتصرف',
    'القدوس': 'المنزه عن النقص',
    'السلام': 'المنزه عن العيب والآفة',
    'المؤمن': 'واهب الأمن ومصدق وعده',
    'المهيمن': 'الرقيب الحافظ',
    'العزيز': 'الغالب الذي لا يُقهر',
    'الجبار': 'العالي وجابر الضعف',
    'المتكبر': 'المتعالي عن صفات النقص',
    'الخالق': 'مقدر الخلق وموجده',
    'البارئ': 'المنشئ للخلق',
    'المصور': 'الذي أعطى كل شيء صورته',
    'الغفار': 'كثير المغفرة',
    'القهار': 'الغالب على كل شيء',
    'الوهاب': 'كثير العطاء',
    'الرزاق': 'خالق الأرزاق وموصلها',
    'الفتاح': 'الحاكم والفاتح لأبواب الخير',
    'العليم': 'المحيط علمه بكل شيء',
    'القابض': 'يقبض بحكمة',
    'الباسط': 'يبسط الرزق والرحمة',
    'الخافض': 'يخفض بحكمة',
    'الرافع': 'يرفع بحكمة',
    'المعز': 'مانح العزة',
    'المذل': 'يخفض المتكبرين بعدل',
    'السميع': 'يسمع كل شيء',
    'البصير': 'لا يخفى عليه شيء',
    'الحكم': 'الحاكم بالحق',
    'العدل': 'المنزه عن الظلم',
    'اللطيف': 'البر بعباده والعالم بالدقائق',
    'الخبير': 'العالم ببواطن الأمور',
    'الحليم': 'لا يعجل بالعقوبة',
    'العظيم': 'ذو العظمة',
    'الغفور': 'واسع المغفرة',
    'الشكور': 'يثيب على العمل',
    'العلي': 'المتعالي',
    'الكبير': 'العظيم القدر',
    'الحفيظ': 'الحافظ لكل شيء',
    'المقيت': 'المتكفل بالأقوات',
    'الحسيب': 'الكافي والمحاسب',
    'الجليل': 'ذو الجلال',
    'الكريم': 'كثير الخير والعطاء',
    'الرقيب': 'المطلع الحافظ',
    'المجيب': 'مجيب الدعاء',
    'الواسع': 'واسع الفضل والعلم',
    'الحكيم': 'يضع الأمور مواضعها',
    'الودود': 'كثير المحبة لعباده الصالحين',
    'المجيد': 'عظيم المجد والكرم',
    'الباعث': 'باعث الخلق',
    'الشهيد': 'لا يغيب عنه شيء',
    'الحق': 'الثابت الذي لا ريب فيه',
    'الوكيل': 'الكافي لمن توكل عليه',
    'القوي': 'كامل القوة',
    'المتين': 'شديد القوة',
    'الولي': 'المتولي لنصرة عباده',
    'الحميد': 'المستحق للحمد',
    'المحصي': 'المحيط بعدد الأشياء',
    'المبدئ': 'يبدأ الخلق',
    'المعيد': 'يعيد الخلق',
    'المحيي': 'واهب الحياة',
    'المميت': 'مقدر الموت',
    'الحي': 'كامل الحياة',
    'القيوم': 'القائم بنفسه والمدبر لخلقه',
    'الواجد': 'الذي لا يعوزه شيء',
    'الماجد': 'عظيم الشرف والكرم',
    'الواحد': 'المتفرد',
    'الصمد': 'المقصود في الحوائج',
    'القادر': 'ذو القدرة',
    'المقتدر': 'تام القدرة',
    'المقدم': 'يقدم ما يشاء بحكمة',
    'المؤخر': 'يؤخر ما يشاء بحكمة',
    'الأول': 'ليس قبله شيء',
    'الآخر': 'ليس بعده شيء',
    'الظاهر': 'العالي بآياته',
    'الباطن': 'المحيط بكل شيء',
    'الوالي': 'المتولي تدبير الخلق',
    'المتعالي': 'المنزه عن صفات النقص',
    'البر': 'كثير الإحسان',
    'التواب': 'يقبل التوبة',
    'المنتقم': 'يجازي بالعدل',
    'العفو': 'كثير العفو',
    'الرؤوف': 'شديد الرحمة',
    'مالك الملك': 'مالك الملك كله',
    'ذو الجلال والإكرام': 'صاحب العظمة والكرم',
    'المقسط': 'العادل',
    'الجامع': 'يجمع الخلق للحساب',
    'الغني': 'المستغني عن كل شيء',
    'المغني': 'يغني من يشاء',
    'المانع': 'يمنع بحكمة',
    'الضار': 'لا يقع شيء إلا بمشيئته',
    'النافع': 'بيده النفع',
    'النور': 'منور السماوات والأرض',
    'الهادي': 'يهدي إلى الصواب',
    'البديع': 'المبدع بلا مثال سابق',
    'الباقي': 'الدائم',
    'الوارث': 'الباقي بعد فناء الخلق',
    'الرشيد': 'الهادي إلى الرشد',
    'الصبور': 'لا يعجل بالعقوبة',
  };

  @override
  Widget build(BuildContext context) {
    final names = AbjadConstants.divineNames;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'الأسماء الحسنى',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold.withOpacity(.25)),
            ),
            child: const Text(
              'تعرض الشاشة قائمة شائعة من الأسماء الحسنى؛ قد تختلف بعض القوائم في ترتيب بعض الأسماء أو عدّها. المعاني مختصرة للتعريف وليست تفسيرًا جامعًا.',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: names.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) {
                final name = names[index];
                return Card(
                  color: AppColors.primaryNavy.withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 17,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _descriptions[name] ?? 'اسم في القائمة المتداولة',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
