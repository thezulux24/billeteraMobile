import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/app_popup.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/brand_banner.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../bank_accounts/models/bank_account.dart';
import '../../../bank_accounts/providers/bank_account_notifier.dart';
import '../../../cash_wallets/models/cash_wallet.dart';
import '../../../cash_wallets/providers/cash_wallet_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.wait([
        ref.read(cashWalletNotifierProvider).load(),
        ref.read(bankAccountNotifierProvider).load(),
      ]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final wallets = ref.watch(cashWalletNotifierProvider);
    final bankAccounts = ref.watch(bankAccountNotifierProvider);

    final totalAssets = wallets.totalBalance + bankAccounts.totalBalance;

    return GlassScaffold(
      child: AnimatedOpacity(
        opacity: _showContent ? 1 : 0,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _showContent ? Offset.zero : const Offset(0, 0.05),
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeOutCubic,
          child: RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              children: [
                AppTopBar(
                  title: 'Inicio',
                  subtitle:
                      auth.session?.email ??
                      'Administra tus activos y cuentas desde un solo lugar.',
                  actions: [
                    AppTopBarAction(
                      label: 'Perfil',
                      icon: Icons.manage_accounts_outlined,
                      style: AppTopBarActionStyle.primary,
                      onPressed: () => context.push('/profile'),
                    ),
                    AppTopBarAction(
                      label: 'Salir',
                      icon: Icons.logout_rounded,
                      style: AppTopBarActionStyle.danger,
                      onPressed: auth.isBusy ? null : _confirmSignOut,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceLg),
                const BrandBanner(
                  title: 'Vista general de tus finanzas',
                  subtitle:
                      'Controla billeteras en efectivo y cuentas bancarias con una interfaz unificada.',
                ),
                const SizedBox(height: AppTokens.spaceLg),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activos liquidos totales',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTokens.spaceSm),
                      Text(
                        '${totalAssets.toStringAsFixed(2)} USD',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppTokens.spaceSm),
                      Wrap(
                        spacing: AppTokens.spaceSm,
                        runSpacing: AppTokens.spaceSm,
                        children: [
                          _MetricChip(
                            icon: Icons.account_balance_wallet_outlined,
                            label:
                                'Efectivo: ${wallets.totalBalance.toStringAsFixed(2)}',
                          ),
                          _MetricChip(
                            icon: Icons.account_balance_outlined,
                            label:
                                'Bancos: ${bankAccounts.totalBalance.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                _SectionCard(
                  title: 'Billeteras de efectivo',
                  ctaLabel: 'Nueva billetera',
                  ctaIcon: Icons.add_circle_outline_rounded,
                  ctaLoading: wallets.isSubmitting,
                  onTapCta: _openCreateWalletSheet,
                  child: wallets.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _WalletList(
                          wallets: wallets.wallets,
                          isSubmitting: wallets.isSubmitting,
                          onDelete: _confirmDeleteWallet,
                        ),
                ),
                const SizedBox(height: AppTokens.spaceLg),
                _SectionCard(
                  title: 'Cuentas bancarias',
                  ctaLabel: 'Nueva cuenta',
                  ctaIcon: Icons.account_balance_outlined,
                  ctaLoading: bankAccounts.isSubmitting,
                  onTapCta: _openCreateBankAccountSheet,
                  child: bankAccounts.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _BankAccountList(
                          accounts: bankAccounts.accounts,
                          isSubmitting: bankAccounts.isSubmitting,
                          onDelete: _confirmDeleteBankAccount,
                        ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                if (wallets.error != null) ...[
                  Text(
                    'Billeteras: ${wallets.error!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                ],
                if (bankAccounts.error != null)
                  Text(
                    'Bancos: ${bankAccounts.error!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
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

  Future<void> _confirmSignOut() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text(
            'Se cerrara tu sesion actual en este dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
    if (shouldExit != true || !mounted) {
      return;
    }
    await ref.read(authNotifierProvider).signOut();
  }

  Future<void> _openCreateWalletSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        final sheetRoute = ModalRoute.of(sheetContext);
        return _CreateAssetSheet(
          title: 'Crear billetera',
          submitLabel: 'Guardar billetera',
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
                if (!mounted) {
                  return;
                }
                if (created) {
                  final canCloseSheet =
                      sheetNavigator.mounted &&
                      (sheetRoute?.isCurrent ?? false);
                  if (canCloseSheet) {
                    sheetNavigator.pop();
                  }
                  showAppPopup(
                    context,
                    message: 'Billetera creada correctamente.',
                    type: AppPopupType.success,
                  );
                  return;
                }
                final error = ref.read(cashWalletNotifierProvider).error;
                showAppPopup(
                  context,
                  message: error ?? 'No se pudo crear la billetera.',
                  type: AppPopupType.error,
                );
              },
        );
      },
    );
  }

  Future<void> _openCreateBankAccountSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        final sheetRoute = ModalRoute.of(sheetContext);
        return _CreateAssetSheet(
          title: 'Crear cuenta bancaria',
          extraFieldLabel: 'Banco (opcional)',
          submitLabel: 'Guardar cuenta',
          onSubmit:
              ({
                required String name,
                required double amount,
                required String currency,
                String? extraValue,
              }) async {
                final created = await ref
                    .read(bankAccountNotifierProvider)
                    .createAccount(
                      name: name,
                      bankName: extraValue,
                      balance: amount,
                      currency: currency,
                    );
                if (!mounted) {
                  return;
                }
                if (created) {
                  final canCloseSheet =
                      sheetNavigator.mounted &&
                      (sheetRoute?.isCurrent ?? false);
                  if (canCloseSheet) {
                    sheetNavigator.pop();
                  }
                  showAppPopup(
                    context,
                    message: 'Cuenta bancaria creada correctamente.',
                    type: AppPopupType.success,
                  );
                  return;
                }
                final error = ref.read(bankAccountNotifierProvider).error;
                showAppPopup(
                  context,
                  message: error ?? 'No se pudo crear la cuenta bancaria.',
                  type: AppPopupType.error,
                );
              },
        );
      },
    );
  }

  Future<void> _confirmDeleteWallet(CashWallet wallet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar billetera'),
          content: Text('Se eliminara "${wallet.name}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (confirm != true || !mounted) {
      return;
    }

    final deleted = await ref
        .read(cashWalletNotifierProvider)
        .deleteWallet(wallet.id);
    if (!mounted) {
      return;
    }
    if (deleted) {
      showAppPopup(
        context,
        message: 'Billetera eliminada.',
        type: AppPopupType.success,
      );
      return;
    }
    final error = ref.read(cashWalletNotifierProvider).error;
    showAppPopup(
      context,
      message: error ?? 'No se pudo eliminar la billetera.',
      type: AppPopupType.error,
    );
  }

  Future<void> _confirmDeleteBankAccount(BankAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar cuenta bancaria'),
          content: Text('Se eliminara "${account.name}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (confirm != true || !mounted) {
      return;
    }

    final deleted = await ref
        .read(bankAccountNotifierProvider)
        .deleteAccount(account.id);
    if (!mounted) {
      return;
    }
    if (deleted) {
      showAppPopup(
        context,
        message: 'Cuenta bancaria eliminada.',
        type: AppPopupType.success,
      );
      return;
    }
    final error = ref.read(bankAccountNotifierProvider).error;
    showAppPopup(
      context,
      message: error ?? 'No se pudo eliminar la cuenta bancaria.',
      type: AppPopupType.error,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.ctaLoading,
    required this.onTapCta,
    required this.child,
  });

  final String title;
  final String ctaLabel;
  final IconData ctaIcon;
  final bool ctaLoading;
  final VoidCallback onTapCta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.spaceSm),
          GlassButton(
            label: ctaLabel,
            icon: ctaIcon,
            loading: ctaLoading,
            onPressed: onTapCta,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          child,
        ],
      ),
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
    this.extraFieldLabel,
  });

  final String title;
  final String submitLabel;
  final _CreateAssetSheetSubmit onSubmit;
  final String? extraFieldLabel;

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
    if (_submitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

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
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.82;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          left: AppTokens.spaceLg,
          right: AppTokens.spaceLg,
          bottom: viewInsetsBottom + AppTokens.spaceLg,
          top: AppTokens.spaceLg,
        ),
        child: GlassCard(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    if (widget.extraFieldLabel != null) ...[
                      const SizedBox(height: AppTokens.spaceSm),
                      TextFormField(
                        controller: _extraController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: widget.extraFieldLabel,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTokens.spaceSm),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Saldo inicial',
                      ),
                      validator: (value) {
                        final amount = double.tryParse((value ?? '').trim());
                        if (amount == null || amount < 0) {
                          return 'Ingresa un monto valido (>= 0)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTokens.spaceSm),
                    TextFormField(
                      controller: _currencyController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Moneda (ISO)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length != 3) {
                          return 'Usa codigo ISO de 3 letras';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    GlassButton(
                      label: widget.submitLabel,
                      icon: Icons.save_outlined,
                      loading: _submitting,
                      onPressed: _submit,
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
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceSm,
        vertical: AppTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: AppTokens.spaceXs),
          Text(label),
        ],
      ),
    );
  }
}

