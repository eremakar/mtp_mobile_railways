import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/pages/image_constant.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showBoardingBadge;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.showBoardingBadge = false,
  }) : super(key: key);

  Widget _buildNavItem({
    required String svgAsset,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isSelected = index == currentIndex;

    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    svgAsset,
                    width: 28,
                    height: 28,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                  ),
                  if (showBadge)
                    Positioned(
                      right: 0,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 211, 211, 211),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0070E0),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 13,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Row(
            children: [
              _buildNavItem(
                svgAsset: ImageConstant.home,
                label: l10n.home,
                index: 0,
              ),
              _buildNavItem(
                svgAsset: ImageConstant.receipt,
                label: l10n.boarding,
                index: 1,
              ),
              _buildNavItem(
                svgAsset: ImageConstant.menu,
                label: l10n.menu,
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
