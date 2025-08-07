import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Professional Support Groups Screen
class SupportGroupsScreen extends ConsumerStatefulWidget {
  const SupportGroupsScreen({super.key});

  @override
  ConsumerState<SupportGroupsScreen> createState() =>
      _SupportGroupsScreenState();
}

class _SupportGroupsScreenState extends ConsumerState<SupportGroupsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support Groups'),
        backgroundColor: AppColors.supportPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Discover'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyGroupsTab(),
            _buildDiscoverTab(),
            _buildMessagesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroupsTab() {
    // Mock data for demonstration
    final myGroups = [
      {
        'name': 'First Time Mothers',
        'description': 'Support for new mothers navigating pregnancy',
        'members': 245,
        'lastActivity': '2 hours ago',
        'unreadMessages': 3,
        'isPrivate': false,
      },
      {
        'name': 'Family Planning Support',
        'description': 'Discussing contraception and family planning',
        'members': 189,
        'lastActivity': '1 day ago',
        'unreadMessages': 0,
        'isPrivate': true,
      },
    ];

    if (myGroups.isEmpty) {
      return _buildEmptyState(
        'No groups joined yet',
        'Discover and join support groups to connect with others',
        Icons.group_add,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh groups from API
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myGroups.length,
        itemBuilder: (context, index) {
          final group = myGroups[index];
          return _buildGroupCard(group, isJoined: true);
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    // Mock data for available groups
    final availableGroups = [
      {
        'name': 'Pregnancy After 35',
        'description': 'Support for women having babies after 35',
        'members': 156,
        'lastActivity': '3 hours ago',
        'unreadMessages': 0,
        'isPrivate': false,
      },
      {
        'name': 'Breastfeeding Support',
        'description': 'Tips and support for breastfeeding mothers',
        'members': 298,
        'lastActivity': '30 minutes ago',
        'unreadMessages': 0,
        'isPrivate': false,
      },
      {
        'name': 'Mental Health & Pregnancy',
        'description': 'Supporting mental wellness during pregnancy',
        'members': 134,
        'lastActivity': '1 hour ago',
        'unreadMessages': 0,
        'isPrivate': true,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...availableGroups.map(
            (group) => _buildGroupCard(group, isJoined: false),
          ),
          const SizedBox(height: 24),
          Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoriesGrid(),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    // Mock data for recent messages
    final recentMessages = [
      {
        'groupName': 'First Time Mothers',
        'lastMessage': 'Thanks for the advice about morning sickness!',
        'sender': 'Sarah M.',
        'time': '2 hours ago',
        'unread': 3,
        'isGroup': true,
      },
      {
        'groupName': 'Dr. Emily Johnson',
        'lastMessage': 'Your test results look great. Keep up the good work!',
        'sender': 'Dr. Emily',
        'time': '1 day ago',
        'unread': 1,
        'isGroup': false,
      },
    ];

    if (recentMessages.isEmpty) {
      return _buildEmptyState(
        'No messages yet',
        'Start conversations in your support groups',
        Icons.message,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentMessages.length,
      itemBuilder: (context, index) {
        final message = recentMessages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, {required bool isJoined}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openGroup(group['name']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.supportPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      group['isPrivate'] ? Icons.lock : Icons.group,
                      color: AppColors.supportPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (group['unreadMessages'] > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${group['unreadMessages']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${group['members']} members',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    group['lastActivity'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (!isJoined)
                    ElevatedButton(
                      onPressed: () => _joinGroup(group['name']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.supportPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Join', style: TextStyle(fontSize: 12)),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => _leaveGroup(group['name']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Leave',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name': 'Pregnancy',
        'icon': Icons.pregnant_woman,
        'color': AppColors.pregnancyPurple,
      },
      {
        'name': 'New Mothers',
        'icon': Icons.child_care,
        'color': AppColors.primary,
      },
      {
        'name': 'Family Planning',
        'icon': Icons.family_restroom,
        'color': AppColors.secondary,
      },
      {
        'name': 'Mental Health',
        'icon': Icons.psychology,
        'color': AppColors.success,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      child: InkWell(
        onTap: () => _browseCategory(category['name']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openChat(message['groupName']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.supportPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  message['isGroup'] ? Icons.group : Icons.person,
                  color: AppColors.supportPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message['groupName'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (message['unread'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${message['unread']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['lastMessage'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          message['sender'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          ' • ${message['time']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action methods - Clients can only join/leave groups created by health workers

  void _openGroup(String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(groupName: groupName),
      ),
    );
  }

  Future<void> _joinGroup(String groupName) async {
    try {
      // In a real implementation, you would get the group ID and call the API
      // final response = await ApiService.instance.joinSupportGroup(groupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined $groupName successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Refresh the groups list
        setState(() {
          // Move group from discover to my groups in mock data
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining group: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup(String groupName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Support Group'),
            content: Text('Are you sure you want to leave "$groupName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Leave'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        // In a real implementation, you would get the group ID and call the API
        // final response = await ApiService.instance.leaveSupportGroup(groupId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left $groupName successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          // Refresh the groups list
          setState(() {
            // Move group from my groups to discover in mock data
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error leaving group: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _browseCategory(String categoryName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Browsing $categoryName groups')));
  }

  void _openChat(String chatName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(groupName: chatName),
      ),
    );
  }
}

// Group Chat Screen
class GroupChatScreen extends StatefulWidget {
  final String groupName;

  const GroupChatScreen({super.key, required this.groupName});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Sarah M.',
      'message': 'Thanks for all the support everyone! 💕',
      'time': '2:30 PM',
      'isMe': false,
    },
    {
      'sender': 'You',
      'message': 'How is everyone feeling today?',
      'time': '2:25 PM',
      'isMe': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: AppColors.supportPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showGroupInfo(),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.supportPurple : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message['sender'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.supportPurple,
                ),
              ),
            Text(
              message['message'],
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['time'],
              style: TextStyle(
                fontSize: 12,
                color:
                    isMe
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppColors.supportPurple,
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.insert(0, {
          'sender': 'You',
          'message': _messageController.text.trim(),
          'time': 'Now',
          'isMe': true,
        });
      });
      _messageController.clear();
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.groupName),
            content: const Text('Group information and settings'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
