import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import 'book_service_screen.dart';

class CenterDetailScreen extends StatefulWidget {
  final String centerId;
  const CenterDetailScreen({super.key, required this.centerId});

  @override
  State<CenterDetailScreen> createState() => _CenterDetailScreenState();
}

class _CenterDetailScreenState extends State<CenterDetailScreen> {
  Map<String, dynamic>? _center;
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenter();
    _loadReviews();
  }

  Future<void> _loadCenter() async {
    try {
      final data = await ApiService.get(
        '/services/centers/${widget.centerId}/',
      );
      setState(() {
        _center = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ApiService.get('/reviews/center/${widget.centerId}/');
      setState(() => _reviews = data['results'] ?? []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
              const SizedBox(height: 24),
              Text(
                'Fetching Details...',
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ).animate().fadeIn(duration: 800.ms),
            ],
          ),
        ),
      );
    }

    if (_center == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Center Not Found',
          message: 'The service center you are looking for does not exist.',
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          // Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.05),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Icon(
                            Icons.store_rounded,
                            size: 60,
                            color: AppTheme.primary,
                          ),
                        ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _center!['name'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.8,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & Reviews
                  // Rating & Reviews
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMedium,
                      boxShadow: AppTheme.softShadow,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${_center!['average_rating'] ?? 0.0}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFF59E0B),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RatingStars(
                                  rating: (_center!['average_rating'] ?? 0).toDouble(),
                                  size: 14,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_center!['total_reviews'] ?? 0} reviews',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Container(width: 1, height: 100, color: const Color(0xFFF1F5F9)),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(Icons.location_on_rounded, _center!['address'] ?? '', AppTheme.primary),
                                  const SizedBox(height: 12),
                                  _infoRow(Icons.phone_rounded, _center!['phone'] ?? '', const Color(0xFF0F172A)),
                                  const SizedBox(height: 12),
                                  _infoRow(Icons.access_time_filled_rounded, '${_center!['opening_time']} - ${_center!['closing_time']}', const Color(0xFFF59E0B)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xFFF1F5F9)),
                        ),
                        _infoRow(
                          Icons.calendar_month_rounded,
                          'Working Days: ${_center!['working_days'] ?? 'All weekdays'}',
                          AppTheme.primary,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                  // Description
                  if (_center!['description']?.isNotEmpty == true) ...[
                    const SizedBox(height: 32),
                    _sectionHeader('About Center', Icons.info_outline_rounded),
                    const SizedBox(height: 16),
                    Text(
                      _center!['description'] ?? '',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],

                  // Services
                  const SizedBox(height: 32),
                  _sectionHeader(
                    'Premium Services',
                    Icons.miscellaneous_services_rounded,
                  ),
                  const SizedBox(height: 16),
                  ...(_center!['offered_services'] as List? ?? [])
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildServiceItem(entry.value)
                            .animate()
                            .fadeIn(delay: (700 + entry.key * 100).ms)
                            .slideX(begin: -0.1),
                      ),

                  // Time Slots
                  const SizedBox(height: 32),
                  _sectionHeader('Available Slots', Icons.schedule_rounded),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: (_center!['time_slots'] as List? ?? [])
                        .asMap()
                        .entries
                        .map(
                          (entry) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCardLight.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryLight.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${entry.value['start_time']} - ${entry.value['end_time']}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ).animate().fadeIn(delay: (800 + entry.key * 50).ms).scale(),
                        )
                        .toList(),
                  ),

                  // Reviews
                  const SizedBox(height: 48),
                  _sectionHeader('Customer Reviews', Icons.star_rounded),
                  const SizedBox(height: 16),
                  if (_reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.textPrimary.withValues(alpha: 0.05),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No reviews yet. Be the first!',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms)
                  else
                    ..._reviews
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildReviewCard(entry.value)
                              .animate()
                              .fadeIn(delay: (900 + entry.key * 100).ms)
                              .slideY(begin: 0.1),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: GradientButton(
            text: 'Schedule Appointment',
            icon: Icons.calendar_today_rounded,
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BookServiceScreen(center: _center!),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
                    ),
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutExpo),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.6), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.build_circle_rounded, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['service_type_name'] ?? '',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (service['description']?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    service['description'] ?? '',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${service['price'] ?? ''}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${service['estimated_duration'] ?? ''} mins',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (review['user_name'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user_name'] ?? 'Anonymous User',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RatingStars(rating: (review['rating'] ?? 0).toDouble(), size: 12),
                  ],
                ),
              ),
            ],
          ),
          if (review['comment']?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              review['comment'] ?? '',
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          if (review['owner_reply']?.isNotEmpty == true) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1F5F9))),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded, color: AppTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Owner Response',
                        style: GoogleFonts.outfit(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['owner_reply'] ?? '',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
