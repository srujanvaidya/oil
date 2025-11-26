import 'package:flutter/material.dart';

import 'package:fasalmitra/screens/home_screen.dart';
import 'package:fasalmitra/services/auth_service.dart';

class OTPScreenArgs {
  OTPScreenArgs({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
}

class OTPScreen extends StatefulWidget {
  const OTPScreen({required this.args, super.key});

  static const routeName = '/otp';
  final OTPScreenArgs args;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _verifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final smsCode = _otpController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _verifying = true);

    try {
      await AuthService.instance.verifyOtp(widget.args.verificationId, smsCode);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP for ${widget.args.phoneNumber}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter the 6-digit OTP you received',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return 'Enter the 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verifyOtp,
                      child: _verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
