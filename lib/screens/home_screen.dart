import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/salawat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_pattern_painter.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _service = SalawatService.instance;
  late final AnimationController _pulseController;
  bool _sending = false;
  final _customAmountController = TextEditingController();
  bool _sendingCustomAmount = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _onTapCounter() async {
    if (_sending) return;
    setState(() => _sending = true);
    _pulseController.forward().then((_) => _pulseController.reverse());
    try {
      await _service.incrementSalawat();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر الحفظ الآن، حاول مرة أخرى ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _onAddCustomAmount() async {
    if (_sendingCustomAmount) return;
    final amount = int.tryParse(_customAmountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقمًا صحيحًا أكبر من صفر')),
      );
      return;
    }
    if (amount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكنك إدخال أكثر من ١٠٠ دفعة واحدة، قسّم العدد على عدة دفعات',
          ),
        ),
      );
      return;
    }
    setState(() => _sendingCustomAmount = true);
    try {
      await _service.incrementSalawat(amount: amount);
      _customAmountController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر الحفظ الآن، حاول مرة أخرى ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingCustomAmount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== الخلفية: لوحة المسجد النبوي الأصلية =====
          Image.asset(
            'assets/images/masjid_nabawi.jpg',
            fit: BoxFit.cover,
          ),
          // تعتيم خفيف لتحسين وضوح النصوص فوق الصورة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.86),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ===== إطار زخرفي هندسي مرسوم بالكود =====
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  color: AppColors.gold.withOpacity(0.14),
                ),
              ),
            ),
          ),

          // ===== المحتوى =====
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.domeGreenDark,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.domeGreenDark.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // زر العدّاد الرئيسي
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1 + _pulseController.value;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GestureDetector(
                      onTap: _onTapCounter,
                      child: Container(
                        width: 168,
                        height: 168,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.domeGreen,
                              AppColors.domeGreenDark,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.domeGreen.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: AppColors.rose,
                                size: 30,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'صلِّ الآن',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // إضافة عدد مخصص دفعة واحدة (مثلاً ١٠٠)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 3,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'أدخل عددًا مثلاً ١٠٠ (الحد الأقصى ١٠٠)',
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.85),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.gold.withOpacity(0.6),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _onAddCustomAmount(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            _sendingCustomAmount ? null : _onAddCustomAmount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.domeGreenDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('إضافة'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // بطاقتا الإحصائيات: الشخصي + الإجمالي العام
                  StreamBuilder<int>(
                    stream: _service.personalCountStream(),
                    initialData: _service.cachedLocalCount,
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'عددك أنت',
                        value: snapshot.data ?? 0,
                        icon: Icons.person_outline,
                        accent: AppColors.domeGreen,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<int>(
                    stream: _service.globalTotalStream(),
                    initialData: 0,
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'إجمالي كل المستخدمين',
                        value: snapshot.data ?? 0,
                        icon: Icons.groups_outlined,
                        accent: AppColors.roseDeep,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'كل ضغطة تُضاف مباشرة لعدّادك ولعدّاد الجميع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.ink.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
