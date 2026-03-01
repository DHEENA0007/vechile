import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class OwnerRevenueScreen extends StatefulWidget {
  const OwnerRevenueScreen({super.key});

  @override
  State<OwnerRevenueScreen> createState() => _OwnerRevenueScreenState();
}

class _OwnerRevenueScreenState extends State<OwnerRevenueScreen> {
  Map<String, dynamic>? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/bookings/revenue/');
      setState(() {
        _report = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Revenue Report',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.bgDark.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 150,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.08),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReport,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.bgCard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Revenue Cards
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Daily Revenue',
                                  value: '₹${_report?['daily_revenue'] ?? '0'}',
                                  icon: Icons.today_rounded,
                                  color: AppTheme.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Monthly Revenue',
                                  value:
                                      '₹${_report?['monthly_revenue'] ?? '0'}',
                                  icon: Icons.calendar_month_rounded,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                          // Service-wise Revenue
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Service-wise Revenue',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 16),

                          if ((_report?['service_revenue'] as List?)?.isEmpty ??
                              true)
                            GlassCard(
                              padding: const EdgeInsets.all(32),
                              child: const Center(
                                child: Text(
                                  'No revenue data yet',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms)
                          else
                            ...(_report!['service_revenue'] as List)
                                .asMap()
                                .entries
                                .map((entry) {
                                  final item = entry.value;
                                  return GlassCard(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accent
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: AppTheme.accent
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.build_rounded,
                                                color: AppTheme.accent,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['service'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppTheme.textPrimary,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    item['center'] ?? '',
                                                    style: const TextStyle(
                                                      color: AppTheme.textMuted,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '₹${item['revenue'] ?? '0'}',
                                              style: const TextStyle(
                                                color: AppTheme.accent,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                shadows: [
                                                  Shadow(
                                                    color: AppTheme.accent,
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: (400 + entry.key * 80).ms)
                                      .slideX(begin: 0.05);
                                }),

                          // Mechanic Productivity
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Mechanic Productivity',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 16),

                          if ((_report?['mechanic_productivity'] as List?)
                                  ?.isEmpty ??
                              true)
                            GlassCard(
                              padding: const EdgeInsets.all(32),
                              child: const Center(
                                child: Text(
                                  'No mechanic data',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 600.ms)
                          else
                            ...(_report!['mechanic_productivity'] as List)
                                .asMap()
                                .entries
                                .map((entry) {
                                  final mech = entry.value;
                                  return GlassCard(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppTheme.primary,
                                                    AppTheme.primaryDark,
                                                  ],
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    AppTheme.bgCard,
                                                child: Text(
                                                  (mech['name'] ?? 'M')[0]
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                mech['name'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: AppTheme
                                                                .success,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${mech['completed_jobs'] ?? 0} done',
                                                      style: const TextStyle(
                                                        color: AppTheme.success,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: AppTheme
                                                                .warning,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${mech['active_jobs'] ?? 0} active',
                                                      style: const TextStyle(
                                                        color: AppTheme.warning,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: (600 + entry.key * 80).ms)
                                      .slideX(begin: 0.05);
                                }),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
