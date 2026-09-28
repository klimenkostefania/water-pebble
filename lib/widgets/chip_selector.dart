import 'package:flutter/material.dart';

import '../theme.dart';

/// Row of preset chips used by the settings screen.
class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.values,
    required this.selected,
    required this.onSelect,
  });

  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == values.length - 1 ? 0 : 8),
              child: _chip(values[i], values[i] == selected),
            ),
          ),
      ],
    );
  }

  Widget _chip(int value, bool active) {
    return SizedBox(
      height: 44,
      child: Material(
        color: active
            ? AppColors.primary.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelect(value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? AppColors.primary
                    : AppColors.emptyIcon.withValues(alpha: 0.5),
                width: active ? 1.5 : 1.0,
              ),
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
