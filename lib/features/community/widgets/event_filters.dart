import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/community_events_provider.dart';

class EventFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedEventType;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onEventTypeChanged;
  final VoidCallback onClearFilters;

  const EventFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedEventType,
    required this.onCategoryChanged,
    required this.onEventTypeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearFilters,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Category Filter
          const Text(
            'Category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableCategories.length,
              itemBuilder: (context, index) {
                final category = availableCategories[index];
                final isSelected = selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryDisplayName(category)),
                    selected: isSelected,
                    onSelected: (_) => onCategoryChanged(category),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Event Type Filter
          const Text(
            'Event Type',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableEventTypes.length,
              itemBuilder: (context, index) {
                final eventType = availableEventTypes[index];
                final isSelected = selectedEventType == eventType;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getEventTypeDisplayName(eventType)),
                    selected: isSelected,
                    onSelected: (_) => onEventTypeChanged(eventType),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All Categories';
      case 'family_planning':
        return 'Family Planning';
      case 'maternal_health':
        return 'Maternal Health';
      case 'mental_health':
        return 'Mental Health';
      case 'nutrition':
        return 'Nutrition';
      case 'general_health':
        return 'General Health';
      case 'support':
        return 'Support';
      default:
        return category;
    }
  }

  String _getEventTypeDisplayName(String eventType) {
    switch (eventType) {
      case 'all':
        return 'All Types';
      case 'workshop':
        return 'Workshop';
      case 'seminar':
        return 'Seminar';
      case 'support_group':
        return 'Support Group';
      case 'health_screening':
        return 'Health Screening';
      case 'education':
        return 'Education';
      case 'community_meeting':
        return 'Community Meeting';
      default:
        return eventType;
    }
  }
}
