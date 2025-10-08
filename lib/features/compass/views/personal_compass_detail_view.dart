import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/compass_responsive.dart';
import '../controllers/compass_controller.dart';
import '../constants/compass_ui_theme.dart';
import '../models/direction_info.dart';
import '../models/feng_shui_result.dart';

class PersonalCompassDetailView extends StatelessWidget {
  PersonalCompassDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompassController>();
    
    // Get data once outside of Obx to avoid rebuilds
    if (!controller.hasPersonalInfo || controller.fengShuiResult == null) {
      return Scaffold(
        backgroundColor: CompassUITheme.backgroundColor,
        appBar: AppBar(
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
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'Không có thông tin',
            style: TextStyle(
              color: CompassUITheme.primaryTextColor,
              fontSize: 16.csp,
            ),
          ),
        ),
      );
    }
    
    // Get snapshot of current values - won't update in real-time
    final personalInfo = controller.fengShuiResult!.personalInfo;
    final currentDirection = controller.currentDirection;
    final currentFengShuiDirection = controller.getCurrentFengShuiDirection();
    final headingDegrees = controller.headingText;
    
    return Scaffold(
      backgroundColor: CompassUITheme.backgroundColor,
      appBar: AppBar(
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
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 24.ch,
            left: 16.cw,
            right: 16.cw,
            bottom: 32.ch,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 ',
                      style: TextStyle(fontSize: 18.csp),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin người dùng:',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 18.csp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SVN Gilroy',
                            ),
                          ),
                          SizedBox(height: 12.ch),
                          Text(
                            '• Năm sinh: ${personalInfo.birthYear} (${_getZodiacYear(personalInfo.birthYear)})',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 16.csp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SVN Gilroy',
                              height: 1.5,
                            ),
                          ),
                          Text(
                            '• Giới tính: ${personalInfo.isMale ? "Nam" : "Nữ"}',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 16.csp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SVN Gilroy',
                              height: 1.5,
                            ),
                          ),
                          Text(
                            '• Mệnh quái: ${_getKuaName(personalInfo.kuaNumber)} – thuộc ${_getDestinyGroupName(personalInfo.destinyGroup)}',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 16.csp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SVN Gilroy',
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.ch),
                
                // Current direction section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 ',
                      style: TextStyle(fontSize: 18.csp),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hướng đo được: ${currentDirection?.vietnameseName ?? "--"} – $headingDegrees',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 18.csp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SVN Gilroy',
                            ),
                          ),
                          SizedBox(height: 12.ch),
                          Text(
                            '• Góc $headingDegrees rơi vào hướng ${currentDirection?.vietnameseName ?? "--"} (${currentDirection?.chineseName ?? "--"}).',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 16.csp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SVN Gilroy',
                              height: 1.5,
                            ),
                          ),
                          if (currentFengShuiDirection != null)
                            Text(
                              '• Với người có mệnh ${_getKuaName(personalInfo.kuaNumber)}, hướng ${currentDirection?.vietnameseName ?? "--"} tương ứng với cung ${currentFengShuiDirection.name}.',
                              style: TextStyle(
                                color: const Color(0xFFFFFAED),
                                fontSize: 16.csp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SVN Gilroy',
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.ch),
                
                // Directions meaning section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧭 ',
                      style: TextStyle(fontSize: 18.csp),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ý nghĩa các cung trên la bàn:',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 18.csp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SVN Gilroy',
                            ),
                          ),
                          SizedBox(height: 12.ch),
                          Text(
                            'Các cung được chia làm 8 hướng ứng với 8 quẻ bát quái – mỗi hướng lại có một ý nghĩa cát hoặc hung khác nhau, tùy theo mệnh của từng người. Với người mệnh ${_getKuaName(personalInfo.kuaNumber)}, các hướng có ý nghĩa như sau:',
                            style: TextStyle(
                              color: const Color(0xFFFFFAED),
                              fontSize: 16.csp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SVN Gilroy',
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 8.ch),
                          
                          // Dynamic directions based on user's Kua with fixed descriptions
                          ...controller.fengShuiResult!.goodDirections.map((direction) =>
                            _buildDirectionItem(direction, true)
                          ),
                          
                          ...controller.fengShuiResult!.badDirections.map((direction) =>
                            _buildDirectionItem(direction, false)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.ch),
                
                // Conclusion section
                if (currentFengShuiDirection != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👉 ',
                        style: TextStyle(fontSize: 18.csp),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kết luận tại vị trí đo $headingDegrees:',
                              style: TextStyle(
                                color: const Color(0xFFFFFAED),
                                fontSize: 18.csp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'SVN Gilroy',
                              ),
                            ),
                            SizedBox(height: 12.ch),
                            Text(
                              '• Bạn đang đối mặt với hướng ${currentFengShuiDirection.name} – ${_getConclusionQuality(currentFengShuiDirection)} theo Bát Trạch.',
                              style: TextStyle(
                                color: const Color(0xFFFFFAED),
                                fontSize: 16.csp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SVN Gilroy',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '• Hướng này đại diện cho: ${_getConclusionMeaning(currentFengShuiDirection)}.',
                              style: TextStyle(
                                color: const Color(0xFFFFFAED),
                                fontSize: 16.csp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SVN Gilroy',
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '• ${currentFengShuiDirection.isGood ? "Phù hợp để" : "Không phù hợp để"}: ${_getConclusionRecommendation(currentFengShuiDirection)}.',
                              style: TextStyle(
                                color: const Color(0xFFFFFAED),
                                fontSize: 16.csp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SVN Gilroy',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      
    );
  }


  Widget _buildDirectionItem(FengShuiDirectionResult direction, bool isGood) {
    // Get DirectionInfo from the static list
    final directionInfo = DirectionInfo.all.firstWhere(
      (info) => info.baGuaDirection == direction.direction,
      orElse: () => DirectionInfo.all.first,
    );
    
    // Determine quality text
    String quality = "";
    if (isGood) {
      quality = direction.type == FengShuiDirectionType.sinhKhi ? "Tốt nhất" : "Tốt";
    } else {
      quality = direction.type == FengShuiDirectionType.tuyetMenh ? "Rất xấu" : "Xấu";
    }
    
    // Get fixed description based on direction type
    String description = _getFixedDescription(direction.type);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 4.ch),
      child: Text(
        '• ${directionInfo.vietnameseName} (${directionInfo.chineseName}) - Cung ${direction.name} - $quality: $description',
        style: TextStyle(
          color: const Color(0xFFFFFAED),
          fontSize: 16.csp,
          fontWeight: FontWeight.w500,
          fontFamily: 'SVN Gilroy',
          height: 1.5,
        ),
      ),
    );
  }

  String _getFixedDescription(FengShuiDirectionType type) {
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

  String _getKuaName(int kuaNumber) {
    switch (kuaNumber) {
      case 1: return 'Khảm (Thủy)';
      case 2: return 'Khôn (Thổ)';
      case 3: return 'Chấn (Mộc)';
      case 4: return 'Tốn (Mộc)';
      case 6: return 'Càn (Kim)';
      case 7: return 'Đoài (Kim)';
      case 8: return 'Cấn (Thổ)';
      case 9: return 'Ly (Hỏa)';
      default: return 'Không xác định';
    }
  }

  String _getDestinyGroupName(PersonalDestinyGroup group) {
    switch (group) {
      case PersonalDestinyGroup.dongTu:
        return 'Đông Tứ Mệnh';
      case PersonalDestinyGroup.tayTu:
        return 'Tây Tứ Mệnh';
    }
  }

  String _getZodiacYear(int year) {
    final zodiacAnimals = [
      'Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ',
      'Ngọ', 'Mùi', 'Thân', 'Dậu', 'Tuất', 'Hợi'
    ];
    final heavenlyStems = [
      'Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu',
      'Kỷ', 'Canh', 'Tân', 'Nhâm', 'Quý'
    ];
    
    // Calculate Heavenly Stem (Can)
    final stemIndex = (year - 4) % 10;
    final stem = heavenlyStems[stemIndex];
    
    // Calculate Earthly Branch (Chi)
    final branchIndex = (year - 4) % 12;
    final branch = zodiacAnimals[branchIndex];
    
    return '$stem $branch';
  }


  String _getConclusionQuality(FengShuiDirectionResult direction) {
    if (direction.isGood) {
      if (direction.type == FengShuiDirectionType.sinhKhi) {
        return 'hướng tốt nhất trong 4 hướng cát';
      } else if (direction.type == FengShuiDirectionType.dienNien) {
        return '(còn gọi là Diên Niên) - một trong 4 hướng tốt';
      } else {
        return 'một trong 4 hướng tốt';
      }
    } else {
      if (direction.type == FengShuiDirectionType.tuyetMenh) {
        return 'hướng xấu nhất trong 4 hướng hung';
      } else {
        return 'một trong 4 hướng xấu';
      }
    }
  }

  String _getConclusionMeaning(FengShuiDirectionResult direction) {
    switch (direction.type) {
      case FengShuiDirectionType.sinhKhi:
        return 'tài lộc, thăng tiến, danh tiếng, thu hút may mắn';
      case FengShuiDirectionType.dienNien:
        return 'sự ổn định, hòa thuận, gia đạo bền vững, các mối quan hệ tốt đẹp';
      case FengShuiDirectionType.thienY:
        return 'sức khỏe, trường thọ, gặp quý nhân, hóa giải bệnh tật';
      case FengShuiDirectionType.phucVi:
        return 'sự ổn định, củng cố tinh thần, thuận lợi cho phát triển cá nhân và gia đạo';
      case FengShuiDirectionType.hoaHai:
        return 'xáo trộn, mất hòa thuận, rắc rối nhỏ trong cuộc sống';
      case FengShuiDirectionType.lucSat:
        return 'xáo trộn, bất hòa, dễ gặp rắc rối trong quan hệ và pháp luật';
      case FengShuiDirectionType.nguQuy:
        return 'mất mát tài sản, tai nạn, cãi vã, hỏa hoạn';
      case FengShuiDirectionType.tuyetMenh:
        return 'bệnh tật nặng, phá sản, chia ly, nguy hiểm đến tính mạng';
    }
  }

  String _getConclusionRecommendation(FengShuiDirectionResult direction) {
    if (direction.isGood) {
      switch (direction.type) {
        case FengShuiDirectionType.sinhKhi:
          return 'đặt cửa chính, phòng làm việc, phòng khách, hướng bàn làm việc';
        case FengShuiDirectionType.dienNien:
          return 'đặt bàn thờ, phòng ngủ, cửa chính, hướng ngồi làm việc';
        case FengShuiDirectionType.thienY:
          return 'đặt phòng ngủ, phòng chữa bệnh, phòng thờ, cửa chính';
        case FengShuiDirectionType.phucVi:
          return 'đặt bàn thờ, phòng ngủ, phòng học, hướng ngồi làm việc';
        default:
          return 'đặt các vị trí quan trọng trong nhà';
      }
    } else {
      switch (direction.type) {
        case FengShuiDirectionType.tuyetMenh:
          return 'đặt cửa chính, phòng ngủ, phòng bếp, hướng bàn làm việc';
        case FengShuiDirectionType.nguQuy:
          return 'đặt cửa chính, bếp, phòng ngủ, hướng bàn làm việc';
        case FengShuiDirectionType.lucSat:
          return 'đặt cửa chính, phòng ngủ, phòng khách, hướng bàn làm việc';
        default:
          return 'đặt cửa chính, phòng ngủ, bàn làm việc';
      }
    }
  }
}