class _WalletList extends StatelessWidget {
  const _WalletList({
    required this.wallets,
    required this.isSubmitting,
    required this.onDelete,
  });

  final List<CashWallet> wallets;
  final bool isSubmitting;
  final Future<void> Function(CashWallet wallet) onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: wallets.isEmpty
          ? const Text(
              'Aun no tienes billeteras. Crea la primera para comenzar.',
            )
          : Column(
              key: ValueKey('wallets-${wallets.length}'),
              children: [
                for (final wallet in wallets) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(wallet.name),
                    subtitle: Text(
                      'Actualizado ${_formatDate(wallet.updatedAt)}',
                    ),
                    trailing: Wrap(
                      spacing: AppTokens.spaceSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${wallet.balance.toStringAsFixed(2)} ${wallet.currency}',
                        ),
                        IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () => onDelete(wallet),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (wallet != wallets.last) const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

class _BankAccountList extends StatelessWidget {
  const _BankAccountList({
    required this.accounts,
    required this.isSubmitting,
    required this.onDelete,
  });

  final List<BankAccount> accounts;
  final bool isSubmitting;
  final Future<void> Function(BankAccount account) onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: accounts.isEmpty
          ? const Text(
              'Aun no tienes cuentas bancarias. Agrega una para continuar.',
            )
          : Column(
              key: ValueKey('bank-accounts-${accounts.length}'),
              children: [
                for (final account in accounts) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(account.name),
                    subtitle: Text(
                      account.bankName == null || account.bankName!.isEmpty
                          ? 'Actualizado ${_formatDate(account.updatedAt)}'
                          : '${account.bankName} · ${_formatDate(account.updatedAt)}',
                    ),
                    trailing: Wrap(
                      spacing: AppTokens.spaceSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${account.balance.toStringAsFixed(2)} ${account.currency}',
                        ),
                        IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () => onDelete(account),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (account != accounts.last) const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
