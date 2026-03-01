import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import 'search_center_screen.dart';
import 'booking_list_screen.dart';
import 'service_history_screen.dart';
import 'profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/bookings/user/dashboard/');
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const SearchCenterScreen(),
      const BookingListScreen(),
      const ServiceHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Essential for glass bottom nav
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),

          screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child:
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary, // Crisp dark dock on light theme
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.dashboard_rounded),
                    _buildNavItem(1, Icons.search_rounded),
                    _buildNavItem(2, Icons.calendar_month_rounded),
                    _buildNavItem(3, Icons.history_rounded),
                    _buildNavItem(4, Icons.person_rounded),
                  ],
                ),
              ),
            ).animate().slideY(
              begin: 1.0,
              duration: 800.ms,
              curve: Curves.easeOutExpo,
            ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected
              ? AppTheme.textPrimary
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppTheme.accent,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        slivers: [
          // App Bar & Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.bgSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withValues(alpha: 0.1), AppTheme.bgSurface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${auth.firstName} 👋',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your Garage',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -1,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.softShadow,
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                                onPressed: () => _showNotifications(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quick Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusMedium,
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppTheme.primary.withValues(alpha: 0.6), size: 24),
                      const SizedBox(width: 14),
                      Text(
                        'Search service centers...',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune_rounded, color: AppTheme.primary, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Bookings',
                      value: '${_dashboardData?['total_bookings'] ?? 0}',
                      icon: Icons.calendar_month_rounded,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Active Services',
                      value: '${_dashboardData?['active_count'] ?? 0}',
                      icon: Icons.build_circle_rounded,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ),

          // Active Service
          if (_dashboardData?['active_service'] != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'Active Service',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),
                    _buildActiveServiceCard(
                      _dashboardData!['active_service'],
                    ).animate().fadeIn(delay: 600.ms).scaleXY(begin: 0.95),
                  ],
                ),
              ),
            ),

          // Upcoming Bookings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Upcoming Bookings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )
                  else if (_dashboardData?['upcoming_bookings']?.isEmpty ??
                      true)
                    const EmptyState(
                      icon: Icons.event_available_rounded,
                      title: 'No Upcoming Bookings',
                      message:
                          'Search for a service center to book your next service',
                    ).animate().fadeIn()
                  else
                    ...(_dashboardData!['upcoming_bookings'] as List)
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildBookingCard(entry.value)
                              .animate()
                              .fadeIn(delay: (700 + entry.key * 100).ms)
                              .slideX(begin: 0.1),
                        ),
                ],
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SERVICES',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildQuickAction(
                        Icons.search_rounded,
                        'Find Center',
                        AppTheme.primary,
                        () => setState(() => _currentIndex = 1),
                      ),
                      const SizedBox(width: 16),
                      _buildQuickAction(
                        Icons.directions_car_rounded,
                        'My Garage',
                        const Color(0xFF6366F1), // Indigo 500
                        () => setState(() => _currentIndex = 4),
                      ),
                      const SizedBox(width: 16),
                      _buildQuickAction(
                        Icons.receipt_long_rounded,
                        'History',
                        const Color(0xFF8B5CF6), // Violet 500
                        () => setState(() => _currentIndex = 3),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildActiveServiceCard(Map<String, dynamic> service) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${service['booking_number'] ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryLight,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              StatusBadge(status: service['status'] ?? 'pending'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppTheme.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['service_center_details']?['name'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${(service['status'] ?? 'Processing').toString().toUpperCase()}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (service['estimated_cost'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Est. Billing Amount',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${service['estimated_cost']}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppTheme.textMuted, height: 1),
          ),
          // Status Timeline
          _buildStatusTimeline(service['status'] ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = [
      'confirmed',
      'vehicle_received',
      'inspection_done',
      'in_progress',
      'completed',
      'ready_pickup',
    ];
    final currentIndex = statuses.indexOf(currentStatus);

    return SizedBox(
      height: 48,
      child: Row(
        children: statuses.asMap().entries.map((entry) {
          final i = entry.key;
          final isCompleted = i <= currentIndex;
          final isCurrent = i == currentIndex;
          final color = isCompleted
              ? AppTheme.accent
              : AppTheme.textMuted.withValues(alpha: 0.3);

          return Expanded(
            child: Row(
              children: [
                Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppTheme.bgCard : color,
                        border: Border.all(color: color, width: 3),
                        boxShadow: isCurrent || isCompleted
                            ? [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                    )
                    .animate(target: isCurrent ? 1 : 0)
                    .scaleXY(end: 1.3)
                    .shimmer(duration: 1.seconds),
                if (i < statuses.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['service_center_name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking['booking_date']} • ID: ${booking['booking_number']}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: booking['status'] ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) async {
    try {
      final data = await ApiService.get('/bookings/notifications/');
      final notifications = data['results'] as List? ?? [];
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: AppTheme.softShadow,
          ),
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Updates',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              if (notifications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 48, color: AppTheme.primary.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No new notifications',
                          style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final isRead = n['is_read'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isRead ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.primary.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isRead ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            n['title'] ?? '',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            n['message'] ?? '',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (i * 100).ms).slideX(begin: 0.05);
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (_) {}
  }
}
