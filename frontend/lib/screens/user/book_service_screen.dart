import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class BookServiceScreen extends StatefulWidget {
  final Map<String, dynamic> center;
  const BookServiceScreen({super.key, required this.center});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  List<dynamic> _vehicles = [];
  String? _selectedVehicle;
  final List<String> _selectedServices = [];
  String? _selectedTimeSlot;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _descriptionCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/accounts/vehicles/');
      setState(() {
        _vehicles = data['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookService() async {
    if (_selectedVehicle == null || _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a vehicle and services',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.post(
        '/bookings/user/create/',
        body: {
          'vehicle': _selectedVehicle,
          'service_center': widget.center['id'],
          'service_ids': _selectedServices,
          'time_slot': _selectedTimeSlot,
          'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'problem_description': _descriptionCtrl.text,
        },
      );

      if (mounted) {
        Navigator.pop(context); // Pop book screen
        Navigator.pop(context); // Pop detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Booking created successfully!',
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
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get services =>
      (widget.center['offered_services'] as List?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  List<Map<String, dynamic>> get timeSlots =>
      (widget.center['time_slots'] as List?)?.cast<Map<String, dynamic>>() ??
      [];

  double get _totalCost {
    double total = 0;
    for (var s in services) {
      if (_selectedServices.contains(s['id'])) {
        total += double.tryParse(s['price'].toString()) ?? 0;
      }
    }
    return total;
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle first'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentStep == 1 && _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentStep == 2 && _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _bookService();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
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
            top: 100,
            right: -50,
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

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.accent,
                        onSurface: AppTheme.textPrimary,
                      ),
                      canvasColor: Colors.transparent,
                    ),
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepContinue: _nextStep,
                      onStepCancel: _prevStep,
                      physics: const BouncingScrollPhysics(),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  text: _currentStep == 3
                                      ? 'Confirm Booking'
                                      : 'Continue',
                                  icon: _currentStep == 3
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  isLoading: _isSubmitting,
                                  onPressed: details.onStepContinue,
                                ),
                              ),
                              if (_currentStep > 0) ...[
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: details.onStepCancel,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: AppTheme.bgCardLight
                                        .withValues(alpha: 0.5),
                                  ),
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        );
                      },
                      steps: [
                        // Step 1: Select Vehicle
                        Step(
                          title: Text(
                            'Select Vehicle',
                            style: TextStyle(
                              color: _currentStep == 0
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                              fontWeight: _currentStep == 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0
                              ? StepState.complete
                              : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                if (_vehicles.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCardLight.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.textPrimary.withValues(
                                          alpha: 0.05,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.directions_car_rounded,
                                          size: 48,
                                          color: AppTheme.textMuted,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No vehicles added yet',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.add_rounded),
                                          label: const Text('Add Vehicle'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryLight,
                                            foregroundColor:
                                                AppTheme.textPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              () {}, // Navigate to add vehicle
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn()
                                else
                                  ..._vehicles.asMap().entries.map(
                                    (entry) => GlassCard(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      onTap: () => setState(
                                        () => _selectedVehicle =
                                            entry.value['id'],
                                      ),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: entry.value['id'],
                                            groupValue: _selectedVehicle,
                                            onChanged: (val) => setState(
                                              () => _selectedVehicle = val,
                                            ),
                                            activeColor: AppTheme.accent,
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  _selectedVehicle ==
                                                      entry.value['id']
                                                  ? AppTheme.accent.withValues(
                                                      alpha: 0.2,
                                                    )
                                                  : AppTheme.bgCardLight,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              entry.value['vehicle_type'] ==
                                                      'bike'
                                                  ? Icons.two_wheeler_rounded
                                                  : Icons
                                                        .directions_car_rounded,
                                              color:
                                                  _selectedVehicle ==
                                                      entry.value['id']
                                                  ? AppTheme.accent
                                                  : AppTheme.textMuted,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${entry.value['make']} ${entry.value['model']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                    color:
                                                        _selectedVehicle ==
                                                            entry.value['id']
                                                        ? AppTheme.textPrimary
                                                        : AppTheme.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  entry.value['registration_number'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: AppTheme.textMuted,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: (entry.key * 100).ms).slideX(begin: 0.1),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Step 2: Select Services
                        Step(
                          title: Text(
                            'Select Services',
                            style: TextStyle(
                              color: _currentStep == 1
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                              fontWeight: _currentStep == 1
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1
                              ? StepState.complete
                              : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_selectedServices.length} selected',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedServices.length ==
                                              services.length) {
                                            _selectedServices.clear();
                                          } else {
                                            _selectedServices.clear();
                                            _selectedServices.addAll(
                                              services.map(
                                                (s) => s['id'] as String,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        _selectedServices.length ==
                                                services.length
                                            ? Icons.deselect_rounded
                                            : Icons.select_all_rounded,
                                        color: AppTheme.accent,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _selectedServices.length ==
                                                services.length
                                            ? 'Clear All'
                                            : 'Select All',
                                        style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(),
                                const SizedBox(height: 8),
                                ...services.asMap().entries.map((entry) {
                                  final s = entry.value;
                                  final isSelected = _selectedServices.contains(
                                    s['id'],
                                  );
                                  return GlassCard(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedServices.remove(s['id']);
                                            } else {
                                              _selectedServices.add(s['id']);
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    _selectedServices.add(
                                                      s['id'],
                                                    );
                                                  } else {
                                                    _selectedServices.remove(
                                                      s['id'],
                                                    );
                                                  }
                                                });
                                              },
                                              activeColor: AppTheme.accent,
                                              checkColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                s['service_type_name'] ?? '',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppTheme.textPrimary
                                                      : AppTheme.textPrimary,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppTheme.accent
                                                          .withValues(
                                                            alpha: 0.15,
                                                          )
                                                    : AppTheme.bgCardLight,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '₹${s['price']}',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppTheme.accent
                                                      : AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: (entry.key * 50).ms)
                                      .scale(begin: const Offset(0.95, 0.95));
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Step 3: Date & Time
                        Step(
                          title: Text(
                            'Schedule',
                            style: TextStyle(
                              color: _currentStep == 2
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                              fontWeight: _currentStep == 2
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          isActive: _currentStep >= 2,
                          state: _currentStep > 2
                              ? StepState.complete
                              : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 90),
                                      ),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: AppTheme.accent,
                                              onPrimary: Colors.black,
                                              surface: AppTheme.bgCard,
                                              onSurface: AppTheme.textPrimary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) {
                                      setState(() => _selectedDate = date);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .primaryGradient
                                              .colors[0]
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: AppTheme.primaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        DateFormat(
                                          'EEEE, MMM d, yyyy',
                                        ).format(_selectedDate),
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.edit_calendar_rounded,
                                        color: AppTheme.textMuted,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(),

                                const SizedBox(height: 24),
                                const Text(
                                  'Time Slot',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: timeSlots.asMap().entries.map((
                                    entry,
                                  ) {
                                    final slot = entry.value;
                                    final isSelected =
                                        _selectedTimeSlot == slot['id'];
                                    return GestureDetector(
                                          onTap: () => setState(
                                            () =>
                                                _selectedTimeSlot = slot['id'],
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? AppTheme.primaryGradient
                                                  : null,
                                              color: isSelected
                                                  ? null
                                                  : AppTheme.bgCardLight
                                                        .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppTheme.primaryLight
                                                    : AppTheme.textPrimary
                                                          .withValues(
                                                            alpha: 0.05,
                                                          ),
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: AppTheme.primary
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              '${slot['start_time']} - ${slot['end_time']}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textSecondary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w900
                                                    : FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: (entry.key * 50).ms)
                                        .scale(begin: const Offset(0.9, 0.9));
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Step 4: Confirm
                        Step(
                          title: Text(
                            'Review',
                            style: TextStyle(
                              color: _currentStep == 3
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                              fontWeight: _currentStep == 3
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          isActive: _currentStep >= 3,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                GlassCard(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.receipt_long_rounded,
                                            color: AppTheme.accent,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Order Summary',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        height: 1,
                                        color: AppTheme.textMuted.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _summaryRow(
                                        'Service Center',
                                        widget.center['name'] ?? '',
                                        Icons.store_rounded,
                                      ),
                                      _summaryRow(
                                        'Date',
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(_selectedDate),
                                        Icons.event_rounded,
                                      ),
                                      _summaryRow(
                                        'Services',
                                        '${_selectedServices.length} selected items',
                                        Icons.miscellaneous_services_rounded,
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        height: 1,
                                        color: AppTheme.textMuted.withValues(
                                          alpha: 0.15,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Estimated',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '₹${_totalCost.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppTheme.accent,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              shadows: [
                                                Shadow(
                                                  color: AppTheme.accent,
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).animate().slideY(begin: 0.2),
                                const SizedBox(height: 24),
                                GlassCard(
                                  padding: const EdgeInsets.all(4),
                                  child: TextField(
                                    controller: _descriptionCtrl,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Any specific problems? Mention them here...',
                                      hintStyle: const TextStyle(
                                        color: AppTheme.textMuted,
                                      ),
                                      labelText: 'Extra Notes (Optional)',
                                      labelStyle: const TextStyle(
                                        color: AppTheme.primaryLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.bgCardLight
                                          .withValues(alpha: 0.3),
                                    ),
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ).animate().slideY(begin: 0.3, delay: 100.ms),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
