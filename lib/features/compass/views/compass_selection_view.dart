import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/compass_responsive.dart';
import '../../../config/assets_path.dart';

import '../constants/compass_ui_theme.dart';
import 'basic_compass_view.dart';
import 'personal_info_view.dart';

/// Compass Selection Screen - choose between basic and personal compass
class CompassSelectionView extends StatelessWidget {
  const CompassSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CompassUITheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Build app bar with title only
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CompassUITheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false, // This removes the back button






      title: Text(
        'La bàn phong thủy',
        style: CompassUITheme.appBarTitleStyle,
      ),
      centerTitle: true,
    );
  }

  /// Build main body content
  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(CompassUITheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: CompassUITheme.titleDescriptionSpacing),
          
          // Description text
          Text(
            'Hãy chọn la bàn phù hợp với công việc hoặc mục đích sử dụng của bạn',
            style: CompassUITheme.descriptionTextStyle.copyWith(
              height: 26.ch / CompassUITheme.descriptionTextSize, // Line height 26px
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: CompassUITheme.descriptionCardsSpacing),
          
          // Compass selection cards
          Row(
            children: [
              // Basic compass card
              Expanded(
                child: _buildCompassCard(
                  title: 'La bàn cơ bản',
                  imagePath: CompassPath.baseCompass,
                  onTap: () => Get.to(() => const BasicCompassView()),
                ),
              ),
              
              SizedBox(width: CompassUITheme.cardSpacing),
              
              // Personal compass card
              Expanded(
                child: _buildCompassCard(
                  title: 'La bàn theo tuổi',
                  imagePath: CompassPath.personalCompassKua1,
                  onTap: () => Get.to(() => const PersonalInfoView()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual compass selection card
  Widget _buildCompassCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CompassUITheme.cardBorderRadius),
          gradient: const LinearGradient(
            colors: CompassUITheme.cardBorderGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(1.cw), // 0.5px border width
        child: Container(
          decoration: BoxDecoration(
            color: CompassUITheme.cardBackground,
            borderRadius: BorderRadius.circular(CompassUITheme.cardBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: CompassUITheme.cardVerticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Real compass image
              Container(
                width: CompassUITheme.cardImageSize,
                height: CompassUITheme.cardImageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.cr),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.cr),
                  child: Image.asset(
                    imagePath,
                    width: CompassUITheme.cardImageSize,
                    height: CompassUITheme.cardImageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: CompassUITheme.cardImageSize,
                        height: CompassUITheme.cardImageSize,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12.cr),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.explore,
                          size: 60.csp,
                          color: CompassUITheme.cardLabelColor.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: CompassUITheme.cardImageTextSpacing),
              
              // Card label
              Text(
                title,
                style: CompassUITheme.cardLabelStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}