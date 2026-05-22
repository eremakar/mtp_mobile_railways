import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localization/localization.dart';
import 'package:passflow_app/pages/image_constant.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showBoardingBadge;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showBoardingBadge = false,
  });

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
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      svgAsset,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
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
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
                label: "nav-home".i18n(),
                index: 0,
              ),
              _buildNavItem(
                svgAsset: ImageConstant.shedule,
                label: "nav-schedule".i18n(),
                index: 1,
              ),
              _buildNavItem(
                svgAsset: ImageConstant.message,
                label: "services".i18n(),
                index: 2,
              ),
              _buildNavItem(
                svgAsset: ImageConstant.menu,
                label: "nav-menu".i18n(),
                index: 3,
              ),
               _buildNavItem(
                svgAsset: ImageConstant.aichat,
                label: "nav-aichat".i18n(),
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
