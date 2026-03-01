import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _dashboard;
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  static const _mechColor = Color(0xFFFF6B35);
  static const _mechColorDark = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadJobs();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ApiService.get('/bookings/mechanic/dashboard/');
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadJobs() async {
    try {
      final data = await ApiService.get('/bookings/mechanic/');
      setState(() => _jobs = data['results'] ?? []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mechColor.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: _mechColor.withValues(alpha: 0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          _currentIndex == 0 ? _buildDashboard() : _buildJobList(),
        ],
      ),
      bottomNavigationBar:
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface.withValues(alpha: 0.8),
                    border: Border.all(
                      color: AppTheme.textPrimary.withValues(alpha: 0.05),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: _mechColor,
                    unselectedItemColor: AppTheme.textMuted,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.dashboard_rounded, size: 24),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _mechColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.dashboard_rounded,
                            size: 26,
                            color: _mechColor,
                          ),
                        ),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.work_rounded, size: 24),
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _mechColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.work_rounded,
                            size: 26,
                            color: _mechColor,
                          ),
                        ),
                        label: 'All Jobs',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().slideY(
            begin: 1.0,
            duration: 800.ms,
            curve: Curves.easeOutExpo,
          ),
    );
  }

  Widget _buildDashboard() {
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboard();
        await _loadJobs();
      },
      color: _mechColor,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_mechColor, _mechColorDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                              'Hi, ${auth.fullName}! 🔧',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideX(begin: -0.1),
                        const SizedBox(height: 6),
                        const Text(
                          'Ready to fix some vehicles?',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () => _showNotifications(context),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () => auth.logout(),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(color: _mechColor),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Assigned Jobs',
                                value: '${_dashboard?['assigned_jobs'] ?? 0}',
                                icon: Icons.assignment_rounded,
                                color: _mechColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'In Progress',
                                value: '${_dashboard?['in_progress'] ?? 0}',
                                icon: Icons.build_rounded,
                                color: AppTheme.warning,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Completed Today',
                                value: '${_dashboard?['completed_today'] ?? 0}',
                                icon: Icons.done_all_rounded,
                                color: AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Total Completed',
                                value: '${_dashboard?['total_completed'] ?? 0}',
                                icon: Icons.emoji_events_rounded,
                                color: AppTheme.accent,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                        // Today's Tasks
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _mechColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Today's Tasks",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: 16),

                        if ((_dashboard?['todays_tasks'] as List?)?.isEmpty ??
                            true)
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: _mechColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.work_off_rounded,
                                    size: 48,
                                    color: _mechColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Tasks Today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enjoy your free time!',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms),
                          )
                        else
                          ...(_dashboard!['todays_tasks'] as List)
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildJobCard(entry.value)
                                    .animate()
                                    .fadeIn(delay: (600 + entry.key * 100).ms)
                                    .slideX(begin: 0.1),
                              ),
                      ],
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'All Jobs',
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
      body: SafeArea(
        child: _jobs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _mechColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.work_rounded,
                        size: 56,
                        color: _mechColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Jobs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your assigned jobs will appear here',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ).animate().fadeIn(),
              )
            : RefreshIndicator(
                onRefresh: _loadJobs,
                color: _mechColor,
                backgroundColor: AppTheme.bgCard,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: _jobs.length,
                  itemBuilder: (_, i) => _buildJobCard(
                    _jobs[i],
                  ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05),
                ),
              ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
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
                  color: _mechColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job['booking_number'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _mechColor,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
              StatusBadge(status: job['status'] ?? ''),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.person_rounded,
            job['user_name'] ?? '',
            AppTheme.accent,
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.directions_car_rounded,
            job['vehicle_info'] ?? '',
            AppTheme.textMuted,
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.event_rounded,
            job['booking_date'] ?? '',
            AppTheme.textMuted,
          ),
          if (job['services_list'] != null) ...[
            const SizedBox(height: 6),
            _infoRow(
              Icons.build_rounded,
              (job['services_list'] as List).join(', '),
              AppTheme.primaryLight,
            ),
          ],
          const SizedBox(height: 16),
          _buildMechanicActions(job),
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

  Widget _buildMechanicActions(Map<String, dynamic> job) {
    final status = job['status'] ?? '';
    final actions = <Widget>[];

    if (status == 'vehicle_received') {
      actions.add(
        _actionButton(
          'Mark Inspection Done',
          AppTheme.info,
          Icons.search_rounded,
          () => _showInspectionDialog(job['id']),
        ),
      );
    } else if (status == 'inspection_done') {
      actions.add(
        _actionButton(
          'Start Repair',
          _mechColor,
          Icons.build_rounded,
          () => _updateStatus(job['id'], 'in_progress'),
        ),
      );
    } else if (status == 'in_progress') {
      actions.add(
        _actionButton(
          'Complete Repair',
          AppTheme.success,
          Icons.done_all_rounded,
          () => _showCompleteDialog(job['id']),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    String jobId,
    String status, {
    String notes = '',
  }) async {
    try {
      await ApiService.post(
        '/bookings/mechanic/$jobId/update-status/',
        body: {'status': status, 'notes': notes},
      );
      _loadDashboard();
      _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Status updated!',
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

  void _showInspectionDialog(String jobId) {
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
                    '/bookings/mechanic/$jobId/update-status/',
                    body: {
                      'status': 'inspection_done',
                      'inspection_report': reportCtrl.text,
                      'estimated_cost': total.toString(),
                      'estimate_items': estimateItems,
                    },
                  );
                  _loadDashboard();
                  _loadJobs();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection Done!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating));
                  }
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

  void _showCompleteDialog(String jobId) {
    final notesCtrl = TextEditingController();
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
            Icon(Icons.check_circle_rounded, color: AppTheme.success),
            SizedBox(width: 8),
            Text(
              'Complete Service',
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
            const Text(
              'Add any final remarks about the service.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Final remarks...',
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
          ],
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
              backgroundColor: AppTheme.success,
              foregroundColor: AppTheme.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(jobId, 'completed', notes: notesCtrl.text);
            },
            child: const Text(
              'Complete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) async {
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
                        color: _mechColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: _mechColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Notifications',
                      style: TextStyle(
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
                            const Text(
                              'Caught up!',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'No new notifications',
                              style: TextStyle(color: AppTheme.textMuted),
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
                                      : _mechColor,
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
                                        style: TextStyle(
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
                                        style: const TextStyle(
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
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load notifications'),
            backgroundColor: AppTheme.error,
          ),
        );
    }
  }
}
