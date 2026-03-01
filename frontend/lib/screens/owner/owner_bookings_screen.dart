import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  List<dynamic> _bookings = [];
  List<dynamic> _mechanics = [];
  bool _isLoading = true;
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, String>{};
      if (_statusFilter.isNotEmpty) params['status'] = _statusFilter;
      final data = await ApiService.get('/bookings/owner/', params: params);
      setState(() {
        _bookings = data['results'] ?? [];
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
          'Booking Management',
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
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),

          SafeArea(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      _filterChip('All', ''),
                      _filterChip('Pending', 'pending'),
                      _filterChip('Confirmed', 'confirmed'),
                      _filterChip('In Progress', 'in_progress'),
                      _filterChip('Completed', 'completed'),
                      _filterChip('Cancelled', 'cancelled'),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : _bookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.book_online_rounded,
                                  size: 56,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No Bookings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bookings will appear here',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ],
                          ).animate().fadeIn(),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          color: AppTheme.primary,
                          backgroundColor: AppTheme.bgCard,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: _bookings.length,
                            itemBuilder: (_, i) =>
                                _buildBookingCard(_bookings[i])
                                    .animate()
                                    .fadeIn(delay: (i * 80).ms)
                                    .slideX(begin: 0.05),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String status) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _statusFilter = isSelected ? '' : status);
          _loadBookings();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  )
                : null,
            color: isSelected
                ? null
                : AppTheme.bgCardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppTheme.textPrimary.withValues(alpha: 0.05),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['booking_number'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
              StatusBadge(status: booking['status'] ?? ''),
            ],
          ),
          if (booking['service_center_name'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.store_rounded, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking['service_center_name'],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _infoRow(
            Icons.person_rounded,
            booking['user_name'] ?? '',
            AppTheme.accent,
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.directions_car_rounded,
            booking['vehicle_info'] ?? '',
            AppTheme.textMuted,
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.event_rounded,
            booking['booking_date'] ?? '',
            AppTheme.textMuted,
          ),
          if (booking['mechanic_name'] != null) ...[
            const SizedBox(height: 6),
            _infoRow(
              Icons.engineering_rounded,
              booking['mechanic_name'],
              AppTheme.primaryLight,
            ),
          ],
          const SizedBox(height: 16),
          _buildActions(booking),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: AppTheme.bgCardLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Map<String, dynamic> booking) {
    final status = booking['status'] ?? '';
    final actions = <Widget>[];

    if (status == 'pending') {
      actions.addAll([
        _actionButton(
          'Accept',
          AppTheme.success,
          Icons.check_rounded,
          () => _doAction(booking['id'], 'accept'),
        ),
        const SizedBox(width: 8),
        _actionButton(
          'Reject',
          AppTheme.error,
          Icons.close_rounded,
          () => _doAction(booking['id'], 'reject'),
        ),
      ]);
    } else if (status == 'confirmed') {
      actions.addAll([
        _actionButton(
          'Receive Vehicle',
          AppTheme.info,
          Icons.local_shipping_rounded,
          () => _doAction(booking['id'], 'receive_vehicle'),
        ),
        if (booking['mechanic'] == null) ...[
          const SizedBox(width: 8),
          _actionButton(
            'Assign Mechanic',
            AppTheme.primary,
            Icons.person_add_rounded,
            () => _showAssignMechanic(booking['id'], booking['service_center']?.toString() ?? ''),
          ),
        ],
      ]);
    } else if (status == 'vehicle_received') {
      if (booking['mechanic'] == null) {
        actions.add(
          _actionButton(
            'Assign Mechanic',
            AppTheme.primary,
            Icons.person_add_rounded,
            () => _showAssignMechanic(booking['id'], booking['service_center']?.toString() ?? ''),
          ),
        );
      } else {
        actions.add(
          _actionButton(
            'Inspection Done',
            AppTheme.warning,
            Icons.search_rounded,
            () => _showInspectionDialog(booking['id']),
          ),
        );
      }
    } else if (status == 'inspection_done') {
      actions.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text('Waiting for user approval...', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    } else if (status == 'estimate_approved') {
      actions.add(
        _actionButton(
          'Start Service',
          AppTheme.primary,
          Icons.build_rounded,
          () => _doAction(booking['id'], 'start_service'),
        ),
      );
    } else if (status == 'estimate_rejected') {
      actions.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text('User rejected estimate.', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );
    } else if (status == 'in_progress') {
      actions.add(
        _actionButton(
          'Complete',
          AppTheme.success,
          Icons.done_all_rounded,
          () => _doAction(booking['id'], 'complete_service'),
        ),
      );
    } else if (status == 'completed') {
      actions.addAll([
        _actionButton(
          'Ready Pickup',
          AppTheme.accent,
          Icons.local_parking_rounded,
          () => _doAction(booking['id'], 'ready_pickup'),
        ),
        const SizedBox(width: 8),
        _actionButton(
          'Invoice',
          AppTheme.warning,
          Icons.receipt_rounded,
          () => _showCreateInvoice(booking),
        ),
      ]);
    } else if (status == 'ready_pickup') {
      actions.add(
        _actionButton(
          'Delivered',
          AppTheme.success,
          Icons.verified_rounded,
          () => _doAction(booking['id'], 'delivered'),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: actions);
  }

  Widget _actionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doAction(String bookingId, String action) async {
    try {
      await ApiService.post(
        '/bookings/owner/$bookingId/action/',
        body: {'action': action},
      );
      _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking $action successful',
              style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showAssignMechanic(String bookingId, String centerId) async {
    if (centerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Could not identify service center for this booking.'), backgroundColor: AppTheme.error));
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );

    List<dynamic> centerMechanics = [];
    try {
      final data = await ApiService.get('/services/owner/centers/$centerId/mechanics/');
      centerMechanics = data['results'] ?? [];
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); // pop loading

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
        ),
        title: const Row(
          children: [
            Icon(Icons.engineering_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text(
              'Assign Mechanic',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: centerMechanics.isEmpty 
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No mechanics found for this service center.', style: TextStyle(color: AppTheme.textMuted)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: centerMechanics
                  .map(
                    (m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      m['user_details']?['full_name'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${m['specialization'] ?? ''} • ${m['active_jobs'] ?? 0} active jobs',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await ApiService.post(
                          '/bookings/owner/$bookingId/assign-mechanic/',
                          body: {'mechanic_id': m['id']},
                        );
                        _loadBookings();
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
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showInspectionDialog(String bookingId) {
    final reportCtrl = TextEditingController();
    final List<Map<String, dynamic>> estimateItems = [];
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String itemType = 'service';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
          ),
          title: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppTheme.warning),
              SizedBox(width: 8),
              Text(
                'Inspection & Estimate',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reportCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter general inspection notes...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Estimate Items', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ...estimateItems.asMap().entries.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.value['description'],
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                        ),
                        Text(
                          '₹${e.value['unit_price']} (${e.value['item_type'].toUpperCase()})',
                          style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: itemType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  dropdownColor: AppTheme.bgCard,
                  items: ['service', 'parts', 'labor', 'other'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: const TextStyle(color: AppTheme.textPrimary)))).toList(),
                  onChanged: (v) => setDialogState(() => itemType = v!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Item Description',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Est. Price (₹)',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, color: AppTheme.warning),
                  label: const Text('Add Estimate Item', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (descCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                      setDialogState(() {
                        estimateItems.add({
                          'item_type': itemType,
                          'description': descCtrl.text,
                          'unit_price': priceCtrl.text,
                          'quantity': 1,
                        });
                        descCtrl.clear();
                        priceCtrl.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.warning, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                // If they typed something but didn't click "Add", include it automatically
                if (descCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                  estimateItems.add({
                    'item_type': itemType,
                    'description': descCtrl.text,
                    'unit_price': priceCtrl.text,
                    'quantity': 1,
                  });
                }

                if (estimateItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one estimate item'), backgroundColor: AppTheme.error)
                  );
                  return;
                }

                Navigator.pop(context);
                
                double total = 0;
                for (var item in estimateItems) {
                  total += double.tryParse(item['unit_price'].toString()) ?? 0;
                }

                try {
                  await ApiService.post(
                    '/bookings/owner/$bookingId/action/',
                    body: {
                      'action': 'inspection_done',
                      'inspection_report': reportCtrl.text,
                      'estimated_cost': total.toString(),
                      'estimate_items': estimateItems,
                    },
                  );
                  _loadBookings();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating));
                  }
                }
              },
              child: const Text('Submit Estimate', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateInvoice(Map<String, dynamic> booking) {
    final String bookingId = booking['id'];
    final items = <Map<String, dynamic>>[];
    
    // Auto-populate from accepted estimate if available
    if (booking['estimate_items'] != null && booking['estimate_items'] is List) {
      for (var item in booking['estimate_items']) {
        items.add({
          'item_type': item['item_type'],
          'description': item['description'],
          'unit_price': item['unit_price'],
          'quantity': item['quantity'] ?? 1,
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppTheme.accent),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Create Invoice',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AUTO-FILLED',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.asMap().entries.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.value['description'],
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '₹${e.value['unit_price']}',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: items.isEmpty
                ? null
                : () async {
                    Navigator.pop(context);
                    try {
                      await ApiService.post(
                        '/bookings/invoice/create/$bookingId/',
                        body: {'items': items, 'tax_percentage': 18.0},
                      );
                      _loadBookings();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invoice created!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
            child: const Text(
              'Finalize & Create Invoice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
