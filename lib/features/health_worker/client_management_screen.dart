import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/models/health_record_model.dart';
import '../../core/services/real_data_service.dart';
import '../../widgets/voice_button.dart';
import '../messaging/enhanced_chat_screen.dart';
import 'client_details_screen.dart';

class ClientManagementScreen extends StatefulWidget {
  final User healthWorker;

  const ClientManagementScreen({super.key, required this.healthWorker});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _clients = [];
  List<User> _filteredClients = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'all',
    'active',
    'pregnant',
    'family_planning',
    'high_risk',
  ];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load clients using RealDataService
      final realDataService = RealDataService();

      // Initialize service if not already done
      if (!realDataService.isConnected) {
        await realDataService.initialize();
      }

      // Get all users with CLIENT role
      final allUsers = await realDataService.getAllUsers();
      _clients =
          allUsers.where((user) => user.role == UserRole.client).toList();

      _filteredClients = _clients;
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka abakiriya');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients =
          _clients.where((client) {
            final matchesSearch =
                client.name.toLowerCase().contains(query) ||
                client.phone.contains(query) ||
                (client.email.toLowerCase().contains(query));

            final matchesFilter =
                _selectedFilter == 'all' ||
                _getClientCategory(client) == _selectedFilter;

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  String _getClientCategory(User client) {
    // TODO: Implement based on health records
    final random = client.id.hashCode % 4;
    switch (random) {
      case 0:
        return 'active';
      case 1:
        return 'pregnant';
      case 2:
        return 'family_planning';
      case 3:
        return 'high_risk';
      default:
        return 'active';
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('shakisha') || lowerCommand.contains('search')) {
      // Focus search field
      FocusScope.of(context).requestFocus();
    } else if (lowerCommand.contains('inda') ||
        lowerCommand.contains('pregnant')) {
      _setFilter('pregnant');
    } else if (lowerCommand.contains('gahunda') ||
        lowerCommand.contains('planning')) {
      _setFilter('family_planning');
    } else if (lowerCommand.contains('byose') || lowerCommand.contains('all')) {
      _setFilter('all');
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterClients();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gucunga abakiriya'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: Add new client
              _showErrorSnackBar('Kongeramo umukiriya - Izaza vuba');
            },
            tooltip: 'Kongeramo umukiriya',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(isTablet),

          // Clients list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildClientsList(isTablet),
          ),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Shakisha" kugira ngo ushake, "Inda" kugira ngo ugere ku bafite inda, cyangwa "Gahunda" kugira ngo ugere ku bafite gahunda y\'umuryango',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushaka',
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Shakisha abakiriya...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),

          SizedBox(height: AppTheme.spacing12),

          // Filter chips
          SizedBox(
            height: isTablet ? 50 : 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;

                return Container(
                  margin: EdgeInsets.only(right: AppTheme.spacing8),
                  child: FilterChip(
                    label: Text(_getFilterLabel(filter)),
                    selected: isSelected,
                    onSelected: (selected) => _setFilter(filter),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: AppTheme.bodySmall.copyWith(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, duration: 600.ms);
  }

  Widget _buildClientsList(bool isTablet) {
    if (_filteredClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta bakiriya baboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'Gerageza guhindura amashakiro yawe',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return _buildClientCard(client, isTablet, index);
      },
    );
  }

  Widget _buildClientCard(User client, bool isTablet, int index) {
    final category = _getClientCategory(client);
    final categoryColor = _getCategoryColor(category);
    final isOnline =
        client.lastLoginAt != null &&
        DateTime.now().difference(client.lastLoginAt!).inHours < 24;

    return Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _viewClientDetails(client),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                ),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 28 : 24,
                          backgroundColor: categoryColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person_rounded,
                            color: categoryColor,
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: isTablet ? 12 : 10,
                              height: isTablet ? 12 : 10,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 6 : 5,
                                ),
                                border: Border.all(
                                  color: AppTheme.surfaceColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: AppTheme.spacing16),

                    // Client info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  client.name,
                                  style: AppTheme.labelLarge.copyWith(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing8,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.spacing4,
                                  ),
                                ),
                                child: Text(
                                  _getCategoryLabel(category),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 10 : 8,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppTheme.spacing4),

                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: isTablet ? 16 : 14,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: AppTheme.spacing4),
                              Text(
                                client.phone,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppTheme.spacing4),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: isTablet ? 16 : 14,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: AppTheme.spacing4),
                              Expanded(
                                child: Text(
                                  '${client.cell}, ${client.sector}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: isTablet ? 12 : 10,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (client.lastLoginAt != null) ...[
                            SizedBox(height: AppTheme.spacing4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: isTablet ? 16 : 14,
                                  color: AppTheme.textTertiary,
                                ),
                                SizedBox(width: AppTheme.spacing4),
                                Text(
                                  _getLastSeenText(client.lastLoginAt!),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textTertiary,
                                    fontSize: isTablet ? 12 : 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action buttons
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chat_rounded,
                            color: AppTheme.primaryColor,
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: () => _startChat(client),
                          tooltip: 'Tanga ubutumwa',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.call_rounded,
                            color: AppTheme.secondaryColor,
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: () => _callClient(client),
                          tooltip: 'Hamagara',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn()
        .slideX(begin: -0.3, duration: 600.ms);
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Byose';
      case 'active':
        return 'Bakora';
      case 'pregnant':
        return 'Bafite inda';
      case 'family_planning':
        return 'Gahunda y\'umuryango';
      case 'high_risk':
        return 'Mu kaga';
      default:
        return filter;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'active':
        return 'Akora';
      case 'pregnant':
        return 'Afite inda';
      case 'family_planning':
        return 'Gahunda';
      case 'high_risk':
        return 'Mu kaga';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'active':
        return AppTheme.successColor;
      case 'pregnant':
        return AppTheme.accentColor;
      case 'family_planning':
        return AppTheme.primaryColor;
      case 'high_risk':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getLastSeenText(DateTime lastSeen) {
    final difference = DateTime.now().difference(lastSeen);

    if (difference.inMinutes < 60) {
      return 'Yabonetse ${difference.inMinutes} iminota ishize';
    } else if (difference.inHours < 24) {
      return 'Yabonetse ${difference.inHours} isaha ishize';
    } else {
      return 'Yabonetse ${difference.inDays} umunsi ushize';
    }
  }

  void _viewClientDetails(User client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ClientDetailsScreen(
              client: client,
              healthWorker: widget.healthWorker,
            ),
      ),
    );
  }

  void _startChat(User client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EnhancedChatScreen(
              contact: HealthWorker(
                id: 'hw_${client.id}',
                name: 'Health Worker',
                specialization: 'General',
                facilityId: '',
                phone: '+250788123456',
                email: 'healthworker@health.gov.rw',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
      ),
    );
  }

  void _callClient(User client) {
    // TODO: Implement phone call
    _showErrorSnackBar('Guhamagara - Izaza vuba');
  }
}
