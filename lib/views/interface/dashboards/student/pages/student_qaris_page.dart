import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';
import '../widgets/qari_booking_dialog.dart';

class StudentQarisPage extends StatefulWidget {
  const StudentQarisPage({super.key});

  @override
  State<StudentQarisPage> createState() => _StudentQarisPageState();
}

class _StudentQarisPageState extends State<StudentQarisPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _minRating = 0.0;
  double _maxPrice = 100.0;
  QariSortOption _sortOption = QariSortOption.rating;

  @override
  void initState() {
    super.initState();
    _startRealTimeListening();
  }

  void _startRealTimeListening() {
    final qariProvider = context.read<QariProvider>();
    qariProvider.startListeningToVerifiedQaris();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2ECC71).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Consumer<QariProvider>(
          builder: (context, qariProvider, child) {
            return Column(
              children: [
                const SizedBox(height: 40),
                
                // Search and Filter Section
                _buildSearchAndFilterSection(),
                
                // Qaris List
                Expanded(
                  child: _buildQarisList(qariProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Qaris by bio or specialization...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Filter Row
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Rating: ${_minRating.toStringAsFixed(1)}+',
                  Icons.star,
                  () => _showRatingFilter(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterChip(
                  'Max: \$${_maxPrice.toStringAsFixed(0)}',
                  Icons.attach_money,
                  () => _showPriceFilter(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterChip(
                  _sortOption.displayName,
                  Icons.sort,
                  () => _showSortOptions(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQarisList(QariProvider qariProvider) {
    // Debug print
    print('DEBUG: QariProvider state:');
    print('  - isLoading: ${qariProvider.isLoading}');
    print('  - error: ${qariProvider.error}');
    print('  - verifiedQaris count: ${qariProvider.verifiedQaris.length}');
    print('  - verifiedQaris: ${qariProvider.verifiedQaris.map((q) => q.qariId).toList()}');
    
    if (qariProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (qariProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 15),
            Text(
              'Error loading Qaris',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              qariProvider.error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startRealTimeListening(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Apply filters
    List<QariProfile> filteredQaris = qariProvider.verifiedQaris;
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredQaris = qariProvider.searchQaris(_searchQuery);
    }
    
    // Rating filter
    if (_minRating > 0) {
      filteredQaris = filteredQaris.where((qari) => qari.rating >= _minRating).toList();
    }
    
    // Price filter
    filteredQaris = filteredQaris.where((qari) => qari.pricing <= _maxPrice).toList();
    
    // Sort
    filteredQaris = _sortQaris(filteredQaris);

    if (filteredQaris.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 15),
            Text(
              'No Qaris found',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search filters',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _startRealTimeListening(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredQaris.length,
        itemBuilder: (context, index) {
          final qari = filteredQaris[index];
          return _buildQariCard(qari);
        },
      ),
    );
  }

  Widget _buildQariCard(QariProfile qari) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    'Q',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qari ${qari.qariId.substring(0, 8)}',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < qari.rating.floor()
                                  ? Icons.star
                                  : index < qari.rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            qari.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${qari.pricing.toStringAsFixed(0)}',
                      style: GoogleFonts.merriweather(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'per hour',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Bio
            Text(
              qari.bio.isNotEmpty ? qari.bio : 'Experienced Quran teacher',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 15),
            
            // Certificates
            if (qari.certificates.isNotEmpty) ...[
              Text(
                'Certifications',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${qari.certificates.length} certificate${qari.certificates.length != 1 ? 's' : ''} verified',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF27AE60),
                ),
              ),
              const SizedBox(height: 15),
            ],
            
            // Available Slots Preview
            if (qari.availableSlots.isNotEmpty) ...[
              Text(
                'Available Times',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: qari.availableSlots.take(3).map((slot) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (qari.availableSlots.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${qari.availableSlots.length - 3} more slots',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 15),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showQariDetails(qari);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showBookingDialog(qari);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Book Session',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<QariProfile> _sortQaris(List<QariProfile> qaris) {
    switch (_sortOption) {
      case QariSortOption.rating:
        qaris.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case QariSortOption.priceLowToHigh:
        qaris.sort((a, b) => a.pricing.compareTo(b.pricing));
        break;
      case QariSortOption.priceHighToLow:
        qaris.sort((a, b) => b.pricing.compareTo(a.pricing));
        break;
    }
    return qaris;
  }

  void _showRatingFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Minimum Rating',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setModalState(() {
                        _minRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Maximum Price',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _maxPrice,
                    min: 20.0,
                    max: 200.0,
                    divisions: 18,
                    label: '\$${_maxPrice.toStringAsFixed(0)}',
                    onChanged: (value) {
                      setModalState(() {
                        _maxPrice = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort By',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...QariSortOption.values.map((option) {
                return ListTile(
                  title: Text(option.displayName),
                  leading: Radio<QariSortOption>(
                    value: option,
                    groupValue: _sortOption,
                    onChanged: (value) {
                      setState(() {
                        _sortOption = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showQariDetails(QariProfile qari) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            'Q',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qari ${qari.qariId.substring(0, 12)}',
                                style: GoogleFonts.merriweather(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < qari.rating.floor()
                                          ? Icons.star
                                          : index < qari.rating
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      size: 20,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    qari.rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Bio Section
                    Text(
                      'About',
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      qari.bio.isNotEmpty ? qari.bio : 'Experienced Quran teacher dedicated to helping students learn with proper tajweed and understanding.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Pricing Section
                    Row(
                      children: [
                        Text(
                          'Pricing: ',
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${qari.pricing.toStringAsFixed(0)} per hour',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Certificates Section
                    if (qari.certificates.isNotEmpty) ...[
                      Text(
                        'Certifications',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...qari.certificates.map((cert) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: const Color(0xFF27AE60),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cert,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 30),
                    ],
                    
                    // Available Slots Section
                    if (qari.availableSlots.isNotEmpty) ...[
                      Text(
                        'Available Time Slots',
                        style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: qari.availableSlots.map((slot) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')} - ${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                    
                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showBookingDialog(qari);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Book Session with This Qari',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(QariProfile qari) {
    showDialog(
      context: context,
      builder: (context) => QariBookingDialog(qari: qari),
    );
  }
}

// Extension to add display names for sort options
extension QariSortOptionExtension on QariSortOption {
  String get displayName {
    switch (this) {
      case QariSortOption.rating:
        return 'Rating';
      case QariSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case QariSortOption.priceHighToLow:
        return 'Price: High to Low';
    }
  }
}
