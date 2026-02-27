import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/wallet_card.dart';
import '../../../../shared/widgets/monthly_overview_chart.dart';
import '../../../../shared/widgets/insight_card.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';
import '../../../../shared/widgets/app_popup.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../bank_accounts/providers/bank_account_notifier.dart';
import '../../../cash_wallets/providers/cash_wallet_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.wait([
        ref.read(cashWalletNotifierProvider).load(),
        ref.read(bankAccountNotifierProvider).load(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final String? email = auth.session?.email;
    final rawName = (email != null && email.contains('@'))
        ? email.split('@').first
        : 'Alexandra';
    final displayName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase()
        : 'Alexandra';

    // Mock constants for visual parity with design reference
    const mockBalance = 142590.00;
    const mockAssets = 156200.00;
    const mockDebt = 13610.00;

    return GlassScaffold(
      isPremium: true,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 24),
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDd2LvR87zPtHuu4jJbu3qq7YZxkQmkCvgw1NkRAEyoV7ZKW2-KnQ3g1KcwUFyKyPPJTWYZuo77B9ik648jGbMu-r3sokra3VdrkB5-aY0-HyC1DawwPS5fItKt0YLy-aOHfK1pH2wtf2_ysGA7T1A-yDKq6MlmDROHP8amXsVGiFl3HzGx5HeEn9e_bN9qMVo1k0EC-hxsN4te5qcLdP7M1cSozmgJHVe_E_imNOzbTfzn_pQSzBJi85QN9HvJZ754AtLGn4jstr0',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WELCOME BACK',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0x99a5b4fc),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  displayName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff43f5e),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xff0f0c1d),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Net Worth Summary
                    MetricCard(
                      totalBalance: mockBalance,
                      totalAssets: mockAssets,
                      creditDebt: mockDebt,
                    ),
                    const SizedBox(height: 36),

                    // My Wallets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Wallets',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/wallet'),
                          child: Text(
                            'See All',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff818cf8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 170,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: WalletCard(
                              name: 'Main Checking',
                              balance: 4250.0,
                              currency: 'USD',
                              type: WalletCardType.visa,
                              lastFourDigit: '4250',
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: WalletCard(
                              name: 'Platinum Card',
                              balance: 1240.0,
                              currency: 'USD',
                              type: WalletCardType.amex,
                              lastFourDigit: '1240',
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: WalletCard(
                              name: 'High Yield Savings',
                              balance: 56000.0,
                              currency: 'USD',
                              type: WalletCardType.savings,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Monthly Overview Chart
                    const MonthlyOverviewChart(),
                    const SizedBox(height: 36),

                    // Quick Insight Card
                    const InsightCard(),
                    const SizedBox(height: 120), // Spacing for BottomNav
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PremiumBottomNav(
                currentIndex: 0,
                onAddPressed: _openCreateWalletSheet,
                onTabSelected: (index) {
                  if (index == 1) context.go('/analytics');
                  if (index == 2) context.go('/wallet');
                  if (index == 3) context.go('/profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(cashWalletNotifierProvider).load(),
      ref.read(bankAccountNotifierProvider).load(),
    ]);
  }

  Future<void> _openCreateWalletSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CreateAssetSheet(
          title: 'Create Asset',
          submitLabel: 'Save Asset',
          onSubmit:
              ({
                required String name,
                required double amount,
                required String currency,
                String? extraValue,
              }) async {
                final created = await ref
                    .read(cashWalletNotifierProvider)
                    .createWallet(
                      name: name,
                      balance: amount,
                      currency: currency,
                    );
                if (!mounted) return;
                if (created) {
                  Navigator.pop(context);
                  showAppPopup(
                    context,
                    message: 'Wallet created successfully.',
                    type: AppPopupType.success,
                  );
                } else {
                  final error = ref.read(cashWalletNotifierProvider).error;
                  showAppPopup(
                    context,
                    message: error ?? 'Could not create wallet.',
                    type: AppPopupType.error,
                  );
                }
              },
        );
      },
    );
  }
}

typedef _CreateAssetSheetSubmit =
    Future<void> Function({
      required String name,
      required double amount,
      required String currency,
      String? extraValue,
    });

class _CreateAssetSheet extends StatefulWidget {
  const _CreateAssetSheet({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final String submitLabel;
  final _CreateAssetSheetSubmit onSubmit;

  @override
  State<_CreateAssetSheet> createState() => _CreateAssetSheetState();
}

class _CreateAssetSheetState extends State<_CreateAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _extraController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController(text: '0');
    _currencyController = TextEditingController(text: 'USD');
    _extraController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        currency: _currencyController.text.trim().toUpperCase(),
        extraValue: _extraController.text.trim().isEmpty
            ? null
            : _extraController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: viewInsetsBottom + 24,
          top: 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xff1b1933),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _SheetField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _SheetField(
                  controller: _amountController,
                  label: 'Initial Balance',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                _SheetField(
                  controller: _currencyController,
                  label: 'Currency (ISO)',
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.submitLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff94a3b8)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
