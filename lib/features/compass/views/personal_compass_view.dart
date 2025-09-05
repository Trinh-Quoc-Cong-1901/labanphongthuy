import '../models/feng_shui_result.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import '../utils/compass_responsive.dart';
import '../../../config/assets_path.dart';

import '../controllers/compass_controller.dart';
import '../constants/compass_ui_theme.dart';
import '../widgets/personal_zoomable_image_compass.dart';
import 'personal_compass_detail_view.dart';

class PersonalCompassView extends StatelessWidget {
  const PersonalCompassView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompassController>();
    
    return Scaffold(
        backgroundColor: CompassUITheme.backgroundColor,
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: false, // Prevent resize when keyboard shows
        body: Column(
          children: [
            // Main content area with SafeArea for top only
            Expanded(
              child: SafeArea(
                bottom: false, // Don't apply SafeArea to bottom
                child: Screenshot(
                  controller: controller.screenshotController,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF020931), // Match app background for clean screenshot
                    child: Column(
                      children: [
                        // Top heading display section with Feng Shui info
                        _buildHeadingDisplaySection(controller),
                        
                        // Main Compass Area - Fixed spacing layout with overflow protection
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(), // Disable scroll but prevent overflow
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Compass widget - fixed size
                                      _buildCompassSection(controller),
                                      
                                      // Fixed gap below compass
                                      SizedBox(height: 36.ch),
                                      
                                      // Direction meaning text
                                      _buildDirectionMeaningText(controller),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom action buttons - OUTSIDE SafeArea to stick to bottom
            _buildBottomActionButtons(context, controller),
          ],
        ),
      );
  }

  /// Build top heading display section with Feng Shui direction info
  Widget _buildHeadingDisplaySection(CompassController controller) {
    // Adjust height based on screen size to prevent overlap
    final isSmallScreen = CompassResponsive.screenHeight < 700;
    final sectionHeight = isSmallScreen ? 100.ch : 140.ch;
    
    return SizedBox(
      height: sectionHeight,
      child: Stack(
        children: [
          // Column with degree box and direction text - positioned with proper spacing from app bar
          Positioned(
            top: isSmallScreen ? 10.ch : 27.ch, // Adjust top spacing for small screens
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading display box - Fixed 86px width, 40px height
                Container(
                  width: 86.cw,
                  height: 40.ch,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99.cr),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFDC24C),
                        Color(0xFFFCF5D0),
                        Color(0xFFD78F40),
                        Color(0xFFFFFACA),
                        Color(0xFFD78F40),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(1.cw), // Inner border effect
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99.cr),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF101847),
                          Color(0xFF303C7B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 8.ch),
                    child: Center(
                      child: Obx(() {
                        final heading = controller.compassData.heading;
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFEFFEF3),
                                Color(0xFFF2D983),
                                Color(0xFFE2BA5A),
                                Color(0xFFDCC16D),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  heading.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 20.csp,
                                    fontWeight: FontWeight.w600,
                                    height: 24.ch / 20.csp,
                                    letterSpacing: 0,
                                    color: Colors.white,
                                    fontFamily: 'SVN Gilroy',
                                  ),
                                ),
                                Text(
                                  '°',
                                  style: TextStyle(
                                    fontSize: 20.csp,
                                    fontWeight: FontWeight.w600,
                                    height: 24.ch / 20.csp,
                                    letterSpacing: 0,
                                    color: Colors.white,
                                    fontFamily: 'SVN Gilroy',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                // Gap 16px between degree box and direction text
                SizedBox(height: 16.ch),
                
                // Direction text (basic direction only, feng shui info moved below compass)
                Obx(() => Text(
                  'Hướng: ${controller.currentDirection?.vietnameseName ?? '--'} (${controller.currentDirection?.chineseName ?? '--'})',
                  style: TextStyle(
                    fontSize: 24.csp, // Font size 24
                    fontWeight: FontWeight.w700, // Weight 700
                    color: const Color(0xFFFFCD45), // Gold color
                    fontFamily: 'SVN Gilroy',
                  ),
                  textAlign: TextAlign.center,
                )),
              ],
            ),
          ),
          
          // Lock icon button - positioned at top:27, right:16
          Positioned(
            top: isSmallScreen ? 10.ch : 27.ch,
            right: 16.cw,
            child: Container(
              width: 40.cw,
              height: 40.cw,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99.cr),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFDC24C),
                    Color(0xFFFCF5D0),
                    Color(0xFFD78F40),
                    Color(0xFFFFFACA),
                    Color(0xFFD78F40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(1.cw), // Inner border effect
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99.cr),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF101847),
                      Color(0xFF303C7B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99.cr),
                    onTap: () => controller.toggleRotationLock(),
                    child: Padding(
                      padding: EdgeInsets.all(8.cw),
                      child: Obx(() => ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFF5E29F),
                            Color(0xFFDEC87D),
                            Color(0xFFD3AA45),
                            Color(0xFFF2DC98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Image.asset(
                          controller.isRotationLocked 
                            ? CompassPath.lockIcon
                            : CompassPath.unlockIcon,
                          width: 20.cw,
                          height: 20.cw,
                          color: Colors.white, // Will be masked by gradient
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CompassUITheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: CompassUITheme.primaryTextColor,
        ),
      ),
      title: Text(
        'La bàn theo tuổi',
        style: CompassUITheme.appBarTitleStyle,
      ),
      centerTitle: true, // Center aligned
      // No trailing actions for personal compass
    );
  }

  Widget _buildCompassSection(CompassController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.cw), // Only 8px horizontal padding
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0, // Perfect square
          child: LayoutBuilder(
            builder: (context, constraints) {
              return PersonalZoomableImageCompass(
                size: (MediaQuery.of(context).size.width - 16.cw), // Full width minus padding
                minZoom: 1.0,
                maxZoom: 3.0,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build bottom action buttons with personal info display - sticky container 80px height
  Widget _buildBottomActionButtons(BuildContext context, CompassController controller) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      width: double.infinity, // Full width to cover entire screen
      height: 80.ch + bottomPadding, // Fixed height 80px + safe area bottom
      decoration: BoxDecoration(
        color: const Color(0xFF020931), // Background color
        border: Border(
          top: BorderSide(
            color: const Color(0xFF7E88C3).withOpacity(0.5), // Top border 50% opacity
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 19.cw,
          right: 19.cw,
          top: 20.ch,
          bottom: 20.ch + bottomPadding, // Add safe area to bottom padding
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Zoom controls
            Row(
              children: [
                // Zoom Out button
                _buildCircleButton(
                  iconAsset: CompassPath.zoomOutIcon,
                  onTap: () => controller.triggerZoomOut(),
                ),
                
                // Gap 12px between icons
                SizedBox(width: 12.cw),
                
                // Zoom In button
                _buildCircleButton(
                  iconAsset: CompassPath.zoomInIcon,
                  onTap: () => controller.triggerZoomIn(),
                ),
              ],
            ),
            
            // Center: Personal info display - "Nam 2002" style
            Obx(() {
              if (controller.hasPersonalInfo) {
                final genderText = controller.isMale ? 'Nam' : 'Nữ';
                final yearText = controller.birthYear.toString();
                return Text(
                  '$genderText $yearText',
                  style: TextStyle(
                    fontSize: 20.csp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFDB60), // Color as requested #FFDB60
                    fontFamily: 'SVN Gilroy',
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Right side: Screenshot and Detail buttons
            Row(
              children: [
                // Screenshot button with loading indicator
                Obx(() => controller.isCapturingScreenshot
                  ? Container(
                      width: 40.cw,
                      height: 40.cw,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99.cr),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFDC24C),
                            Color(0xFFFCF5D0),
                            Color(0xFFD78F40),
                            Color(0xFFFFFACA),
                            Color(0xFFD78F40),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(1.cw),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99.cr),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF101847),
                              Color(0xFF303C7B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 20.cw,
                            height: 20.cw,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF5E29F),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : _buildCircleButton(
                      iconAsset: CompassPath.screenshotIcon,
                      onTap: () => _takeScreenshot(controller),
                    ),
                ),
                
                // Gap 12px between icons
                SizedBox(width: 12.cw),
                
                // Detail button
                _buildCircleButton(
                  iconAsset: CompassPath.detailIcon,
                  onTap: () => _navigateToDetail(controller),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build circle button with consistent styling (same as BasicCompassView)
  Widget _buildCircleButton({
    IconData? icon,
    String? iconAsset,
    required VoidCallback onTap,
  }) {
    // Use minimum of width/height scale to ensure buttons stay circular
    final buttonSize = 40 * (CompassResponsive.scaleWidth < CompassResponsive.scaleHeight 
        ? CompassResponsive.scaleWidth 
        : CompassResponsive.scaleHeight);
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99.cr),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFDC24C),
            Color(0xFFFCF5D0),
            Color(0xFFD78F40),
            Color(0xFFFFFACA),
            Color(0xFFD78F40),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(1.cw), // Inner border effect
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99.cr),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF101847),
              Color(0xFF303C7B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(99.cr),
            onTap: onTap,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFF5E29F),
                  Color(0xFFDEC87D),
                  Color(0xFFD3AA45),
                  Color(0xFFF2DC98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: iconAsset != null
                ? Image.asset(
                    iconAsset,
                    width: 20.cw,
                    height: 20.cw,
                    color: Colors.white, // Will be masked by gradient
                  )
                : Icon(
                    icon,
                    color: Colors.white, // Will be masked by gradient
                    size: 28.cw,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  /// Zoom out compass
  void _zoomOut() {
    final controller = Get.find<CompassController>();
    controller.triggerZoomOut();
  }

  /// Reset zoom to 1.0x
  void _resetZoom() {
    final controller = Get.find<CompassController>();
    controller.triggerResetZoom();
  }

  /// Take screenshot of compass
  void _takeScreenshot(CompassController controller) {
    controller.takeCompassScreenshot();
  }
  
  /// Navigate to detail view
  void _navigateToDetail(CompassController controller) {
    Get.to(() => PersonalCompassDetailView());
  }
  
  /// Build direction meaning text widget
  Widget _buildDirectionMeaningText(CompassController controller) {
    return Container(
      // Fixed height to always reserve space for 2 lines
      height: 48.ch, // 2 lines * 24px (line height)
      padding: EdgeInsets.symmetric(horizontal: 16.cw),
      child: Center(
        child: Obx(() {
          final fengShuiDirection = controller.getCurrentFengShuiDirection();
          
          if (fengShuiDirection == null) {
            // Return empty container with same height to maintain layout
            return const SizedBox();
          }
          
          // Get quality text (Tốt/Xấu/Tốt nhất/Rất xấu)
          String quality = "";
          if (fengShuiDirection.isGood) {
            if (fengShuiDirection.type == FengShuiDirectionType.sinhKhi) {
              quality = "Tốt nhất";
            } else {
              quality = "Tốt";
            }
          } else {
            if (fengShuiDirection.type == FengShuiDirectionType.tuyetMenh) {
              quality = "Rất xấu";
            } else {
              quality = "Xấu";
            }
          }
          
          // Get short description based on type
          String shortDescription = _getShortDescription(fengShuiDirection.type);
          
          return Text(
            '${fengShuiDirection.name} ($quality): $shortDescription',
            style: TextStyle(
              fontSize: 18.csp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFECA9),
              fontFamily: 'SVN Gilroy',
              height: 1.3, // Line height to ensure consistent spacing
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Maximum 2 lines
            overflow: TextOverflow.ellipsis, // Handle overflow gracefully
          );
        }),
      ),
    );
  }
  
  /// Get short description for each feng shui direction type
  String _getShortDescription(FengShuiDirectionType type) {
    switch (type) {
      case FengShuiDirectionType.sinhKhi:
        return 'Tài lộc, công danh, phát triển.';
      case FengShuiDirectionType.dienNien:
        return 'Mọi sự ổn định, lâu dài, gia đạo tốt.';
      case FengShuiDirectionType.thienY:
        return 'Sức khỏe, con cháu, được che chở.';
      case FengShuiDirectionType.phucVi:
        return 'Bình yên, củng cố tinh thần.';
      case FengShuiDirectionType.hoaHai:
        return 'Thất bại, tai tiếng, thị phi.';
      case FengShuiDirectionType.lucSat:
        return 'Sát khí, thị phi, kiện tụng.';
      case FengShuiDirectionType.nguQuy:
        return 'Hao tài, khẩu thiệt, bất ổn.';
      case FengShuiDirectionType.tuyetMenh:
        return 'Tai nạn, phá sản, bệnh tật.';
    }
  }
}
