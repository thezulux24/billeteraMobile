import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/bank_accounts/providers/bank_account_notifier.dart';
import '../../features/cash_wallets/providers/cash_wallet_notifier.dart';
import '../../features/credit_cards/providers/credit_card_notifier.dart';
import '../../core/theme/app_colors.dart';
import 'glass_text_field.dart';
// ─── Account Type ────────────────────────────────────────────────────────────

enum _AccountType { bank, cash, credit }

extension _AccountTypeX on _AccountType {
  String get label => switch (this) {
    _AccountType.bank => 'Bank',
    _AccountType.cash => 'Cash',
    _AccountType.credit => 'Credit',
  };

  IconData get icon => switch (this) {
    _AccountType.bank => Icons.account_balance_rounded,
    _AccountType.cash => Icons.payments_rounded,
    _AccountType.credit => Icons.credit_card_rounded,
  };
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class AddAccountBottomSheet extends ConsumerStatefulWidget {
  const AddAccountBottomSheet({super.key});

  @override
  ConsumerState<AddAccountBottomSheet> createState() =>
      _AddAccountBottomSheetState();
}

class _AddAccountBottomSheetState extends ConsumerState<AddAccountBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  _AccountType _accountType = _AccountType.bank;
  String _creditTier = 'Classic';
  String _cardProvider = 'Visa';

  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _limitController = TextEditingController();
  bool _creating = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _balanceController.dispose();
    _lastFourController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _switchType(_AccountType type) {
    if (_accountType == type) return;
    HapticFeedback.selectionClick();
    _fadeCtrl.forward(from: 0);
    setState(() => _accountType = type);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                // Liquid glass: capas de color y gradiente superpuestas
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC1A1530), // deep indigo translucent
                          Color(0xEE0F0E1C), // near-black
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xE6EDE9FE), Color(0xF0EEF2FF)],
                      ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        children: [
                          // ── Drag handle ──────────────────────────────────────
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Header ───────────────────────────────────────────
                          _LiquidHeader(accountType: _accountType),
                          const SizedBox(height: 28),

                          // ── Type Selector (main feature) ─────────────────────
                          _AnimatedTypeSelector(
                            selected: _accountType,
                            onChanged: _switchType,
                          ),
                          const SizedBox(height: 32),

                          // ── Fields (fade when switching) ─────────────────────
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: _buildFields(isDark),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        // ── CTA Button ───────────────────────────────────────
                        child: _LiquidButton(
                          label: 'Create Account',
                          onPressed: _createAccount,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassTextField(
          controller: _nameController,
          label: 'Account Name',
          hintText: 'e.g. Main Savings',
          prefixIcon: Icons.label_outline_rounded,
          isPremium: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter an account name' : null,
        ),
        const SizedBox(height: 16),

        // Balance (not for Credit)
        if (_accountType != _AccountType.credit) ...[
          GlassTextField(
            controller: _balanceController,
            label: 'Current Balance',
            hintText: '0.00',
            prefixIcon: Icons.attach_money_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isPremium: true,
          ),
          const SizedBox(height: 16),
        ],

        // Bank name (not for Cash)
        if (_accountType != _AccountType.cash) ...[
          GlassTextField(
            controller: _bankNameController,
            label: 'Bank Name',
            hintText: 'e.g. Chase, BBVA',
            prefixIcon: Icons.account_balance_rounded,
            isPremium: true,
          ),
          const SizedBox(height: 16),
        ],

        // Credit-only fields
        if (_accountType == _AccountType.credit) ...[
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _lastFourController,
                  label: 'Last 4 Digits',
                  hintText: '0000',
                  prefixIcon: Icons.pin_rounded,
                  keyboardType: TextInputType.number,
                  isPremium: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassDropdown(
                  label: 'Provider',
                  options: const ['Visa', 'Mastercard', 'Amex'],
                  selected: _cardProvider,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _cardProvider = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tier label
          Text(
            'CARD TIER',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 12),
          _TierSelector(
            selected: _creditTier,
            onChanged: (t) => setState(() => _creditTier = t),
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          GlassTextField(
            controller: _limitController,
            label: 'Credit Limit',
            hintText: '5000.00',
            prefixIcon: Icons.speed_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isPremium: true,
          ),
        ],
      ],
    );
  }

  Future<void> _createAccount() async {
    if (_creating) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _creating = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final bankName = _bankNameController.text.trim();
    bool success = false;

    try {
      if (_accountType == _AccountType.bank) {
        success = await ref
            .read(bankAccountNotifierProvider)
            .createAccount(
              name: name,
              balance: balance,
              bankName: bankName,
              currency: 'USD',
            );
      } else if (_accountType == _AccountType.cash) {
        success = await ref
            .read(cashWalletNotifierProvider)
            .createWallet(name: name, balance: balance, currency: 'USD');
      } else {
        final limit = double.tryParse(_limitController.text) ?? 0.0;
        final lastFour = _lastFourController.text.trim();
        success = await ref
            .read(creditCardNotifierProvider)
            .createCard(
              name: name,
              issuer: bankName.isNotEmpty ? bankName : null,
              lastFour: lastFour.length == 4 ? lastFour : null,
              cardProvider: _cardProvider.toLowerCase(),
              tier: _creditTier.toLowerCase(),
              creditLimit: limit,
              currentDebt: 0.0,
              currency: 'USD',
            );
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _creating = false);
      }
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A1530),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Failed to create account. Please try again.',
            style: GoogleFonts.manrope(color: Colors.white),
          ),
        ),
      );
    }
  }
}

