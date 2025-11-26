import 'package:flutter/material.dart';

import 'package:fasalmitra/screens/phone_login.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/services/tip_service.dart';
import 'package:fasalmitra/widgets/language_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _grassAsset = 'assets/images/grass.png';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _submitting = false;
  bool _cachedGrass = false;
  CaptchaData? _captcha;
  bool _captchaLoading = false;

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    _phoneController.dispose();
    _captchaController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_captcha == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Captcha not ready yet')));
      return;
    }
    final captchaText = _captchaController.text.trim();
    if (captchaText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter captcha text')));
      return;
    }

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.instance.verifyCaptcha(
        captchaId: _captcha!.id,
        text: captchaText,
      );
      await AuthService.instance.registerUser(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Registration submitted!')),
      );
      Navigator.of(context).pushReplacementNamed(PhoneLoginScreen.routeName);
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
      _loadCaptcha();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
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
              final card = _buildRegisterCard();
              if (!isWide) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildWelcomePanel(height: constraints.maxHeight * 0.25),
                      card,
                    ],
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildWelcomePanel()),
                  Expanded(child: SingleChildScrollView(child: card)),
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

  Widget _buildRegisterCard() {
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
                      lang.t('register'),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: lang.t('fullName'),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Required'
                                : null,
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
                                return 'Include country code (e.g. +91…)';
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
                                  decoration: InputDecoration(
                                    labelText: lang.t('captchaText'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildCaptchaBox(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(lang.t('registerCta')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(PhoneLoginScreen.routeName);
                      },
                      child: Text(lang.t('alreadyRegistered')),
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
}
