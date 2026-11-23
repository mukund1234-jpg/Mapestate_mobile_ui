
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class StatusChip extends StatelessWidget {
  final String label;
  final int? foSize;
  final bool isSelected;
  final bool isTitle;
  final VoidCallback? onTap;
  Color colorBox;

  StatusChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isTitle = false,
    required this.foSize,
    this.onTap,
    required this.colorBox,
  });

  @override
  Widget build(BuildContext context) {
    if (isTitle) {
      return Text(
        label,
        style: TextStyle(
          fontSize: foSize?.toDouble(),
          fontWeight: FontWeight.w700,
          color: Colors.blue,
        ),
      );
    }

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:  Colors.white ,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? colorBox : Colors.transparent,
          width: isSelected ? 1.5 : 0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorBox : Colors.black54,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: foSize?.toDouble(),
        ),
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: chip,
    );
  }
}
