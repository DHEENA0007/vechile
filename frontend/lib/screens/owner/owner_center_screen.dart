import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class OwnerCenterScreen extends StatefulWidget {
  const OwnerCenterScreen({super.key});

  @override
  State<OwnerCenterScreen> createState() => _OwnerCenterScreenState();
}

class _OwnerCenterScreenState extends State<OwnerCenterScreen> {
  List<dynamic> _centers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/services/owner/centers/');
      setState(() {
        _centers = data['results'] ?? [];
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
          'My Service Centers',
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateCenter,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: AppTheme.textPrimary),
          label: const Text(
            'Add Center',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      body: Stack(
        children: [
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.06),
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
                : _centers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            size: 64,
                            color: AppTheme.primary,
                          ),
                        ).animate().scale(
                          delay: 200.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Service Centers',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first service center',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Create Center',
                          icon: Icons.add_rounded,
                          onPressed: _showCreateCenter,
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCenters,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.bgCard,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: _centers.length,
                      itemBuilder: (_, i) => _buildCenterCard(_centers[i])
                          .animate()
                          .fadeIn(delay: (i * 100).ms)
                          .slideY(begin: 0.1),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(Map<String, dynamic> center) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.car_repair_rounded,
                  color: AppTheme.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingStars(
                          rating: (center['average_rating'] ?? 0).toDouble(),
                          size: 14,
                        ),
                        Text(
                          ' (${center['total_reviews'] ?? 0})',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (center['is_active'] == true
                              ? AppTheme.success
                              : AppTheme.error)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        (center['is_active'] == true
                                ? AppTheme.success
                                : AppTheme.error)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  center['is_active'] == true ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: center['is_active'] == true
                        ? AppTheme.success
                        : AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.location_on_rounded,
            '${center['address'] ?? ''}, ${center['city'] ?? ''}',
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_rounded, center['phone'] ?? ''),
          const SizedBox(height: 6),
          _infoRow(
            Icons.access_time_rounded,
            '${center['opening_time'] ?? ''} - ${center['closing_time'] ?? ''}',
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.calendar_today_rounded, center['working_days'] ?? ''),

          // Show current services count & time slots count
          if (center['offered_services'] != null ||
              center['time_slots'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(
                  '${(center['offered_services'] as List?)?.length ?? 0} Services',
                  AppTheme.accent,
                ),
                const SizedBox(width: 8),
                _statChip(
                  '${(center['time_slots'] as List?)?.length ?? 0} Slots',
                  AppTheme.info,
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              const Spacer(),
              _actionBtn(
                'Services',
                Icons.build_rounded,
                AppTheme.accent,
                () => _showManageServices(center),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                'Time Slots',
                Icons.schedule_rounded,
                AppTheme.info,
                () => _showManageTimeSlots(center),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: AppTheme.bgCardLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.textMuted, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  // ================== CREATE CENTER ==================

  void _showCreateCenter() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    TimeOfDay openingTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay closingTime = const TimeOfDay(hour: 18, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_business_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Create Center',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Center Name'),
                _dialogField(descCtrl, 'Description', maxLines: 2),
                _dialogField(phoneCtrl, 'Phone', keyboard: TextInputType.phone),
                _dialogField(addressCtrl, 'Address'),
                Row(
                  children: [
                    Expanded(child: _dialogField(cityCtrl, 'City')),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogField(stateCtrl, 'State')),
                  ],
                ),
                _dialogField(pincodeCtrl, 'Pincode'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: openingTime,
                          );
                          if (picked != null) setDlgState(() => openingTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Opens At', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                              Text(openingTime.format(ctx), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: closingTime,
                          );
                          if (picked != null) setDlgState(() => closingTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Closes At', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                              Text(closingTime.format(ctx), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || addressCtrl.text.isEmpty || cityCtrl.text.isEmpty || stateCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppTheme.warning, behavior: SnackBarBehavior.floating),
                  );
                  return;
                }

                final openMin = openingTime.hour * 60 + openingTime.minute;
                final closeMin = closingTime.hour * 60 + closingTime.minute;
                if (closeMin <= openMin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Closing time must be after opening time'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                  );
                  return;
                }

                final openStr = '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}';
                final closeStr = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}';

                try {
                  await ApiService.post(
                    '/services/owner/centers/',
                    body: {
                      'name': nameCtrl.text,
                      'description': descCtrl.text,
                      'phone': phoneCtrl.text,
                      'address': addressCtrl.text,
                      'city': cityCtrl.text,
                      'state': stateCtrl.text,
                      'pincode': pincodeCtrl.text,
                      'opening_time': openStr,
                      'closing_time': closeStr,
                    },
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadCenters();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Center created!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ================== MANAGE SERVICES ==================

  void _showManageServices(Map<String, dynamic> center) {
    final centerId = center['id'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ServiceManagementSheet(centerId: centerId, onChanged: _loadCenters),
    );
  }

  // ================== MANAGE TIME SLOTS ==================

  void _showManageTimeSlots(Map<String, dynamic> center) {
    final centerId = center['id'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _TimeSlotManagementSheet(centerId: centerId, onChanged: _loadCenters),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          filled: true,
          fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  SERVICE MANAGEMENT BOTTOM SHEET
// ============================================================

class _ServiceManagementSheet extends StatefulWidget {
  final String centerId;
  final VoidCallback onChanged;
  const _ServiceManagementSheet({
    required this.centerId,
    required this.onChanged,
  });

  @override
  State<_ServiceManagementSheet> createState() =>
      _ServiceManagementSheetState();
}

class _ServiceManagementSheetState extends State<_ServiceManagementSheet> {
  List<dynamic> _services = [];
  List<dynamic> _serviceTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final servicesData = await ApiService.get(
        '/services/owner/centers/${widget.centerId}/services/',
      );
      final typesData = await ApiService.get('/services/types/');
      setState(() {
        _services = servicesData['results'] ?? [];
        _serviceTypes = typesData['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.build_rounded, color: AppTheme.accent),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Manage Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.accent,
                      size: 22,
                    ),
                  ),
                  onPressed: _showAddService,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : _services.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_circle_rounded,
                          size: 56,
                          color: AppTheme.accent.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No services added',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.accent,
                          ),
                          label: const Text(
                            'Add Service',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _showAddService,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _services.length,
                      itemBuilder: (_, i) => _buildServiceCard(_services[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['service_type_name'] ?? '',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${service['price'] ?? '0'}',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${service['estimated_duration'] ?? 0} min',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (service['is_available'] == true
                          ? AppTheme.success
                          : AppTheme.error)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service['is_available'] == true ? 'Active' : 'Off',
              style: TextStyle(
                color: service['is_available'] == true
                    ? AppTheme.success
                    : AppTheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteService(service['id']),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppTheme.error,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddService() {
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    final descCtrl = TextEditingController();
    String? selectedTypeId;

    // Filter out already-added service types
    final existingTypeIds = _services.map((s) => s['service_type']).toSet();
    final availableTypes = _serviceTypes
        .where((t) => !existingTypeIds.contains(t['id']))
        .toList();

    if (availableTypes.isEmpty && _serviceTypes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All available service types have been added',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_rounded, color: AppTheme.accent),
              SizedBox(width: 8),
              Text(
                'Add Service',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTypeId,
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppTheme.bgCard,
                  items: availableTypes
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t['id']?.toString() ?? '',
                          child: Text(
                            t['name'] ?? '',
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDlgState(() => selectedTypeId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  onChanged: (_) => setDlgState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    filled: true,
                    fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (selectedTypeId == null || priceCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a service type and enter price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppTheme.warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                try {
                  await ApiService.post(
                    '/services/owner/centers/${widget.centerId}/services/',
                    body: {
                      'service_type': selectedTypeId,
                      'price': priceCtrl.text,
                      'estimated_duration':
                          int.tryParse(durationCtrl.text) ?? 60,
                      'description': descCtrl.text,
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                  widget.onChanged();
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Service added!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Service?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will remove this service from your center.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.delete('/services/owner/services/$serviceId/');
        _load();
        widget.onChanged();
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Service removed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
      } catch (e) {
        if (mounted)
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

// ============================================================
//  TIME SLOT MANAGEMENT BOTTOM SHEET
// ============================================================

class _TimeSlotManagementSheet extends StatefulWidget {
  final String centerId;
  final VoidCallback onChanged;
  const _TimeSlotManagementSheet({
    required this.centerId,
    required this.onChanged,
  });

  @override
  State<_TimeSlotManagementSheet> createState() =>
      _TimeSlotManagementSheetState();
}

class _TimeSlotManagementSheetState extends State<_TimeSlotManagementSheet> {
  List<dynamic> _slots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get(
        '/services/owner/centers/${widget.centerId}/timeslots/',
      );
      setState(() {
        _slots = data['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppTheme.info),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Manage Time Slots',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.info,
                      size: 22,
                    ),
                  ),
                  onPressed: _showAddSlot,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.info),
                  )
                : _slots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 56,
                          color: AppTheme.info.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No time slots configured',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.info,
                          ),
                          label: const Text(
                            'Add Time Slot',
                            style: TextStyle(
                              color: AppTheme.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _showAddSlot,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _slots.length,
                      itemBuilder: (_, i) => _buildSlotCard(_slots[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final start = slot['start_time'] ?? '';
    final end = slot['end_time'] ?? '';
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: AppTheme.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$start - $end',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max ${slot['max_bookings'] ?? 3} bookings',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (slot['is_active'] == true
                          ? AppTheme.success
                          : AppTheme.error)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slot['is_active'] == true ? 'Active' : 'Off',
              style: TextStyle(
                color: slot['is_active'] == true
                    ? AppTheme.success
                    : AppTheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteSlot(slot['id']),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppTheme.error,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSlot() {
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    final maxCtrl = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15)),
          ),
          title: const Row(
            children: [
              Icon(Icons.schedule_rounded, color: AppTheme.info),
              SizedBox(width: 8),
              Text(
                'Add Time Slot',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start time picker
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: startTime,
                  );
                  if (picked != null) setDlgState(() => startTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: AppTheme.info,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Start: ',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      Text(
                        startTime.format(ctx),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // End time picker
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: endTime,
                  );
                  if (picked != null) setDlgState(() => endTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stop_rounded,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'End:   ',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      Text(
                        endTime.format(ctx),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Max bookings per slot',
                  filled: true,
                  fillColor: AppTheme.bgCardLight.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
                backgroundColor: AppTheme.info,
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final startMinutes = startTime.hour * 60 + startTime.minute;
                final endMinutes = endTime.hour * 60 + endTime.minute;

                if (endMinutes <= startMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                      backgroundColor: AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final startStr =
                    '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                final endStr =
                    '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
                try {
                  await ApiService.post(
                    '/services/owner/centers/${widget.centerId}/timeslots/',
                    body: {
                      'start_time': startStr,
                      'end_time': endStr,
                      'max_bookings': int.tryParse(maxCtrl.text) ?? 3,
                    },
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                  widget.onChanged();
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Time slot added!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSlot(String slotId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Time Slot?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will remove this time slot.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.delete('/services/owner/timeslots/$slotId/');
        _load();
        widget.onChanged();
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Time slot removed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
      } catch (e) {
        if (mounted)
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
