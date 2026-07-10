import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../shared/app_button.dart';

class HomeworkFilterWidget extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const HomeworkFilterWidget({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<HomeworkFilterWidget> createState() => _HomeworkFilterWidgetState();
}

class _HomeworkFilterWidgetState extends State<HomeworkFilterWidget> {
  late String? selectedClass;
  late String? selectedSubject;
  late String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.initialFilters['class'];
    selectedSubject = widget.initialFilters['subject'];
    selectedStatus = widget.initialFilters['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Homework', style: AppTypography.h1),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedClass = null;
                    selectedSubject = null;
                    selectedStatus = null;
                  });
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterLabel('Class'),
          _buildChipRow(['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'], selectedClass, (val) => setState(() => selectedClass = val)),
          const SizedBox(height: 16),
          _buildFilterLabel('Subject'),
          _buildChipRow(['Math', 'Science', 'English', 'History', 'Geography', 'Marathi', 'Hindi'], selectedSubject, (val) => setState(() => selectedSubject = val)),
          const SizedBox(height: 16),
          _buildFilterLabel('Status'),
          _buildChipRow(['PENDING', 'COMPLETED'], selectedStatus, (val) => setState(() => selectedStatus = val)),
          const SizedBox(height: 32),
          AppButton(
            text: 'Apply Filters',
            onPressed: () {
              widget.onApply({
                'class': selectedClass,
                'subject': selectedSubject,
                'status': selectedStatus,
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChipRow(List<String> options, String? selectedValue, Function(String?) onSelected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValue == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? option : null);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
