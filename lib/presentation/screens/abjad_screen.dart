import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/abjad_provider.dart';
import '../widgets/common/loading_indicator.dart';

/// =============================================================================
/// AbjadCalculatorScreen - شاشة حاسبة الجُمَّل
/// =============================================================================

class AbjadCalculatorScreen extends StatefulWidget {
  const AbjadCalculatorScreen({super.key});

  @override
  State<AbjadCalculatorScreen> createState() => _AbjadCalculatorScreenState();
}

class _AbjadCalculatorScreenState extends State<AbjadCalculatorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<AbjadProvider>().calculateAbjad(text);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('حاسبة الجُمَّل'),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الإدخال
            _buildInputCard(),
            const SizedBox(height: 24),
            // بطاقة النتائج
            Consumer<AbjadProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                final result = provider.lastResult;
                if (result == null) {
                  return _buildEmptyState();
                }

                return _buildResultsCard(result);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primaryGold, size: 24),
              SizedBox(width: 8),
              Text(
                'أدخل النص',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textDirection: TextDirection.rtl,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: AppColors.primaryNavy,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب النص هنا...',
              hintStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'احسب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calculate,
              size: 48,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اكتب نصاً لحساب جملته',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'نتائج الجمل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // القيم الأساسية
          _buildResultRow('الجمل الكبير', result.kabir.toString(), AppColors.primaryNavy),
          const Divider(height: 24),
          _buildResultRow('الجمل الصغير', result.saghir.toString(), AppColors.primaryGold),
          const Divider(height: 24),
          _buildResultRow('الجمل الأوسط', result.wasat.toString(), Colors.purple),
          const SizedBox(height: 24),
          // العنصر والكوكب
          Row(
            children: [
              Expanded(
                child: _buildElementCard(result),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // البرج
          _buildZodiacCard(result),
          const SizedBox(height: 16),
          // الاسم الإلهي
          _buildDivineNameCard(result),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildElementCard(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.1),
            AppColors.primaryGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(
                _getElementIcon(result.element),
                size: 32,
                color: _getElementColor(result.element),
              ),
              const SizedBox(height: 4),
              Text(
                'العنصر',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                result.element,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.primaryNavy.withOpacity(0.2),
          ),
          Column(
            children: [
              Icon(
                Icons.public,
                size: 32,
                color: AppColors.primaryGold,
              ),
              const SizedBox(height: 4),
              const Text(
                'الكوكب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                result.planet,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacCard(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            result.zodiac,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'البرج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                Icons.star,
                color: Colors.purple,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivineNameCard(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            result.divineName,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الاسم الإلهي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.primaryNavyDark,
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryNavy,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getElementIcon(String element) {
    switch (element) {
      case 'نار':
        return Icons.local_fire_department;
      case 'ماء':
        return Icons.water_drop;
      case 'تراب':
        return Icons.landscape;
      case 'هواء':
        return Icons.air;
      case 'روح':
        return Icons.cloud;
      default:
        return Icons.circle;
    }
  }

  Color _getElementColor(String element) {
    switch (element) {
      case 'نار':
        return AppColors.elementFire;
      case 'ماء':
        return AppColors.elementWater;
      case 'تراب':
        return AppColors.elementEarth;
      case 'هواء':
        return AppColors.elementAir;
      case 'روح':
        return AppColors.elementSpirit;
      default:
        return AppColors.primaryNavy;
    }
  }
}