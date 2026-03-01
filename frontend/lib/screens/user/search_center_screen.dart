import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import 'center_detail_screen.dart';

class SearchCenterScreen extends StatefulWidget {
  const SearchCenterScreen({super.key});

  @override
  State<SearchCenterScreen> createState() => _SearchCenterScreenState();
}

class _SearchCenterScreenState extends State<SearchCenterScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _centers = [];
  List<dynamic> _serviceTypes = [];
  bool _isLoading = false;
  String? _selectedServiceType;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
    _searchCenters();
  }

  Future<void> _loadServiceTypes() async {
    try {
      final data = await ApiService.get('/services/types/');
      setState(() => _serviceTypes = data['results'] ?? []);
    } catch (_) {}
  }

  Future<void> _searchCenters() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, String>{};
      if (_searchController.text.isNotEmpty) {
        params['search'] = _searchController.text;
      }
      if (_selectedServiceType != null) {
        params['service_type'] = _selectedServiceType!;
      }
      if (_minRating != null) {
        params['min_rating'] = _minRating.toString();
      }
      final data = await ApiService.get('/services/search/', params: params);
      setState(() {
        _centers = data['results'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Find Service Centers',
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
          // Ambient Glow
          Positioned(
            top: 50,
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
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardLight.withValues(alpha: 0.5),
                            borderRadius: AppTheme.borderRadius,
                            border: Border.all(
                              color: AppTheme.textPrimary.withValues(
                                alpha: 0.05,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name or city...',
                              hintStyle: const TextStyle(
                                color: AppTheme.textMuted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.accent,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: AppTheme.textMuted,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _searchCenters();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: (_) => _searchCenters(),
                          ),
                        ),
                      ).animate().slideX(begin: -0.1),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: AppTheme.borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: AppTheme.borderRadius,
                            onTap: _showFilters,
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.tune_rounded,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(delay: 100.ms),
                    ],
                  ),
                ),

                // Filters chips
                if (_selectedServiceType != null || _minRating != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (_selectedServiceType != null)
                          _buildFilterChip(
                            'Service Type',
                            () => setState(() {
                              _selectedServiceType = null;
                              _searchCenters();
                            }),
                          ),
                        if (_minRating != null)
                          _buildFilterChip(
                            '${_minRating!.toInt()}+ ⭐',
                            () => setState(() {
                              _minRating = null;
                              _searchCenters();
                            }),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(),

                // Results
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                          ),
                        )
                      : _centers.isEmpty
                      ? const EmptyState(
                          icon: Icons.store_mall_directory_rounded,
                          title: 'No Service Centers Found',
                          message: 'Try adjusting your search or filters',
                        ).animate().fadeIn()
                      : RefreshIndicator(
                          onRefresh: _searchCenters,
                          color: AppTheme.accent,
                          backgroundColor: AppTheme.bgCard,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              100,
                            ), // padding for bottom nav
                            itemCount: _centers.length,
                            itemBuilder: (_, i) => _buildCenterCard(_centers[i])
                                .animate()
                                .fadeIn(delay: (i * 50).ms)
                                .slideY(begin: 0.1),
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

  Widget _buildCenterCard(Map<String, dynamic> center) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CenterDetailScreen(centerId: center['id']),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: AppTheme.textPrimary,
                  size: 32,
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
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingStars(
                          rating: (center['average_rating'] ?? 0).toDouble(),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${center['total_reviews'] ?? 0} reviews)',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (center['distance'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${center['distance']} km',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppTheme.textMuted, height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.primaryLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${center['address'] ?? ''}, ${center['city'] ?? ''}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: AppTheme.warning,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${center['opening_time'] ?? ''} - ${center['closing_time'] ?? ''}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${center['services_count'] ?? 0} services',
                  style: const TextStyle(
                    color: AppTheme.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppTheme.accent,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.15),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Service Type',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _serviceTypes
                    .map(
                      (st) => ChoiceChip(
                        label: Text(
                          st['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        selected: _selectedServiceType == st['id'],
                        selectedColor: AppTheme.accent,
                        backgroundColor: AppTheme.bgCardLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedServiceType == st['id']
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedServiceType = selected ? st['id'] : null;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 32),

              const Text(
                'Minimum Rating',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [3.0, 3.5, 4.0, 4.5]
                    .map(
                      (rating) => ChoiceChip(
                        label: Text(
                          '$rating+ ⭐',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        selected: _minRating == rating,
                        selectedColor: AppTheme.accent,
                        backgroundColor: AppTheme.bgCardLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: TextStyle(
                          color: _minRating == rating
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            _minRating = selected ? rating : null;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 48),

              GradientButton(
                text: 'Apply Filters',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                  _searchCenters();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
