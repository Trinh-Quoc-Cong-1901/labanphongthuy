import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/assets_path.dart';
import '../../../controllers/notification_controller.dart';

import '../constants/compass_ui_theme.dart';
import 'basic_compass_view.dart';
import 'personal_info_view.dart';
import '../../chat/views/chat_view.dart';
import '../../chat/bindings/chat_binding.dart';

/// Compass Selection Screen - choose between basic and personal compass
class CompassSelectionView extends StatelessWidget {
  const CompassSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize notification controller
    Get.put(NotificationController());

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: CompassUITheme.backgroundColor,
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: _buildChatButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
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
      actions: [
        // Notification settings button
        Container(
          margin: EdgeInsets.only(right: 8.w),
          child: Builder(
            builder: (context) {
              final notificationController = Get.find<NotificationController>();
              return Obx(() => IconButton(
                    icon: Icon(
                      notificationController.notificationsEnabled.value
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: const Color(0xFFFDC24C),
                    ),
                    onPressed: () => _showNotificationSettings(
                        context, notificationController),
                  ));
            },
          ),
        ),
      ],
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
              fontSize: 16.sp, // Responsive font size
              height: 1.6, // Simplified line height
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
                  onTap: () {
                    final notificationController =
                        Get.find<NotificationController>();
                    notificationController.trackCompassUsage();
                    Get.to(() => const BasicCompassView());
                  },
                ),
              ),

              SizedBox(width: CompassUITheme.cardSpacing),

              // Personal compass card
              Expanded(
                child: _buildCompassCard(
                  title: 'La bàn theo tuổi',
                  imagePath: CompassPath.personalCompassKua1,
                  onTap: () {
                    final notificationController =
                        Get.find<NotificationController>();
                    notificationController.trackCompassUsage();
                    Get.to(() => const PersonalInfoView());
                  },
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
        padding: EdgeInsets.all(1.w), // Responsive border width
        child: Container(
          decoration: BoxDecoration(
            color: CompassUITheme.cardBackground,
            borderRadius:
                BorderRadius.circular(CompassUITheme.cardBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 20.h, // Reduced responsive vertical padding for tablets
            horizontal:
                12.w, // Add horizontal padding to prevent content overflow
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Real compass image with better tablet support
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate appropriate image size based on available width
                  // Use smaller of width-based or fixed size to prevent overflow
                  final maxWidth =
                      constraints.maxWidth * 0.6; // 60% of available width
                  final imageSize =
                      maxWidth.clamp(80.0, 140.0); // Min 80, Max 140

                  return Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8.r,
                          spreadRadius: 2.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        imagePath,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.5),
                                width: 1.w,
                              ),
                            ),
                            child: Icon(
                              Icons.explore,
                              size: (imageSize * 0.4).clamp(24.0, 60.0),
                              color: CompassUITheme.cardLabelColor
                                  .withValues(alpha: 0.7),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h), // Responsive spacing

              // Card label
              Text(
                title,
                style: CompassUITheme.cardLabelStyle.copyWith(
                  fontSize: 16.sp, // Responsive font size
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show notification settings dialog
  void _showNotificationSettings(
      BuildContext context, NotificationController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CompassUITheme.cardBackground,
          title: Text(
            'CÀI ĐẶT THÔNG BÁO',
            textAlign: TextAlign.center,
            style: CompassUITheme.appBarTitleStyle.copyWith(
              fontSize: 18.sp, // Responsive font size
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle notifications
              Obx(() => SwitchListTile(
                    title: Text(
                      'Bật thông báo phong thủy',
                      style: CompassUITheme.descriptionTextStyle,
                    ),
                    subtitle: Text(
                      'Nhận lời khuyên và nhắc nhở hàng ngày',
                      style: CompassUITheme.descriptionTextStyle.copyWith(
                        fontSize: 12.sp, // Responsive font size
                        color: Colors.grey[600],
                      ),
                    ),
                    value: controller.notificationsEnabled.value,
                    onChanged: (value) => controller.toggleNotifications(value),
                    activeThumbColor: const Color(0xFFFDC24C),
                    contentPadding: EdgeInsets.only(right: 1.w, left: 4.w),
                  )),

              SizedBox(height: 12.h), // Responsive spacing
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Đóng',
                style: TextStyle(
                  color: const Color(0xFFFDC24C),
                  fontSize: 14.sp, // Responsive font size
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build chat floating action button
  Widget _buildChatButton() {
    return Container(
      width: 60.w, // Responsive width
      height: 60.h, // Responsive height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r), // Responsive border radius
        gradient: const LinearGradient(
          colors: [Color(0xFFFDC24C), Color(0xFFE0A800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDC24C).withValues(alpha: 0.4),
            blurRadius: 12.r, // Responsive blur
            spreadRadius: 3.r, // Responsive spread
            offset: Offset(0, 6.h), // Responsive offset
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8.r, // Responsive blur
            spreadRadius: 1.r, // Responsive spread
            offset: Offset(0, 2.h), // Responsive offset
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _openChat(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.smart_toy,
          color: const Color(0xFF2C3E50),
          size: 28.sp, // Responsive icon size
        ),
      ),
    );
  }

  /// Open chat with Phong Vân
  void _openChat() {
    Get.to(
      () => const ChatView(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
