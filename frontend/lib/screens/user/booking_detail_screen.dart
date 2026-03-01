import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text(
          'Booking Detail',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: false,
        leading: const BackButton(color: AppTheme.textPrimary),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF8FAFC)),
          SafeArea(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
                        const SizedBox(height: 24),
                        Text(
                          'Loading Details...',
                          style: GoogleFonts.outfit(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : _booking == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Booking not found',
                              style: GoogleFonts.outfit(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BOOKING #${_booking!['booking_number'] ?? ''}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.primary,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _booking!['booking_date'] ?? '',
                                          style: GoogleFonts.outfit(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatusBadge(status: _booking!['status'] ?? ''),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(color: Color(0xFFF1F5F9)),
                                ),
                                _detailRow(
                                  Icons.event_rounded,
                                  'Date',
                                  _booking!['booking_date'] ?? '',
                                ),
                                _detailRow(
                                  Icons.store_rounded,
                                  'Service Center',
                                  _booking!['service_center_details']?['name'] ?? '',
                                ),
                                _detailRow(
                                  Icons.directions_car_rounded,
                                  'Vehicle',
                                  '${_booking!['vehicle_details']?['make'] ?? ''} ${_booking!['vehicle_details']?['model'] ?? ''}',
                                ),
                                if (_booking!['mechanic_details'] != null)
                                  _detailRow(
                                    Icons.engineering_rounded,
                                    'Service Expert',
                                    _booking!['mechanic_details']?['user_details']?['full_name'] ?? '',
                                  ),
                                if (_booking!['estimated_cost'] != null) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(color: Color(0xFFF1F5F9)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Estimated Total',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '₹${_booking!['estimated_cost']}',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_booking!['estimate_items'] != null && (_booking!['estimate_items'] as List).isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFF1F5F9)),
                                      ),
                                      child: Column(
                                        children: [
                                          ...(_booking!['estimate_items'] as List).map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${item['description'] ?? ''}',
                                                    style: GoogleFonts.outfit(
                                                      color: AppTheme.textSecondary,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '₹${item['unit_price']}',
                                                  style: GoogleFonts.outfit(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
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
                          _sectionHeader('Tracking Status', Icons.timeline_rounded),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.radiusMedium,
                              boxShadow: AppTheme.softShadow,
                            ),
                            padding: const EdgeInsets.all(24),
                            child: _buildFullTimeline(),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                          // Services
                          if (_booking!['services_list'] != null) ...[
                            const SizedBox(height: 32),
                            _sectionHeader('Services Required', Icons.build_circle_rounded),
                            const SizedBox(height: 16),
                              ...(_booking!['services_list'] as List).asMap().entries.map((entry) {
                                final s = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppTheme.radiusMedium,
                                    boxShadow: AppTheme.softShadow,
                                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        s['name'] ?? '',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₹${s['price'] ?? ''}',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: (400 + entry.key * 100).ms).slideX(begin: -0.1);
                              }),
                          ],

                          // Problem Description
                          if (_booking!['problem_description']?.isNotEmpty == true) ...[
                            const SizedBox(height: 32),
                            _sectionHeader('Problem Notes', Icons.description_rounded),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppTheme.radiusMedium,
                                boxShadow: AppTheme.softShadow,
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _booking!['problem_description'] ?? '',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                  height: 1.6,
                                  fontSize: 15,
                                ),
                              ),
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                          ],

                          // Mechanic Notes
                          if (_booking!['mechanic_notes']?.isNotEmpty == true) ...[
                            const SizedBox(height: 32),
                            _sectionHeader('Expert Notes', Icons.note_alt_rounded),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: AppTheme.radiusMedium,
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _booking!['mechanic_notes'] ?? '',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF92400E),
                                  height: 1.6,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          ],

                          // Inspection Report
                          if (_booking!['inspection_report']?.isNotEmpty == true) ...[
                            const SizedBox(height: 32),
                            _sectionHeader('Inspection Results', Icons.assignment_turned_in_rounded),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: AppTheme.radiusMedium,
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _booking!['inspection_report'] ?? '',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF166534),
                                  height: 1.6,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
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
                          if (_booking!['status'] == 'pending' || _booking!['status'] == 'confirmed')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                label: Text(
                                  'Cancel Booking',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(color: Color(0xFFFEE2E2)),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: const Color(0xFFFEF2F2),
                                ),
                                onPressed: _cancelBooking,
                              ),
                            ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.95, 0.95)),

                          if (_booking!['status'] == 'inspection_done')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.notification_important_rounded, color: Color(0xFF92400E)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Estimate requires your approval to proceed.',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFF92400E),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _handleEstimate('approve'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primary,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                elevation: 0,
                                              ),
                                              child: Text('Approve', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _handleEstimate('reject'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF92400E),
                                                side: const BorderSide(color: Color(0xFFFDE68A)),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: Text('Reject', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),

                          if (_booking!['invoice'] != null && _booking!['invoice']?['is_paid'] != true)
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: AppTheme.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _payWithRazorpay,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Secure Checkout',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.95, 0.95)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: _payWithCash,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.textSecondary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      'Prefer to pay with cash at center?',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
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
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Final Invoice', Icons.receipt_long_rounded),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: invoice['is_paid'] == true ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  invoice['is_paid'] == true ? 'PAID' : 'UNPAID',
                  style: GoogleFonts.outfit(
                    color: invoice['is_paid'] == true ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _invoiceRow('Subtotal', '₹${invoice['total_amount']}', isBold: false),
          const SizedBox(height: 8),
          _invoiceRow('Taxes & Fees', '₹${(invoice['total_amount'] * 0.05).toStringAsFixed(0)}', isBold: false),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1F5F9))),
          _invoiceRow('Grand Total', '₹${invoice['total_amount']}', isBold: true, color: AppTheme.primary),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color ?? (isBold ? AppTheme.textPrimary : AppTheme.textSecondary),
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 20 : 15,
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
