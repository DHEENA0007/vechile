import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
          content: Text('Please select a vehicle and services'),
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
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Booking created successfully!',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppTheme.primary,
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
          ?.cast<Map<String, dynamic>>() ?? [];

  List<Map<String, dynamic>> get timeSlots =>
      (widget.center['time_slots'] as List?)?.cast<Map<String, dynamic>>() ?? [];

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
        title: Text(
          'Book Service',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: false,
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
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppTheme.primary,
                        onSurface: AppTheme.textPrimary,
                      ),
                      canvasColor: Colors.transparent,
                    ),
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepContinue: _nextStep,
                      onStepCancel: _prevStep,
                      physics: const BouncingScrollPhysics(),
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 32, bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _currentStep == 3 ? 'Confirm Order' : 'Next Step',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ),
                              ),
                              if (_currentStep > 0) ...[
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: details.onStepCancel,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ).animate().fadeIn(),
                        );
                      },
                      steps: [
                        Step(
                          title: Text(
                            'Select Vehicle',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                if (_vehicles.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: AppTheme.radiusMedium,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.directions_car_rounded, size: 64, color: Color(0xFFCBD5E1)),
                                        const SizedBox(height: 20),
                                        Text(
                                          'No vehicle selected',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.add_circle_outline_rounded),
                                          label: Text(
                                            'Register New Vehicle',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                          ),
                                          style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn()
                                else
                                  ..._vehicles.asMap().entries.map(
                                    (entry) => GestureDetector(
                                      onTap: () => setState(() => _selectedVehicle = entry.value['id']),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: _selectedVehicle == entry.value['id'] ? const Color(0xFFEEF2FF) : Colors.white,
                                          borderRadius: AppTheme.radiusMedium,
                                          border: Border.all(
                                            color: _selectedVehicle == entry.value['id'] ? AppTheme.primary : const Color(0xFFE2E8F0),
                                            width: _selectedVehicle == entry.value['id'] ? 2 : 1,
                                          ),
                                          boxShadow: _selectedVehicle == entry.value['id'] ? null : AppTheme.softShadow,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              entry.value['vehicle_type'] == 'bike' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                                              color: _selectedVehicle == entry.value['id'] ? AppTheme.primary : const Color(0xFF94A3B8),
                                              size: 32,
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${entry.value['make']} ${entry.value['model']}',
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    entry.value['registration_number']?.toUpperCase() ?? '',
                                                    style: GoogleFonts.outfit(
                                                      color: AppTheme.textSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_selectedVehicle == entry.value['id'])
                                              const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
                                          ],
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: (entry.key * 100).ms),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Step(
                          title: Text(
                            'Select Services',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_selectedServices.length} ITEMS SELECTED',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedServices.length == services.length) {
                                            _selectedServices.clear();
                                          } else {
                                            _selectedServices.clear();
                                            _selectedServices.addAll(services.map((s) => s['id'] as String));
                                          }
                                        });
                                      },
                                      child: Text(
                                        _selectedServices.length == services.length ? 'DESELECT ALL' : 'SELECT ALL',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(),
                                const SizedBox(height: 8),
                                ...services.asMap().entries.map((entry) {
                                  final s = entry.value;
                                  final isSelected = _selectedServices.contains(s['id']);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedServices.add(s['id']);
                                          } else {
                                            _selectedServices.remove(s['id']);
                                          }
                                        });
                                      },
                                      title: Text(
                                        s['service_type_name'] ?? '',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      secondary: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primary : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₹${s['price']}',
                                          style: GoogleFonts.outfit(
                                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      activeColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      controlAffinity: ListTileControlAffinity.leading,
                                    ),
                                  ).animate().fadeIn(delay: (entry.key * 50).ms);
                                }),
                              ],
                            ),
                          ),
                        ),
                        Step(
                          title: Text(
                            'Schedule',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          isActive: _currentStep >= 2,
                          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VISIT DATE',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 90)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: AppTheme.primary,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: AppTheme.textPrimary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) setState(() => _selectedDate = date);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: AppTheme.radiusMedium,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: AppTheme.softShadow,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 28),
                                        const SizedBox(width: 16),
                                        Text(
                                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(),
                                const SizedBox(height: 24),
                                Text(
                                  'PREFERED TIME SLOT',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: timeSlots.asMap().entries.map((entry) {
                                    final slot = entry.value;
                                    final isSelected = _selectedTimeSlot == slot['id'];
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedTimeSlot = slot['id']),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primary : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: isSelected ? null : AppTheme.softShadow,
                                        ),
                                        child: Text(
                                          '${slot['start_time']} - ${slot['end_time']}',
                                          style: GoogleFonts.outfit(
                                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: (entry.key * 50).ms);
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Step(
                          title: Text(
                            'Confirmation',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          isActive: _currentStep >= 3,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
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
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 24),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Order Summary',
                                            style: GoogleFonts.outfit(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F5F9))),
                                      _summaryRow('Service Center', widget.center['name'] ?? '', Icons.store_rounded),
                                      _summaryRow('Appointment', DateFormat('MMM d, yyyy').format(_selectedDate), Icons.event_available_rounded),
                                      _summaryRow('Vehicle', _selectedVehicle != null && _vehicles.any((v) => v['id'] == _selectedVehicle) ? _vehicles.firstWhere((v) => v['id'] == _selectedVehicle)['registration_number']?.toUpperCase() ?? '' : '', Icons.directions_car_rounded),
                                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF1F5F9))),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Estimated Total',
                                            style: GoogleFonts.outfit(
                                              color: AppTheme.textSecondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${_totalCost.toStringAsFixed(0)}',
                                            style: GoogleFonts.outfit(
                                              color: AppTheme.primary,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
