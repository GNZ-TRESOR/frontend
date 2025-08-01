import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/support_ticket.dart';
import '../../core/providers/community_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class CreateSupportTicketForm extends ConsumerStatefulWidget {
  const CreateSupportTicketForm({super.key});

  @override
  ConsumerState<CreateSupportTicketForm> createState() => _CreateSupportTicketFormState();
}

class _CreateSupportTicketFormState extends ConsumerState<CreateSupportTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userPhoneController = TextEditingController();

  TicketType _selectedType = TicketType.technical;
  TicketPriority _selectedPriority = TicketPriority.medium;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                'Create Support Ticket'.at(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubjectField(),
                      const SizedBox(height: 16),
                      _buildTypeField(),
                      const SizedBox(height: 16),
                      _buildPriorityField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildContactFields(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      decoration: InputDecoration(
        labelText: 'Subject *',
        hintText: 'Brief description of your issue',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a subject';
        }
        return null;
      },
    );
  }

  Widget _buildTypeField() {
    return DropdownButtonFormField<TicketType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Ticket Type *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: TicketType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: type.name.toUpperCase().at(),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityField() {
    return DropdownButtonFormField<TicketPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: TicketPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              _getPriorityIcon(priority),
              const SizedBox(width: 8),
              priority.name.toUpperCase().at(),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Description *',
        hintText: 'Please provide detailed information about your issue',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please provide a description';
        }
        return null;
      },
    );
  }

  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'Contact Information'.at(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        'We may need to contact you for additional information'.at(
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _userEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'your.email@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _userPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: 'Cancel'.at(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _createTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.communityTeal,
              foregroundColor: Colors.white,
            ),
            child: 'Create Ticket'.at(),
          ),
        ),
      ],
    );
  }

  Widget _getPriorityIcon(TicketPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TicketPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        icon = Icons.priority_high;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }

  void _createTicket() {
    if (_formKey.currentState!.validate()) {
      final ticket = SupportTicket(
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: TicketStatus.open,
        subject: _subjectController.text.trim(),
        ticketType: _selectedType,
        userEmail: _userEmailController.text.trim().isEmpty 
            ? null 
            : _userEmailController.text.trim(),
        userPhone: _userPhoneController.text.trim().isEmpty 
            ? null 
            : _userPhoneController.text.trim(),
        userId: 1, // TODO: Get from auth provider
      );

      ref.read(supportTicketsProvider.notifier).createTicket(ticket);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: 'Support ticket created successfully!'.at(),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
