import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/user_role.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(selected ? 0.95 : 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accentBlue : AppColors.cardBorder,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                role == UserRole.admin ? Icons.shield_outlined : Icons.groups_2,
                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
              ),
              const SizedBox(height: 14),
              Text(
                role.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                role.subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sign in ->',
                style: TextStyle(
                  color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
