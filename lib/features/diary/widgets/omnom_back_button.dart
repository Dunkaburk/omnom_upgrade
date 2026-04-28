import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class OmnomBackButton extends StatelessWidget {
  const OmnomBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed ?? () => Navigator.maybePop(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left,
              size: 20,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
