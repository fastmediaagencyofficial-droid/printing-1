import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const PaymentScreen({super.key, required this.extra});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'jazzcash';
  XFile? _proofImage;
  bool _isUploading = false;

  // These would normally come from backend API
  static const Map<String, String> _paymentNumbers = {
    'jazzcash': '0325-2467463',
    'easypaisa': '0321-0846667',
  };

  String get _accountNumber => _paymentNumbers[_selectedMethod] ?? '';
  String get _accountName => AppStrings.paymentAccountName;
  String get _orderId => widget.extra['orderId'] as String? ?? 'FP-001';
  double get _amount => (widget.extra['amount'] as double?) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () { try { context.pop(); } catch (_) { context.go('/cart'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment method selector
            _buildMethodSelector(),
            const SizedBox(height: 24),

            // Payment instructions card
            _buildPaymentInstructions(),
            const SizedBox(height: 24),

            // Steps
            _buildSteps(),
            const SizedBox(height: 24),

            // Upload proof
            _buildUploadSection(),
            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(),
            const SizedBox(height: 16),

            // Help text
            Center(
              child: TextButton.icon(
                onPressed: () => _launchWhatsApp(),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('Need help? Chat on WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                name: 'JazzCash',
                isSelected: _selectedMethod == 'jazzcash',
                color: const Color(0xFFBF0000),
                icon: Icons.phone_android_rounded,
                onTap: () => setState(() => _selectedMethod = 'jazzcash'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentMethodCard(
                name: 'EasyPaisa',
                isSelected: _selectedMethod == 'easypaisa',
                color: const Color(0xFF00A651),
                icon: Icons.account_balance_wallet_rounded,
                onTap: () => setState(() => _selectedMethod = 'easypaisa'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, AppColors.charcoal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const Text(
                    'Transfer Details',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.softGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          _InfoRow(label: 'Account Number', value: _accountNumber, canCopy: true),
          const SizedBox(height: 12),
          _InfoRow(label: 'Account Name', value: _accountName, canCopy: false),
          const SizedBox(height: 12),
          _InfoRow(
              label: 'Amount to Transfer',
              value: 'PKR ${_amount.toStringAsFixed(0)}',
              canCopy: true,
              highlight: true),
          const SizedBox(height: 12),
          _InfoRow(
              label: 'Order Reference',
              value: _orderId,
              canCopy: true,
              subtitle: 'Use as payment note'),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryRed, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Please add the Order ID in the payment description/note',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSteps() {
    final steps = [
      'Open your ${_selectedMethod == 'jazzcash' ? 'JazzCash' : 'EasyPaisa'} app',
      'Send Money → Mobile Account',
      'Enter: $_accountNumber',
      'Amount: PKR ${_amount.toStringAsFixed(0)}',
      'Note/Reference: $_orderId',
      'Take screenshot of confirmation',
      'Upload screenshot below',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How to Pay',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    steps[i],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn()
            .slideX(begin: 0.1)),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Payment Screenshot',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload a screenshot of your payment confirmation',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.mediumGrey,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _proofImage != null ? AppColors.successLight : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _proofImage != null
                    ? AppColors.success
                    : AppColors.borderGrey,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: _proofImage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Screenshot Uploaded ✓',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Change Image'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_rounded,
                          color: AppColors.primaryRed, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to upload screenshot',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const Text(
                        'JPG, PNG supported',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _proofImage != null && !_isUploading ? _submitPayment : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _proofImage != null ? AppColors.primaryRed : AppColors.borderGrey,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _isUploading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
          : const Text(
              'Submit Payment Proof',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _proofImage = image);
    }
  }

  Future<void> _submitPayment() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate upload
    setState(() => _isUploading = false);
    if (!mounted) return;
    context.go('/order-confirmation/$_orderId');
  }

  Future<void> _launchWhatsApp() async {
    const phone = '923252467463';
    final message = Uri.encodeComponent(
        'Hi, I need help with my order $_orderId');
    final whatsappUrl = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.name,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String name;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.softGrey, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.canCopy,
    this.highlight = false,
    this.subtitle,
  });
  final String label;
  final String value;
  final bool canCopy;
  final bool highlight;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.softGrey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: highlight ? 18 : 15,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.primaryRed : AppColors.white,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.softGrey,
                  ),
                ),
            ],
          ),
        ),
        if (canCopy)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied!'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primaryRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 14, color: AppColors.white),
                  SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
