import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final String hint;
  final bool enabled;
  final DateTime? value;
  final VoidCallback? onTap;

  const DatePickerField({
    required this.label,
    required this.hint,
    required this.enabled,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = value == null ? '' : DateFormat('dd.MM.yyyy').format(value!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        // Используем InkWell для клика + InputDecorator для стиля инпута
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? onTap : null,
            child: InputDecorator(
              isEmpty: text.isEmpty,
              decoration: InputDecoration(
                enabled: enabled,
                hintText: hint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                text,
                style: TextStyle(
                    color: enabled
                        ? theme.textTheme.bodyMedium?.color
                        : theme.disabledColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
