import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fasalmitra/screens/home_screen.dart';
import 'package:fasalmitra/screens/register_screen.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/services/tip_service.dart';
import 'package:fasalmitra/widgets/language_selector.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  static const String _grassAsset = 'assets/images/grass.png';
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();

  bool _sending = false;
  bool _verifying = false;
  bool _codeSent = false;
  String? _verificationId;
  int? _resendToken;
  CaptchaData? _captcha;
  bool _captchaLoading = false;
  bool _cachedGrass = false;

  @override
  void initState() {
    super.initState();
    final token = AuthService.instance.backendToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      });
    }
    _loadCaptcha();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cachedGrass) {
      precacheImage(const AssetImage(_grassAsset), context).catchError((_) {});
      _cachedGrass = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _captchaController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    setState(() => _captchaLoading = true);
    try {
      final captcha = await AuthService.instance.fetchCaptcha();
      if (!mounted) return;
      setState(() {
        _captcha = captcha;
        _captchaController.clear();
      });
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Captcha failed: $err')));
    } finally {
      if (mounted) {
        setState(() => _captchaLoading = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_captcha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.instance.t('captchaNotReady'))),
      );
      return;
    }
    final captchaText = _captchaController.text.trim();
    if (captchaText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.instance.t('captchaEnter'))),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);

    try {
      await AuthService.instance.verifyCaptcha(
        captchaId: _captcha!.id,
        text: captchaText,
      );

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (exception) {
          messenger.showSnackBar(
            SnackBar(content: Text(exception.message ?? 'Verification failed')),
          );
        },
        codeSent: (verificationId, resendToken) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '${LanguageService.instance.t('otpSentPrefix')} $phone',
              ),
            ),
          );
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
            _otpController.clear();
          });
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
      _loadCaptcha();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) return;
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.instance.t('enterOtp'))),
      );
      return;
    }
    setState(() => _verifying = true);
    try {
      await AuthService.instance.verifyOtp(_verificationId!, code);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(HomeScreen.routeName, (_) => false);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err.toString())));
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final content = _buildLoginCard();
              if (!isWide) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildWelcomePanel(height: constraints.maxHeight * 0.25),
                      content,
                    ],
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildWelcomePanel()),
                  Expanded(child: SingleChildScrollView(child: content)),
                ],
              );
            },
          ),
          const Positioned(top: 16, right: 16, child: LanguageSelector()),
        ],
      ),
    );
  }

  Widget _buildWelcomePanel({double? height}) {
    final lang = LanguageService.instance;
    final grassHeight = (height ?? 400) * 0.6;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF195B33), Color(0xFF4CAF50)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: grassHeight,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.white, Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  _grassAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: ValueListenableBuilder<String>(
                    valueListenable: TipService.instance.listenable,
                    builder: (context, tip, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lang.t('welcome')}\n${lang.t('appName')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (tip.isNotEmpty)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                key: ValueKey(tip),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    final lang = LanguageService.instance;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lang.t('login'),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildOtpRequestCard(),
                    const SizedBox(height: 24),
                    if (_codeSent) _buildOtpVerifyCard(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(RegisterScreen.routeName);
                      },
                      child: Text(lang.t('newUser')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpRequestCard() {
    final lang = LanguageService.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${lang.t('login')} OTP',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: lang.t('mobile'),
              prefixText: '+',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return lang.t('enterPhone');
              }
              if (!value.trim().startsWith('+')) {
                return 'Include country code (e.g. +91...)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _captchaController,
                  decoration: InputDecoration(labelText: lang.t('captchaText')),
                ),
              ),
              const SizedBox(width: 12),
              _buildCaptchaBox(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _sendOtp,
              child: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(lang.t('sendOtp')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaBox() {
    return Container(
      width: 120,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade100,
      ),
      child: _captchaLoading
          ? const Center(child: CircularProgressIndicator())
          : InkWell(
              onTap: _loadCaptcha,
              child: _captcha == null || _captcha!.imageUrl.isEmpty
                  ? const Center(child: Text('Tap to load'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _captcha!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Text('Captcha')),
                      ),
                    ),
            ),
    );
  }

  Widget _buildOtpVerifyCard() {
    final lang = LanguageService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                lang.t('enterOtp'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: lang.t('otpPlaceholder'),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
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
      ],
    );
  }
}
