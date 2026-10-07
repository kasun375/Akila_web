import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/config/stripe_config.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';

enum StripeStatus { success, failed, cancelled }

class StripeResponse {
  final StripeStatus status;
  final String orderId;
  final String paymentIntentId;
  final double amount;
  final String message;
  final String cardBrand;
  final String last4;

  StripeResponse({
    required this.status,
    required this.orderId,
    required this.paymentIntentId,
    required this.amount,
    required this.message,
    this.cardBrand = 'Visa',
    this.last4 = '4242',
  });
}

class StripeCheckoutDialog extends StatefulWidget {
  final UserModel student;
  final ClassModel classItem;
  final String orderId;

  const StripeCheckoutDialog({
    super.key,
    required this.student,
    required this.classItem,
    required this.orderId,
  });

  @override
  State<StripeCheckoutDialog> createState() => _StripeCheckoutDialogState();
}

class _StripeCheckoutDialogState extends State<StripeCheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;
  String _cardBrand = 'CARD';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.student.name;
    _cardNumberController.addListener(_detectCardBrand);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_detectCardBrand);
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _detectCardBrand() {
    final text = _cardNumberController.text.replaceAll(' ', '');
    setState(() {
      if (text.startsWith('4')) {
        _cardBrand = 'VISA';
      } else if (text.startsWith('51') ||
          text.startsWith('52') ||
          text.startsWith('53') ||
          text.startsWith('54') ||
          text.startsWith('55')) {
        _cardBrand = 'MASTERCARD';
      } else if (text.startsWith('34') || text.startsWith('37')) {
        _cardBrand = 'AMEX';
      } else if (text.startsWith('6011') || text.startsWith('65')) {
        _cardBrand = 'DISCOVER';
      } else {
        _cardBrand = 'CARD';
      }
    });
  }

  Future<void> _processStripePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final rawCardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiryParts = _expiryController.text.split('/');
    final expMonth = expiryParts[0].trim();
    final expYear = expiryParts[1].trim().length == 2
        ? '20${expiryParts[1].trim()}'
        : expiryParts[1].trim();
    final cvc = _cvcController.text.trim();
    final cardHolderName = _nameController.text.trim();

    try {
      final amountInCents = (widget.classItem.monthlyFee * 100).toInt();

      // 1. Create Token via Stripe Publishable Key (CORS-enabled for web)
      final tokenResponse = await http.post(
        Uri.parse(StripeConfig.tokensUrl),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.publishableKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'card[number]': rawCardNumber,
          'card[exp_month]': expMonth,
          'card[exp_year]': expYear,
          'card[cvc]': cvc,
          'card[name]': cardHolderName,
        },
      );

      final tokenData = jsonDecode(tokenResponse.body);

      if (tokenResponse.statusCode != 200 || tokenData['id'] == null) {
        final err = tokenData['error']?['message'] ??
            'Invalid card details. Please check your card number, expiry date, and CVC.';
        setState(() {
          _isProcessing = false;
          _errorMessage = err;
        });
        return;
      }

      final String tokenId = tokenData['id'];

      // 2. Submit Charge to User's Stripe Merchant Account via Secret Key
      final chargeResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/charges'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': StripeConfig.currency.toLowerCase(),
          'source': tokenId,
          'description':
              '${widget.classItem.title} - ${widget.student.name} (${widget.orderId})',
          'receipt_email': widget.student.email.isNotEmpty
              ? widget.student.email
              : 'student@akilamaths.lk',
        },
      );

      final chargeData = jsonDecode(chargeResponse.body);

      if (chargeResponse.statusCode == 200 &&
          (chargeData['paid'] == true || chargeData['status'] == 'succeeded')) {
        final chargeId =
            chargeData['id'] ?? 'ch_live_${DateTime.now().millisecondsSinceEpoch}';
        final last4 = rawCardNumber.length >= 4
            ? rawCardNumber.substring(rawCardNumber.length - 4)
            : '4242';

        if (mounted) {
          Navigator.of(context).pop(
            StripeResponse(
              status: StripeStatus.success,
              orderId: widget.orderId,
              paymentIntentId: chargeId,
              amount: widget.classItem.monthlyFee,
              message: 'Payment completed successfully!',
              cardBrand: _cardBrand,
              last4: last4,
            ),
          );
        }
      } else {
        final errorMsg = chargeData['error']?['message'] ??
            'Transaction could not be completed. Please check card balance or try another card.';
        setState(() {
          _isProcessing = false;
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Connection error: $e. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Modern Blue & White Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pay Class Fees',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '256-Bit Encrypted Secure Checkout',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(
                        StripeResponse(
                          status: StripeStatus.cancelled,
                          orderId: widget.orderId,
                          paymentIntentId: '',
                          amount: widget.classItem.monthlyFee,
                          message: 'Cancelled by user',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Cardholder Name Field
                      _buildLabel('Cardholder Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: _buildInputDecoration(
                          hint: 'Full Name on Card',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter cardholder name' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Card Number Field with Brand Badge
                      _buildLabel('Card Number'),
                      TextFormField(
                        controller: _cardNumberController,
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 1.0),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _CardNumberFormatter(),
                        ],
                        decoration: _buildInputDecoration(
                          hint: '4242 4242 4242 4242',
                          icon: Icons.credit_card_rounded,
                          suffix: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _cardBrand,
                              style: const TextStyle(
                                color: Color(0xFF1E40AF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        validator: (v) {
                          final digits = v?.replaceAll(' ', '') ?? '';
                          if (digits.length < 15) return 'Enter valid card number';
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Expiry Date'),
                                TextFormField(
                                  controller: _expiryController,
                                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    _ExpiryDateFormatter(),
                                  ],
                                  decoration: _buildInputDecoration(
                                    hint: 'MM/YY',
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                  validator: (v) {
                                    if (v == null || !v.contains('/') || v.length < 5) {
                                      return 'MM/YY required';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('CVC / CVV'),
                                TextFormField(
                                  controller: _cvcController,
                                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: _buildInputDecoration(
                                    hint: '•••',
                                    icon: Icons.lock_outline_rounded,
                                  ),
                                  validator: (v) => (v == null || v.length < 3) ? '3-4 digits' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Monthly Order Summary Box (Soft Blue & White Tint)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Monthly Class Fee:',
                                        style: TextStyle(color: Color(0xFF1E40AF), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.classItem.title,
                                    style: const TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rs. ${widget.classItem.monthlyFee.toStringAsFixed(2)} LKR',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Primary Action Submit Button (Vibrant Blue)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isProcessing ? null : _processStripePayment,
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Processing Payment...',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Pay Fees • Rs. ${widget.classItem.monthlyFee.toStringAsFixed(2)} LKR',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          '🔒 256-Bit SSL Encrypted • Direct Merchant Settlement',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonOnlyDigits = i + 1;
      if (nonOnlyDigits % 4 == 0 && nonOnlyDigits != text.length) {
        buffer.write(' ');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
