import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/common_widgets.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      final data = await ApiService.get('/bookings/user/${widget.bookingId}/');
      setState(() {
        _booking = data;
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
          'Booking Details',
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
          // Background Glow
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryDark.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
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
          ).animate().fadeIn(duration: 800.ms),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : _booking == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Booking not found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBooking,
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.bgCard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking header
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _booking!['booking_number'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.accent,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    StatusBadge(
                                      status: _booking!['status'] ?? '',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 1,
                                  color: AppTheme.textPrimary.withValues(
                                    alpha: 0.05,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _detailRow(
                                  Icons.event_rounded,
                                  'Date',
                                  _booking!['booking_date'] ?? '',
                                ),
                                _detailRow(
                                  Icons.storefront_rounded,
                                  'Service Center',
                                  _booking!['service_center_details']?['name'] ??
                                      '',
                                ),
                                _detailRow(
                                  Icons.directions_car_rounded,
                                  'Vehicle',
                                  '${_booking!['vehicle_details']?['make'] ?? ''} ${_booking!['vehicle_details']?['model'] ?? ''}',
                                ),
                                if (_booking!['mechanic_details'] != null)
                                  _detailRow(
                                    Icons.engineering_rounded,
                                    'Mechanic',
                                    _booking!['mechanic_details']?['user_details']?['full_name'] ??
                                        '',
                                  ),
                                if (_booking!['estimated_cost'] != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 1,
                                    color: AppTheme.textPrimary.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Estimated Cost',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₹${_booking!['estimated_cost']}',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_booking!['estimate_items'] != null && (_booking!['estimate_items'] as List).isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bgCardLight.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          ...(_booking!['estimate_items'] as List).map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${item['description'] ?? ''} (${(item['item_type'] as String).toUpperCase()})',
                                                    style: const TextStyle(
                                                      color: AppTheme.textMuted,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '₹${item['unit_price']}',
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: 0.1),

                          // Status Timeline
                          const SizedBox(height: 32),
                          const Row(
                            children: [
                              Icon(
                                Icons.timeline_rounded,
                                color: AppTheme.accent,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Status Timeline',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 16),
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: _buildFullTimeline(),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

                          // Services
                          if (_booking!['services_list'] != null) ...[
                            const SizedBox(height: 32),
                            const Row(
                              children: [
                                Icon(
                                  Icons.build_circle_rounded,
                                  color: AppTheme.primaryLight,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Services',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 300.ms),
                            const SizedBox(height: 16),
                            ...(_booking!['services_list'] as List)
                                .asMap()
                                .entries
                                .map((entry) {
                                  final s = entry.value;
                                  return GlassCard(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              s['name'] ?? '',
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accent
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '₹${s['price'] ?? ''}',
                                                style: const TextStyle(
                                                  color: AppTheme.accent,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: (400 + entry.key * 100).ms)
                                      .slideX(begin: -0.1);
                                }),
                          ],

                          // Problem Description
                          if (_booking!['problem_description']?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 32),
                            const Row(
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  color: AppTheme.textMuted,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Problem Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 16),
                            GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    _booking!['problem_description'] ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .slideY(begin: 0.1),
                          ],

                          // Mechanic Notes
                          if (_booking!['mechanic_notes']?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 32),
                            const Row(
                              children: [
                                Icon(
                                  Icons.note_alt_rounded,
                                  color: AppTheme.warning,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Mechanic Notes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 16),
                            GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    _booking!['mechanic_notes'] ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 700.ms)
                                .slideY(begin: 0.1),
                          ],

                          // Inspection Report
                          if (_booking!['inspection_report']?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 32),
                            const Row(
                              children: [
                                Icon(
                                  Icons.assignment_turned_in_rounded,
                                  color: AppTheme.success,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Inspection Report',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 700.ms),
                            const SizedBox(height: 16),
                            GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    _booking!['inspection_report'] ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideY(begin: 0.1),
                          ],

                          // Invoice
                          if (_booking!['invoice'] != null) ...[
                            const SizedBox(height: 32),
                            _buildInvoiceSection(_booking!['invoice'])
                                .animate()
                                .fadeIn(delay: 900.ms)
                                .slideY(begin: 0.1),
                          ],

                          // Actions
                          const SizedBox(height: 48),
                          if (_booking!['status'] == 'pending' ||
                              _booking!['status'] == 'confirmed')
                            Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.error.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.cancel_rounded),
                                    label: const Text(
                                      'Cancel Booking',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.error,
                                      foregroundColor: AppTheme.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _cancelBooking,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 1000.ms)
                                .scale(begin: const Offset(0.9, 0.9)),

                          if (_booking!['status'] == 'inspection_done')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Action Required', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        icon: const Icon(Icons.check_circle_rounded),
                                        label: const Text('Accept Estimate', style: TextStyle(fontWeight: FontWeight.bold)),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _handleEstimate('approve'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.cancel_rounded),
                                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.error,
                                          side: const BorderSide(color: AppTheme.error),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _handleEstimate('reject'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),

                          if (_booking!['invoice'] != null &&
                              _booking!['invoice']?['is_paid'] != true)
                            Column(
                              children: [
                                SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF4834DF),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF6C63FF,
                                              ).withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: FilledButton.icon(
                                          icon: const Icon(
                                            Icons.payment_rounded,
                                          ),
                                          label: const Text(
                                            'Pay Online (Razorpay)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor:
                                                AppTheme.textPrimary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: _payWithRazorpay,
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 1000.ms)
                                    .scale(begin: const Offset(0.9, 0.9)),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.money_rounded),
                                    label: const Text(
                                      'Pay with Cash',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.textSecondary,
                                      side: BorderSide(
                                        color: AppTheme.textMuted.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _payWithCash,
                                  ),
                                ).animate().fadeIn(delay: 1100.ms),
                              ],
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.bgCardLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.textMuted, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTimeline() {
    final allStatuses = [
      {
        'key': 'pending',
        'label': 'Booking Created',
        'icon': Icons.bookmark_added_rounded,
      },
      {
        'key': 'confirmed',
        'label': 'Confirmed',
        'icon': Icons.check_circle_rounded,
      },
      {
        'key': 'vehicle_received',
        'label': 'Vehicle Received',
        'icon': Icons.local_shipping_rounded,
      },
      {
        'key': 'inspection_done',
        'label': 'Inspection Done',
        'icon': Icons.content_paste_search_rounded,
      },
      {
        'key': 'estimate_approved',
        'label': 'Estimate Approved',
        'icon': Icons.verified_rounded,
      },
      {
        'key': 'in_progress',
        'label': 'In Progress',
        'icon': Icons.car_repair_rounded,
      },
      {
        'key': 'completed',
        'label': 'Completed',
        'icon': Icons.done_all_rounded,
      },
      {
        'key': 'ready_pickup',
        'label': 'Ready for Pickup',
        'icon': Icons.hail_rounded,
      },
      {
        'key': 'delivered',
        'label': 'Delivered',
        'icon': Icons.verified_user_rounded,
      },
    ];

    final currentStatus = _booking!['status'] ?? 'pending';
    final currentIndex = allStatuses.indexWhere(
      (s) => s['key'] == currentStatus,
    );
    final isCancelled = currentStatus == 'cancelled';

    return Column(
      children: allStatuses.asMap().entries.map((entry) {
        final i = entry.key;
        final status = entry.value;
        final isCompleted = !isCancelled && i <= currentIndex;
        final isCurrent = !isCancelled && i == currentIndex;
        final isLast = i == allStatuses.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCompleted ? AppTheme.primaryGradient : null,
                      color: isCompleted ? null : AppTheme.bgCardLight,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.transparent
                            : AppTheme.textMuted.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: isCompleted
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.primary.withValues(alpha: 0.5)
                              : AppTheme.textPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: Text(
                    status['label'] as String,
                    style: TextStyle(
                      color: isCurrent
                          ? AppTheme.textPrimary
                          : (isCompleted
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted),
                      fontWeight: isCurrent
                          ? FontWeight.w900
                          : (isCompleted ? FontWeight.bold : FontWeight.w500),
                      fontSize: isCurrent ? 16 : 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInvoiceSection(Map<String, dynamic> invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.warning),
            SizedBox(width: 8),
            Text(
              'Invoice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _invoiceRow('Invoice #', invoice['invoice_number'] ?? ''),
              const SizedBox(height: 8),
              _invoiceRow('Subtotal', '₹${invoice['subtotal'] ?? '0'}'),
              const SizedBox(height: 4),
              _invoiceRow(
                'Tax (${invoice['tax_percentage'] ?? '18'}%)',
                '₹${invoice['tax_amount'] ?? '0'}',
              ),
              if ((invoice['discount'] ?? '0') != '0') ...[
                const SizedBox(height: 4),
                _invoiceRow(
                  'Discount',
                  '-₹${invoice['discount']}',
                  valueColor: AppTheme.success,
                ),
              ],
              const SizedBox(height: 16),
              const Divider(color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹${invoice['total_amount'] ?? '0'}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      shadows: [Shadow(color: AppTheme.accent, blurRadius: 10)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      (invoice['is_paid'] == true
                              ? AppTheme.success
                              : AppTheme.warning)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (invoice['is_paid'] == true
                                ? AppTheme.success
                                : AppTheme.warning)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      invoice['is_paid'] == true
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      color: invoice['is_paid'] == true
                          ? AppTheme.success
                          : AppTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      invoice['is_paid'] == true
                          ? 'Payment Completed'
                          : 'Payment Pending',
                      style: TextStyle(
                        color: invoice['is_paid'] == true
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text(
              'Cancel Booking?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, Keep it',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error.withValues(alpha: 0.2),
              foregroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.post('/bookings/user/${widget.bookingId}/cancel/');
        _loadBooking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Booking cancelled',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEstimate(String action) async {
    try {
      await ApiService.post('/bookings/user/${widget.bookingId}/approve-estimate/', body: {'action': action});
      _loadBooking();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estimate ${action}d successfully!', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _payWithRazorpay() async {
    final invoiceId = _booking!['invoice']?['id'];
    if (invoiceId == null) return;

    PaymentService.openRazorpayCheckout(
      invoiceId: invoiceId,
      onSuccess: (message) {
        _loadBooking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onFailure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_rounded, color: AppTheme.textPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Future<void> _payWithCash() async {
    try {
      final invoiceId = _booking!['invoice']?['id'];
      if (invoiceId != null) {
        await ApiService.post(
          '/bookings/invoice/$invoiceId/pay/',
          body: {'payment_method': 'cash'},
        );
        _loadBooking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cash payment recorded!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
