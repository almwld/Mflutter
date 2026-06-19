import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/abjad_geometry_painter.dart';
import '../../providers/sovereign_chat_provider.dart';

class NucleusScreen extends StatelessWidget {
  const NucleusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('نواة التدبر', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 200, child: CustomPaint(painter: AbjadGeometryPainter(abjadValue: 256, goldColor: AppColors.primaryGold))),
            SizedBox(height: 20),
            Consumer<SovereignChatProvider>(
              builder: (context, chat, _) {
                if (chat.isLoading) return CircularProgressIndicator(color: AppColors.primaryGold);
                return Expanded(child: SingleChildScrollView(child: Text(chat.insight.isEmpty ? 'اضغط لتوليد بصيرة' : chat.insight, style: TextStyle(color: Colors.white70, fontSize: 16))));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => context.read<SovereignChatProvider>().fetchInsight(query: 'اللَّهُ نُورُ السَّمَاوَاتِ وَالأَرْضِ', focus: 1.618, topography: 'mountains', abjad: 256),
        child: Icon(Icons.psychology, color: AppColors.primaryNavy),
      ),
    );
  }
}
