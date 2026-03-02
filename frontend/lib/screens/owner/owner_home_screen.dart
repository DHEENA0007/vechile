import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import 'owner_bookings_screen.dart';
import 'owner_mechanics_screen.dart';
import 'owner_center_screen.dart';
import 'owner_revenue_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboard;
  bool _isLoading = true;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDashboard();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/services/owner/dashboard/');
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutExpo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardView(),
      const OwnerBookingsScreen(),
      const OwnerMechanicsScreen(),
      const OwnerRevenueScreen(),
      const OwnerCenterScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Dynamic mesh background
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
          
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms),

          // Main Pages
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTapped,
        backgroundColor: AppTheme.bgCard,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.engineering_rounded), label: 'Mechs'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Revenue'),
          NavigationDestination(icon: Icon(Icons.store_mall_directory_rounded), label: 'Centers'),
        ],
      ),
    );
  }


  Widget _buildDashboardView() {
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.bgDark,
                      AppTheme.primaryDark.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.store_rounded, color: AppTheme.primary, size: 28),
                            ),
                            const Spacer(),
                            _buildTopActionButton(Icons.notifications_none_rounded, () => _showNotifications(context)),
                            const SizedBox(width: 12),
                            _buildTopActionButton(Icons.logout_rounded, () => auth.logout()),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                        const SizedBox(height: 20),
                        Text(
                          'Owner Portal',
                          style: GoogleFonts.outfit(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome, ${auth.fullName}',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Structure 1: Horizontal Scrollable Featured Stats
                        SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildPremiumStatCard(
                                'Daily Revenue',
                                '₹${_dashboard?['daily_revenue'] ?? '0'}',
                                Icons.trending_up_rounded,
                                AppTheme.success,
                                "Today's earnings",
                              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                              const SizedBox(width: 16),
                              _buildPremiumStatCard(
                                'Today Bookings',
                                '${_dashboard?['today_bookings'] ?? 0}',
                                Icons.calendar_today_rounded,
                                AppTheme.primary,
                                'Active & Pending',
                              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                              const SizedBox(width: 16),
                              _buildPremiumStatCard(
                                'Pending Tasks',
                                '${_dashboard?['pending_bookings'] ?? 0}',
                                Icons.bolt_rounded,
                                AppTheme.warning,
                                'Requires attention',
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Structure 2: Unified Summary Grid
                        Text(
                          'Overview',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildMiniStat('Active Services', '${_dashboard?['active_services'] ?? 0}', Icons.build_circle_rounded, AppTheme.info),
                              _buildMiniStat('Completed Today', '${_dashboard?['completed_today'] ?? 0}', Icons.done_all_rounded, AppTheme.success),
                              _buildMiniStat('Total Centers', '${_dashboard?['total_centers'] ?? 1}', Icons.domain_rounded, AppTheme.accent),
                              _buildMiniStat('Monthly Rev', '₹${_dashboard?['monthly_revenue'] ?? '0'}', Icons.account_balance_wallet_rounded, const Color(0xFF9C27B0)),
                            ],
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                        const SizedBox(height: 32),

                        // Structure 3: Quick Setup Actions as beautiful wide cards
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ).animate().fadeIn(delay: 800.ms),
                        const SizedBox(height: 16),
                        
                        _buildWideActionCard(
                          icon: Icons.person_add_rounded,
                          title: 'Add New Mechanic',
                          subtitle: 'Expand your team and operations',
                          color: AppTheme.info,
                          onTap: () => _onNavTapped(2),
                        ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.1),
                        const SizedBox(height: 12),
                        _buildWideActionCard(
                          icon: Icons.add_business_rounded,
                          title: 'Manage Centers',
                          subtitle: 'View and update service center info',
                          color: AppTheme.primary,
                          onTap: () => _onNavTapped(4),
                        ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.1),

                      ],
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }

  Widget _buildTopActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bgCardLight.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildPremiumStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted.withValues(alpha: 0.3), size: 12),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideActionCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) async {
    // keeping previous notifications logic
    try {
      final data = await ApiService.get('/bookings/notifications/');
      final notifications = data['results'] as List? ?? [];

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Notifications',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_rounded,
                              size: 60,
                              color: AppTheme.textMuted.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Caught up!',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                            Text(
                              'No new notifications',
                              style: GoogleFonts.outfit(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: notifications.length,
                        itemBuilder: (_, i) {
                          final n = notifications[i];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  n['is_read']
                                      ? Icons.notifications_rounded
                                      : Icons.notifications_active_rounded,
                                  color: n['is_read']
                                      ? AppTheme.textMuted
                                      : AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['title'] ?? '',
                                        style: GoogleFonts.outfit(
                                          color: n['is_read']
                                              ? AppTheme.textSecondary
                                              : AppTheme.textPrimary,
                                          fontWeight: n['is_read']
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['message'] ?? '',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textMuted,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load notifications'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
