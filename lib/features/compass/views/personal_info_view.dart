import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/compass_responsive.dart';
import '../controllers/compass_controller.dart';
import '../constants/compass_ui_theme.dart';
import 'personal_compass_view.dart';

/// Personal Information Input View for Personal Compass
class PersonalInfoView extends StatefulWidget {
  const PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  bool? _isMale; // Nullable - no default, user must select
  bool _showGenderError = false; // Track gender validation error

  @override
  void initState() {
    super.initState();
    // Pre-fill form if data exists
    final controller = Get.find<CompassController>();
    if (controller.hasPersonalInfo) {
      _yearController.text = controller.birthYear.toString();
      _isMale = controller.isMale;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CompassUITheme.backgroundColor,
      resizeToAvoidBottomInset: true, // Allow resize for input form
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
        child: Padding(
          padding: EdgeInsets.all(CompassUITheme.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 26.ch),
                
                // Description
                Text(
                  'Vui lòng cung cấp thông tin về người xem để có thể xem hướng theo tuổi chính xác',
                  style: CompassUITheme.descriptionTextStyle.copyWith(
                    height: 26.ch / CompassUITheme.descriptionTextSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 46.ch),
                
                // Information input container
                Column(
                  children: [
                    // Birth year row
                    Row(
                      children: [
                        // Label "Năm sinh"
                        Text(
                          'Năm sinh',
                          style: CompassUITheme.cardLabelStyle.copyWith(
                            fontSize: 18.csp,
                            fontWeight: FontWeight.w500,
                            color: CompassUITheme.primaryTextColor,
                          ),
                        ),
                        
                        SizedBox(width: 16.cw),
                        
                        // Text field
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            style: CompassUITheme.cardLabelStyle.copyWith(
                              fontSize: 16.csp,
                              color: CompassUITheme.primaryTextColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nhập năm sinh',
                              hintStyle: CompassUITheme.descriptionTextStyle.copyWith(
                                fontSize: 16.csp,
                                color: Colors.grey.shade400,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFFFAED).withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.cr),
                                borderSide: BorderSide(
                                  color: const Color(0xFFFFFAED).withOpacity(0.8),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.cr),
                                borderSide: BorderSide(
                                  color: const Color(0xFFFFFAED).withOpacity(0.8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.cr),
                                borderSide: BorderSide(
                                  color: const Color(0xFFFFFAED).withOpacity(0.8),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.cr),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.cr),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 14.csp,
                                color: Colors.red,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.cw,
                                vertical: 12.ch,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập năm sinh';
                              }
                              final year = int.tryParse(value);
                              if (year == null || year < 1900 || year > DateTime.now().year) {
                                return 'Năm sinh không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                              
                    
                    SizedBox(height: 24.ch),
                    
                    // Gender selection row
                    Row(
                      children: [
                        // Label "Giới tính"
                        Text(
                          'Giới tính',
                          style: CompassUITheme.cardLabelStyle.copyWith(
                            fontSize: 18.csp,
                            fontWeight: FontWeight.w500,
                            color: CompassUITheme.primaryTextColor,
                          ),
                        ),
                        
                        SizedBox(width: 16.cw),
                        
                        // Gender selection buttons
                        Expanded(
                          child: Row(
                            children: [
                              // Nam button - EXACT style from degree box
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isMale = true;
                                    _showGenderError = false; // Clear error when selected
                                  }),
                                  child: _isMale == true
                                    ? Container(
                                        // Outer gradient border (EXACT from degree box)
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.cr),
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
                                          // Inner background - new color #01664D
                                          margin: EdgeInsets.all(1.cw), // Inner border effect
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.cr),
                                            color: const Color(0xFF01664D), // New solid color
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.ch,
                                            horizontal: 16.cw,
                                          ),
                                          child: Text(
                                            'Nam',
                                            textAlign: TextAlign.center,
                                            style: CompassUITheme.cardLabelStyle.copyWith(
                                              fontSize: 16.csp,
                                              color: CompassUITheme.primaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // Unselected state
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.ch,
                                          horizontal: 16.cw,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.cr),
                                          border: Border.all(
                                            color: _showGenderError 
                                              ? Colors.red 
                                              : const Color(0xFFFFFAED).withOpacity(0.5),
                                            width: _showGenderError ? 2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Nam',
                                          textAlign: TextAlign.center,
                                          style: CompassUITheme.cardLabelStyle.copyWith(
                                            fontSize: 16.csp,
                                            color: CompassUITheme.primaryTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                              
                              SizedBox(width: 12.cw),
                              
                              // Nữ button - EXACT style from degree box
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isMale = false;
                                    _showGenderError = false; // Clear error when selected
                                  }),
                                  child: _isMale == false
                                    ? Container(
                                        // Outer gradient border (EXACT from degree box)
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.cr),
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
                                          // Inner background - new color #01664D
                                          margin: EdgeInsets.all(1.cw), // Inner border effect
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.cr),
                                            color: const Color(0xFF01664D), // New solid color
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.ch,
                                            horizontal: 16.cw,
                                          ),
                                          child: Text(
                                            'Nữ',
                                            textAlign: TextAlign.center,
                                            style: CompassUITheme.cardLabelStyle.copyWith(
                                              fontSize: 16.csp,
                                              color: CompassUITheme.primaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // Unselected state
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.ch,
                                          horizontal: 16.cw,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.cr),
                                          border: Border.all(
                                            color: _showGenderError 
                                              ? Colors.red 
                                              : const Color(0xFFFFFAED).withOpacity(0.5),
                                            width: _showGenderError ? 2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Nữ',
                                          textAlign: TextAlign.center,
                                          style: CompassUITheme.cardLabelStyle.copyWith(
                                            fontSize: 16.csp,
                                            color: CompassUITheme.primaryTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Error message for gender
                    if (_showGenderError)
                      Padding(
                        padding: EdgeInsets.only(top: 4.ch, left: 40.cw),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Vui lòng chọn giới tính',
                            style: TextStyle(
                              fontSize: 14.csp,
                              color: Colors.red,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 62.5.ch),
                
                // Submit button - matching numerology input style
                Container(
                  width: double.infinity,
                  height: 48.ch,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C5CE6),
                    borderRadius: BorderRadius.circular(99.cr),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate form first
                      bool isFormValid = _formKey.currentState!.validate();
                      
                      // Check gender selection
                      if (_isMale == null) {
                        setState(() {
                          _showGenderError = true;
                        });
                        isFormValid = false;
                      }
                      
                      // Proceed only if both form and gender are valid
                      if (isFormValid && _isMale != null) {
                        
                        // IMPORTANT: Dismiss keyboard and wait for it to complete
                        FocusScope.of(context).unfocus();
                       
                        
                        final controller = Get.find<CompassController>();
                        controller.setPersonalInfo(
                          int.parse(_yearController.text),
                          _isMale!,
                        );
                        
                        // Navigate to PersonalCompassView
                        Get.to(() => const PersonalCompassView());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99.cr),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.ch,
                        horizontal: 24.cw,
                      ),
                    ),
                    child: Text(
                      'Xem hướng theo tuổi',
                      style: CompassUITheme.cardLabelStyle.copyWith(
                        fontSize: 18.csp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Bottom spacer
                SizedBox(height: 32.ch),
              ],
            ),
          ),
        ),
      ),
    );
  }
}