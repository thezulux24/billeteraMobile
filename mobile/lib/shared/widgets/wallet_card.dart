import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum WalletCardType { visa, amex, savings }

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.name,
    required this.balance,
    required this.currency,
    required this.type,
    this.lastFourDigit,
  });

  final String name;
  final double balance;
  final String currency;
  final WalletCardType type;
  final String? lastFourDigit;

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();
    final icon = _getIcon();
    final tag = _getTag();

    return Container(
      width: 280,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: gradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Pattern/Texture simulation
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://www.transparenttextures.com/patterns/stardust.png',
                  ),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          // Glow effect
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == WalletCardType.savings
                          ? '\$${balance.toStringAsFixed(0)}'
                          : '**** ${lastFourDigit ?? "0000"}',
                      style:
                          GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: type == WalletCardType.savings
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: type == WalletCardType.savings
                                ? -0.5
                                : 4,
                          ).copyWith(
                            fontFamily: type == WalletCardType.savings
                                ? null
                                : 'Courier',
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (type) {
      case WalletCardType.visa:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff4f46e5).withValues(alpha: 0.4),
            const Color(0xff0f0c1d).withValues(alpha: 0.6),
          ],
        );
      case WalletCardType.amex:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff1e293b).withValues(alpha: 0.6),
            const Color(0xff000000).withValues(alpha: 0.8),
          ],
        );
      case WalletCardType.savings:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff701a75).withValues(alpha: 0.4),
            const Color(0xff312e81).withValues(alpha: 0.6),
          ],
        );
    }
  }

  IconData _getIcon() {
    switch (type) {
      case WalletCardType.visa:
        return Icons.account_balance;
      case WalletCardType.amex:
        return Icons.diamond_outlined;
      case WalletCardType.savings:
        return Icons.savings_outlined;
    }
  }

  String? _getTag() {
    switch (type) {
      case WalletCardType.visa:
        return 'VISA';
      case WalletCardType.amex:
        return 'AMEX';
      case WalletCardType.savings:
        return null;
    }
  }
}