// ─── Liquid Header ────────────────────────────────────────────────────────────

class _LiquidHeader extends StatelessWidget {
  const _LiquidHeader({required this.accountType});
  final _AccountType accountType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Glow icon badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [AppColors.stitchPurple, AppColors.stitchIndigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.stitchIndigo.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(accountType.icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Account',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F0E1C),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              accountType.label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Animated Type Selector ───────────────────────────────────────────────────

class _AnimatedTypeSelector extends StatelessWidget {
  const _AnimatedTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final _AccountType selected;
  final ValueChanged<_AccountType> onChanged;

  static const _types = _AccountType.values;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final padding = 4.0;
        final itemW = (totalW - padding * 2) / _types.length;
        final selectedIndex = _types.indexOf(selected);

        return Container(
          height: 52,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Stack(
            children: [
              // ── Animated sliding pill ──────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutExpo,
                left: selectedIndex * itemW,
                top: 0,
                bottom: 0,
                width: itemW,
                child: const _SlidingPill(),
              ),

              // ── Labels row ─────────────────────────────────────────
              Row(
                children: _types.map((type) {
                  final isSelected = type == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(type),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.45),
                          ),
                          child: Text(type.label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// La "pill" de vidrio que se desliza debajo del texto seleccionado.
class _SlidingPill extends StatelessWidget {
  const _SlidingPill();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.stitchIndigo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.stitchIndigo.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: -2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Glass Text Field ─────────────────────────────────────────────────────────

class _GlassDropdown extends StatelessWidget {
  const _GlassDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String selected;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1530) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.35),
            size: 20,
          ),
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF0F0E1C),
          ),
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Tier Selector ────────────────────────────────────────────────────────────

class _TierSelector extends StatelessWidget {
  const _TierSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final bool isDark;

  static const _tiers = [
    ('Classic', Color(0xFF94A3B8)),
    ('Gold', Color(0xFFFBBF24)),
    ('Platinum', Color(0xFFE2E8F0)),
    ('Black', Color(0xFF1E293B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _tiers.map(((String name, Color color) tierData) {
        final (name, color) = tierData;
        final isSelected = selected == name;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(name);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected
                    ? color
                    : isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.12),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color
                        : isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF0F0E1C))
                        : isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Liquid CTA Button ────────────────────────────────────────────────────────

class _LiquidButton extends StatefulWidget {
  const _LiquidButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<_LiquidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.stitchPurple, AppColors.stitchIndigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.stitchIndigo.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.stitchPurple.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
